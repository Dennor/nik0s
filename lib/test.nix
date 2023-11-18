{
  makeTest ? import <nixpkgs/nixos/tests/make-test-python.nix>,
  eval-config ? import <nixpkgs/nixos/lib/eval-config.nix>,
  pkgs ? import <nixpkgs> {},
}:
with pkgs; let
  k0s = pkgs.k0s;
  ciliumChart = pkgs.ciliumChart;
  mkTestCase = cluster: {
    name = cluster.clusterName;
    pools = cluster.pools;
    nodes = lib.flatten (
      lib.mapAttrsToList
      (
        poolName: pool:
          lib.mapAttrsToList
          (nodeName: node: {
            uniqueName = "${nodeName}-${poolName}-${cluster.clusterName}";
            names = {
              node = nodeName;
              pool = poolName;
            };
            config = {
              node = node;
              pool = pool;
            };
          })
          pool.nodes
      )
      cluster.pools
    );
  };
  mkTest = {
    testCase,
    auth,
    apiHosts,
    apiHost ? (testCase: node: (builtins.elemAt node.config.node.network.private.ipv4.addresses 0).address),
    apiPort ? (testCase: node: 6443),
    apiSans ? (testCase: node: [(builtins.elemAt node.config.node.network.public.ipv4.addresses 0).address]),
    directRoutingDevice ? (testCase: node: node.config.node.network.private.link),
    manifests ? (testCase: node:
      if node.config.pool.kind == "controller"
      then [[auth.controller.manifest auth.worker.manifest]]
      else []),
    podCIDR ? (testCase: node: ["10.0.0.0/16"]),
    modules ? (
      testCase: node: lib.forEach (lib.attrValues (import ../modules)) (mod: args: (mod (args // {inherit pkgs;})))
    ),
    helm ? (testCase: node:
      if node.config.pool.kind == "controller"
      then {
        openebs-localpv = {
          enable = true;
          chart = pkgs.openebsChart;
          namespace = "openebs";
          kubeconfig = "/var/lib/k0s/pki/admin.conf";
          values = {
            localprovisioner = {
              deviceClass.enabled = false;
              hostpathClass.isDefaultClass = true;
            };
          };
        };
      }
      else {}),
    ...
  }: {...}: {
    name = testCase.name;

    nodes = builtins.listToAttrs (builtins.map (node: {
        globalTimeout = 1200;
        name = node.uniqueName;
        value = {
          virtualisation.diskSize = 6144;
          virtualisation.memorySize = 1536;
          virtualisation.vlans = [1 2];
          imports =
            ((modules testCase) node)
            ++ [
              ({config, ...}: {
                boot = {
                  kernelPackages = pkgs.linuxPackages_xanmod_bpfilter_stable;
                };
                environment.systemPackages = [pkgs.cri-tools pkgs.k0s pkgs.curl];
                environment.variables = {
                  CONTAINER_RUNTIME_ENDPOINT = "unix:///run/k0s/containerd.sock";
                };
                cluster = {
                  enable = true;
                  name = testCase.name;
                  pools = testCase.pools;
                  machine = {
                    pool = node.names.pool;
                    node = node.names.node;
                  };
                  apiHost = (apiHost testCase) node;
                  apiPort = (apiPort testCase) node;
                };
                k0s-cilium = {
                  enable = node.config.pool.kind == "controller";
                  podCIDR = (podCIDR testCase) node;
                  k8sServiceHost = (apiHost testCase) node;
                  k8sServicePort = (apiPort testCase) node;
                  directRoutingDevice = (directRoutingDevice testCase) node;
                  kubeconfig = "/var/lib/k0s/pki/admin.conf";
                };
                helm = (helm testCase) node;
                services.k0s = {
                  enable = true;
                  mode = node.config.pool.kind;
                  api = {
                    address = (apiHost testCase) node;
                    sans = (apiSans testCase) node;
                  };
                  master = node.config.node.master or null;
                  joinToken = node.config.node.joinToken or null;
                  manifests = (manifests testCase) node;
                  bundles = [pkgs.ciliumBundle pkgs.openebsLocalPVBundle];
                };
                documentation.nixos.enable = false;
              })
            ];
        };
      })
      testCase.nodes);

    # We are on purpouse using different subnets and hostnames than the ones set by testing
    # module, as the whole point of module is to have uniform cluster configuration driven
    # by cluster config.
    testScript = let
      controller = (builtins.elemAt (builtins.filter (node: node.config.pool.kind == "controller") testCase.nodes) 0).names.node;
      worker = (builtins.elemAt (builtins.filter (node: node.config.pool.kind != "controller") testCase.nodes) 0).names.node;
    in ''
      start_all()
      # Wait for nodes
      ${controller}.wait_until_succeeds("k0s kubectl get node | grep '\<Ready\>'")
      ${controller}.wait_until_fails("k0s kubectl get node | grep '\<NotReady\>'")
      # Wait for k0s to be running
      ${controller}.wait_until_succeeds("k0s kubectl get pods")
      # Wait for cilium
      ${controller}.wait_until_succeeds("k0s kubectl get pods -A | grep cilium")
      # Wait for k0s all pods to be ready
      ${controller}.wait_until_succeeds("k0s kubectl get -A pods -o go-template='{{ range .items}}{{ range .status.containerStatuses }}{{ .ready }}{{ end }}{{ end }}' | grep -v false")
      # Test connectivity
      ${controller}.succeed("k0s kubectl get -A pods -o go-template='{{ range .items}}{{ range .status.containerStatuses }}{{ .ready }}{{ end }}{{ end }}' | grep -v false")
      # Test if kubernetes is reachable for pods
      ${controller}.succeed("k0s kubectl run --image busybox:1.35.0 --restart=OnFailure --command test1 -- sh -c 'wget https://kubernetes:443/healthz 2>&1 | grep 401'")
      # Make sure that pod completed
      ${controller}.wait_until_succeeds("k0s kubectl get pods | grep test1 | grep Completed")
      # Test kube apiserver connectivity
      ${builtins.concatStringsSep "\n" (
        lib.forEach apiHosts (api: "${worker}.wait_until_succeeds(\"curl -k https://${api}:6443\")")
      )}

    '';
  };
  makeTest' = args:
    makeTest (mkTest ({
        testCase = mkTestCase args.cluster;
      }
      // args)) {inherit pkgs eval-config;};
in
  makeTest'
