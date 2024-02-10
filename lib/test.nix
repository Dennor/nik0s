{
  makeTest ? import <nixpkgs/nixos/tests/make-test-python.nix>,
  eval-config ? import <nixpkgs/nixos/lib/eval-config.nix>,
  pkgs ? import <nixpkgs> {},
}:
with pkgs; let
  mkBundle = import ../lib/airgap.nix;
  testingBundle = mkBundle {
    inherit (pkgs) stdenv dockerTools;
    images = [
      {
        imageName = "curlimages/curl";
        imageDigest = "sha256:c3b8bee303c6c6beed656cfc921218c529d65aa61114eb9e27c62047a1271b9b";
        sha256 = "0qcpklsjdakw1kl4hv0crsvz86j8xkkiyhxig95jl7xyyc80xd9p";
        finalImageName = "curlimages/curl";
        finalImageTag = "8.6.0";
      }
    ];
    name = "testing_bundle";
  };
  testPackage = pkgs.stdenv.mkDerivation rec {
    name = "test-package";
    src = ../.;
    phases = ["installPhase"];
    installPhase = ''
      set -x
      mkdir -p $out
      cp -r ${src}/tests/* $out
    '';
  };
  k0s = pkgs.k0s_1_29_1;
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
      ### PLEASE DO NOT DO THIS! THIS IS INSECURE AND IT'S ONLY HERE FOR TESTING
      ### IN REAL WORLD THIS SHOULD BE AN ABSOLUTE PATH TO A SECRET CREATED BY FOR EXAMPLE
      ### SOPS OR SOME SUCH
      then [(builtins.attrValues (builtins.mapAttrs (_: value: ../tests/bootstrap-token-${value.id}.yaml) auth))]
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
          virtualisation.diskSize = 8192;
          virtualisation.memorySize = 2048;
          virtualisation.vlans = [1 2];
          imports =
            ((modules testCase) node)
            ++ [
              ({config, ...}: {
                boot = {
                  kernelPackages = pkgs.linuxPackages_6_6_hardened_bpfilter;
                };
                environment.systemPackages = [pkgs.cri-tools pkgs.k0s pkgs.curl testPackage];
                environment.variables = {
                  CONTAINER_RUNTIME_ENDPOINT = "unix:///run/k0s/containerd.sock";
                };
                networking.nameservers = ["1.1.1.1" "1.0.0.1"];

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
                  k8sServiceHost = (apiHost testCase) node;
                  k8sServicePort = (apiPort testCase) node;
                  kubeconfig = "/var/lib/k0s/pki/admin.conf";
                  values = {
                    imap = {
                      operator = {
                        clusterPoolIPv4PodCIDRList = (podCIDR testCase) node;
                      };
                    };
                    directRoutingDevice = (directRoutingDevice testCase) node;
                  };
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
                  bundles = [pkgs.ciliumBundle pkgs.openebsLocalPVBundle testingBundle];
                  version = "1.28.4";
                  airgap = true;
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
      ${controller}.succeed("k0s kubectl run --image curlimages/curl:8.6.0 --restart=OnFailure test1 -- -I -k https://kubernetes")
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
      // args)) {
      inherit pkgs eval-config;
    };
in {inherit makeTest' testPackage;}
