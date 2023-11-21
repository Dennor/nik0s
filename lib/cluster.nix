{pkgs}:
with pkgs.lib; let
  clusterFields = builtins.attrNames (import ./cluster_opts.nix {inherit (pkgs) lib;});
  filterFields = name: _: (builtins.any (v: v == name) clusterFields);
  checkCluster = cluster:
    (evalModules {
      modules = [
        ../modules/base_cluster.nix
        {
          config = {
            cluster = filterAttrs filterFields cluster;
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
                publicAddr = builtins.elemAt node.network.public.ipv4.addresses 0;
              in {
                kind = pool.kind;
                name = "${n}.${poolName}.${cluster.name}";
                address = publicAddr.address;
              }) (
                builtins.attrNames pool.nodes
              )
            else []
        )
        cluster.pools
      )
    );
  clusterNodes = clusterNodesByKind null;
  controllerNodes = clusterNodesByKind "controller";
  workerNodes = clusterNodesByKind "worker";
in {
  inherit clusterNodes controllerNodes workerNodes;
  mkCluster = cluster: (pkgs.formats.json {}).generate "cluster.json" (checkCluster cluster);
  mkInstallScript = {
    flake,
    cluster,
  }: let
    nodes = clusterNodes (checkCluster cluster);
    installScript = pkgs.writeShellScript "install_cluster.sh" ''
      set -e

      ${(builtins.concatStringsSep "\n" (builtins.map (node: "${pkgs.nix}/bin/nix run github:numtide/nixos-anywhere -- --flake ${flake}#${node.name} root@${node.address}")
          nodes))}
    '';
  in
    pkgs.stdenv.mkDerivation {
      src = flake;
      name = "install-${cluster.name}";
      installPhase = ''
        cp ${installScript} $out
        chmod +x $out
      '';
    };
  mkUpdateScript = {
    flake,
    cluster,
  }: let
    # Enforce order of update, controller nodes first
    controllers = controllerNodes (checkCluster cluster);
    workers = workerNodes (checkCluster cluster);
    nodes = controllers ++ workers;
    managmentAddress = (builtins.elemAt controllers 0).address;
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
          if node.kind == "controller"
          then "update_controller"
          else "update_worker"
        } ${node.name} ${node.address}")
        nodes))}
    '';
  in
    pkgs.stdenv.mkDerivation {
      src = flake;
      name = "update-${cluster.name}";
      installPhase = ''
        cp ${updateScript} $out
        chmod +x $out
      '';
    };
}
