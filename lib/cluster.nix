{pkgs}:
with pkgs.lib; let
  removeListedAttrs = attrs: removeNames: filterAttrs (name: _: ((builtins.any (v: v == name) removeNames) == false)) attrs;
  keepListedAttrs = attrs: keepNames: filterAttrs (name: _: (builtins.any (v: v == name) keepNames)) attrs;
  clusterFields = builtins.attrNames (import ./cluster_opts.nix {inherit (pkgs) lib;});
  checkCluster = cluster:
    (evalModules {
      modules = [
        ../modules/base_cluster.nix
        {
          config = {
            cluster = keepListedAttrs cluster clusterFields;
          };
        }
      ];
    })
    .config
    .cluster;
  clusterNodesByKind = kind: cluster:
    builtins.concatLists (
      builtins.attrValues (
        builtins.mapAttrs (
          poolName: pool:
            if kind == null || kind == pool.kind
            then
              builtins.map (n: let
                node = cluster.pools.${poolName}.nodes.${n};
              in
                cluster
                // {
                  inherit pool node;
                  machine = {
                    node = n;
                    pool = poolName;
                  };
                }) (
                builtins.attrNames pool.nodes
              )
            else []
        )
        (checkCluster cluster).pools
      )
    );
  clusterNodes = clusterNodesByKind null;
  controllerNodes = clusterNodesByKind "controller";
  workerNodes = clusterNodesByKind "worker";
  nodeFQDN = node: "${node.machine.node}.${node.machine.pool}.${node.name}";
  nodeAddress = node: (builtins.elemAt node.node.network.public.ipv4.addresses 0).address;
  nodeConfig = node: removeListedAttrs node ["pool" "node"];
in {
  inherit clusterNodes controllerNodes workerNodes nodeFQDN nodeAddress nodeConfig;
  mkCluster = cluster: (pkgs.formats.json {}).generate "cluster.json" (checkCluster cluster);
  mkInstallScript = {
    flake,
    cluster,
    workerScript ? null,
    controllerScript ? null,
  }: let
    nodes = clusterNodes cluster;
    installScript = pkgs.writeShellScript "install_cluster.sh" ''
      set -e

      nodeScript() {
        mkdir -p $1
        pushd $1
        $3
        popd
        ${pkgs.rsync}/bin/rsync -av $1/ root@$2:/
      }

      ${(builtins.concatStringsSep "\n" (builtins.map (node: ''
          ${pkgs.nix}/bin/nix run github:numtide/nixos-anywhere -- --flake ${flake}#${nodeFQDN node} root@${nodeAddress node}
          ${let
            script =
              if node.pool.kind == "controller"
              then controllerScript
              else workerScript;
          in
            if script != null
            then "nodeScript ${nodeFQDN node} ${nodeAddress node} ${script}"
            else ""}
        '')
        nodes))}

    '';
  in
    pkgs.stdenv.mkDerivation {
      src = flake;
      name = "install-${cluster.name}";
      installPhase = ''
        mkdir -p $out/bin
        cp ${installScript} $out/bin/install-${cluster.name}
        chmod +x $out/bin/install-${cluster.name}
      '';
    };
  mkUpdateScript = {
    flake,
    cluster,
  }: let
    # Enforce order of update, controller nodes first
    controllers = controllerNodes cluster;
    workers = workerNodes cluster;
    nodes = controllers ++ workers;
    managmentAddress = nodeAddress (builtins.elemAt controllers 0);
    updateScript = pkgs.writeShellScript "update_cluster.sh" ''
      set -e

      update_controller() {
        echo "updating controller node $2"
        ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake ${flake} --target-host "root@$1"
        until ssh "root@$1" systemctl status k0s; do
          echo "waiting for controller to finish updating $2"
        done
        echo "controller node $2 updated"
      }

      update_worker() {
        echo "waiting for worker node to be completely drained $2"
        # This here is on purpose done from controller node kubectl rather than local machine
        # to not have a dependency on the current system config.
        until ssh "root@${managmentAddress}" k0s kubectl drain $2; do
          echo "waiting for worker node to be completely drained $2"
        done
        ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake --target-gost "root@$1"
        until ssh "root@${managmentAddress}" k0s kubectl uncordon $2; do
          echo "waiting for worker node $2 to be available again"
        done
        echo "worker node $2 updated"
      }

      ${(builtins.concatStringsSep "\n" (builtins.map (node: "${
          if node.pool.kind == "controller"
          then "update_controller"
          else "update_worker"
        } ${nodeFQDN node} ${nodeAddress node}")
        nodes))}
    '';
  in
    pkgs.stdenv.mkDerivation {
      src = flake;
      name = "update-${cluster.name}";
      installPhase = ''
        mkdir -p $out/bin
        cp ${updateScript} $out/bin/update-${cluster.name}
        chmod +x $out/bin/update-${cluster.name}
      '';
    };
}
