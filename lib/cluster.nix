{pkgs}:
with pkgs.lib; let
  /*
    Removes names in list from attribute set

    removeListedAttrs :: AttrSet -> [String] -> AttrSet
  */
  removeListedAttrs = attrs: removeNames: filterAttrs (name: _: ((builtins.any (v: v == name) removeNames) == false)) attrs;

  /*
    Creates new attribute set containing only listed attributes.

    keepListedAttrs :: AttrSet -> [String] -> AttrSet
  */
  keepListedAttrs = attrs: keepNames: filterAttrs (name: _: (builtins.any (v: v == name) keepNames)) attrs;

  /*
    A list of cluster options
  */
  clusterFields = builtins.attrNames (import ./cluster_opts.nix {inherit (pkgs) lib;});

  /*
    Verifies if attribute set matches required cluster options.

    checkCluster :: AttrSet -> AttrSet
  */
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

  /*
    Returns cluster nodes of specific kind. If kind is null, returns all cluster nodes.

    clusterNodesByKind :: String -> AttrSet -> [String]
  */
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

  /*
    Returns all cluster nodes.

    clusterNodes :: AttrSet -> [String]
  */
  clusterNodes = clusterNodesByKind null;

  /*
    Returns all cluster controller nodes.

    controllerNodes :: AttrSet -> [String]
  */
  controllerNodes = clusterNodesByKind "controller";

  /*
    Returns all cluster worker nodes.

    workerNodes :: AttrSet -> [String]
  */
  workerNodes = clusterNodesByKind "worker";

  /*
    Returns a fully qualified domain name for the configured cluster node

    nodeFQDN :: AttrSet -> String
  */
  nodeFQDN = node: "${node.machine.node}.${node.machine.pool}.${node.name}";

  /*
    Returns node IPv4 public address.

    nodeAddress :: AttrSet -> String
  */
  nodeAddress = node: (builtins.elemAt node.node.network.public.ipv4.addresses 0).address;

  /*
    Cleans up node config by removing pool and node attributes

    nodeConfig :: AttrSet -> AttrSet
  */
  nodeConfig = node: removeListedAttrs node ["pool" "node"];
  yaml = pkgs.formats.yaml {};

  /*
    Creates a text file derivation build from a list of manifests. Manifests can be either
    a path to a valid yaml file or an attribute set.

    mkManifestFile :: String -> [AttrSet | path] -> Derivation
  */
  mkManifestFile = name: manifests:
    pkgs.writeText name ''
      ${builtins.concatStringsSep "" (builtins.map (manifest: let
        manifestFile =
          if builtins.isPath manifest
          then manifest
          else yaml.generate "manifest.yaml" manifest;
      in ''
        ---
        ${builtins.readFile manifestFile}'')
      manifests)}'';
in {
  inherit clusterNodes controllerNodes workerNodes nodeFQDN nodeAddress nodeConfig mkManifestFile;

  /*
    Creates a json derivation with cluster config.

    mkCluster :: AttrSet -> derivation
  */
  mkCluster = cluster: (pkgs.formats.json {}).generate "cluster.json" (checkCluster cluster);
  mkInstallScript = {
    flake,
    cluster,
    encryptionKeyScripts ? null,
    workerScript ? null,
    controllerScript ? null,
  }: let
    nodes = clusterNodes cluster;
    installScript = pkgs.writeShellScript "install_cluster.sh" ''
      set -e

      tmpdir=$(mktemp -d)
      cleanup() {
        rm -rf "$tmpdir"
      }
      trap cleanup EXIT

      nodeScript() {
        mkdir -p "$tmpdir/$1/extra-files"
        pushd "$tmpdir/$1/extra-files" > /dev/null
        $2
        popd > /dev/null
      }

      encryptionKeys() {
        mkdir -p "$tmpdir/$1/keys"
        pushd "$tmpdir/$1/keys" > /dev/null
        $2
        popd > /dev/null
      }

      ${(builtins.concatStringsSep "\n" (builtins.map (node: ''
          ${let
            script =
              if node.pool.kind == "controller"
              then controllerScript
              else workerScript;
          in
            if script != null
            then "nodeScript ${nodeFQDN node} ${script}"
            else ""}
          EXTRA_ARGS=""
          if [ -d "$tmpdir/${nodeFQDN node}/extra-files" ]; then
            EXTRA_ARGS="--extra-files $tmpdir/${nodeFQDN node}/extra-files"
          fi
          ${let
            script = encryptionKeyScripts."${nodeFQDN node}" or null;
          in
            if script != null
            then "encryptionKeys ${nodeFQDN node} ${script}"
            else ""}
          if [ -d "$tmpdir/${nodeFQDN node}/keys" ]; then
            pushd "$tmpdir/${nodeFQDN node}/keys" > /dev/null
            while IFS= read -r -d ''\'' file
            do
              src="$(readlink -m "$tmpdir/${nodeFQDN node}/keys/$file")"
              dst="$(readlink -m "/$file")"
              ssh -oStrictHostKeyChecking=accept-new root@${nodeAddress node} mkdir -p "$(dirname "$dst")"
              EXTRA_ARGS="$EXTRA_ARGS --disk-encryption-keys $dst $src"
            done <   <(find . -type f -print0)
            popd > /dev/null
          fi
          ${pkgs.nix}/bin/nix run github:numtide/nixos-anywhere -- --flake ${flake}#${nodeFQDN node} root@${nodeAddress node} $EXTRA_ARGS
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
  mkNodeInstallScript = {
    flake,
    cluster,
    workerScript ? null,
    controllerScript ? null,
  }: let
    nodes = clusterNodes cluster;
    installScript = pkgs.writeShellScript "install_node.sh" ''
      set -e

      tmpdir=$(mktemp -d)
      cleanup() {
        rm -rf "$tmpdir"
      }
      trap cleanup EXIT

      nodeScript() {
        mkdir -p $tmpdir/$1
        pushd $tmpdir/$1 > /dev/null
        $2
        popd > /dev/null
      }

      ${(builtins.concatStringsSep "\n" (builtins.map (node: ''
          if [[ "$*" == *"${nodeFQDN node}"* ]]; then
            ${let
            script =
              if node.pool.kind == "controller"
              then controllerScript
              else workerScript;
          in
            if script != null
            then "nodeScript ${nodeFQDN node} ${script}"
            else ""}
            EXTRA_ARGS=""
            if [ -d "$tmpdir/${nodeFQDN node}" ]; then
              EXTRA_ARGS="--extra-files $tmpdir/${nodeFQDN node}"
            fi
            ${pkgs.nix}/bin/nix run github:numtide/nixos-anywhere -- --flake ${flake}#${nodeFQDN node} root@${nodeAddress node} $EXTRA_ARGS
          fi
        '')
        nodes))}

    '';
  in
    pkgs.stdenv.mkDerivation {
      src = flake;
      name = "install-node-${cluster.name}";
      installPhase = ''
        mkdir -p $out/bin
        cp ${installScript} $out/bin/install-node-${cluster.name}
        chmod +x $out/bin/install-node-${cluster.name}
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
        ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake ${flake}#$2 --target-host "root@$1"
        ssh -oStrictHostKeyChecking=accept-new "root@$1" reboot
        sleep 5
        until ssh -oStrictHostKeyChecking=accept-new "root@$1" systemctl status k0s; do
          sleep 5
          echo "waiting for controller to finish updating $2"
        done
        echo "controller node $2 updated"
      }

      update_worker() {
        echo "waiting for worker node to be completely drained $2"
        # This here is on purpose done from controller node kubectl rather than local machine
        # to not have a dependency on the current system config.
        until ssh -oStrictHostKeyChecking=accept-new "root@${managmentAddress}" k0s kubectl drain --ignore-daemonsets --delete-emptydir-data $2; do
          sleep 5
          echo "waiting for worker node to be completely drained $2"
        done
        ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake ${flake}#$2 --target-host "root@$1"
        ssh -oStrictHostKeyChecking=accept-new "root@$1" reboot
        sleep 5
        until ssh -oStrictHostKeyChecking=accept-new "root@$1" systemctl status k0s; do
          sleep 5
          echo "waiting for worker node $2 to restart"
        done
        until ssh -oStrictHostKeyChecking=accept-new "root@${managmentAddress}" k0s kubectl uncordon $2; do
          sleep 5
          echo "waiting for worker node $2 to be available again"
        done
        echo "worker node $2 updated"
      }

      ${(builtins.concatStringsSep "\n" (builtins.map (node: "${
          if node.pool.kind == "controller"
          then "update_controller"
          else "update_worker"
        } ${nodeAddress node} ${nodeFQDN node}")
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
  # Update without reboot
  mkSoftUpdateScript = {
    flake,
    cluster,
  }: let
    # Enforce order of update, controller nodes first
    controllers = controllerNodes cluster;
    workers = workerNodes cluster;
    nodes = controllers ++ workers;
    managmentAddress = nodeAddress (builtins.elemAt controllers 0);
    updateScript = pkgs.writeShellScript "soft_update_cluster.sh" ''
      set -e

      update_controller() {
        echo "updating controller node $2"
        ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake ${flake}#$2 --target-host "root@$1"
        until ssh -oStrictHostKeyChecking=accept-new "root@$1" systemctl status k0s; do
          echo "waiting for controller to finish updating $2"
        done
        echo "controller node $2 updated"
      }

      update_worker() {
        echo "waiting for worker node to be completely drained $2"
        # This here is on purpose done from controller node kubectl rather than local machine
        # to not have a dependency on the current system config.
        until ssh -oStrictHostKeyChecking=accept-new "root@${managmentAddress}" k0s kubectl drain --ignore-daemonsets --delete-emptydir-data $2; do
          echo "waiting for worker node to be completely drained $2"
        done
        ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake ${flake}#$2 --target-host "root@$1"
        until ssh -oStrictHostKeyChecking=accept-new "root@${managmentAddress}" k0s kubectl uncordon $2; do
          sleep 5
          echo "waiting for worker node $2 to be available again"
        done
        echo "worker node $2 updated"
      }

      ${(builtins.concatStringsSep "\n" (builtins.map (node: "${
          if node.pool.kind == "controller"
          then "update_controller"
          else "update_worker"
        } ${nodeAddress node} ${nodeFQDN node}")
        nodes))}
    '';
  in
    pkgs.stdenv.mkDerivation {
      src = flake;
      name = "soft-update-${cluster.name}";
      installPhase = ''
        mkdir -p $out/bin
        cp ${updateScript} $out/bin/soft-update-${cluster.name}
        chmod +x $out/bin/soft-update-${cluster.name}
      '';
    };
  # Update configuration without cordoning and rebooting nodes
  mkConfigUpdateScript = {
    flake,
    cluster,
  }: let
    # Enforce order of update, controller nodes first
    controllers = controllerNodes cluster;
    workers = workerNodes cluster;
    nodes = controllers ++ workers;
    managmentAddress = nodeAddress (builtins.elemAt controllers 0);
    updateScript = pkgs.writeShellScript "config_update_cluster.sh" ''
      set -e

      update_controller() {
        echo "updating controller node $2"
        ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake ${flake}#$2 --target-host "root@$1"
        until ssh -oStrictHostKeyChecking=accept-new "root@$1" systemctl status k0s; do
          echo "waiting for controller to finish updating $2"
        done
        echo "controller node $2 updated"
      }

      update_worker() {
        ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake ${flake}#$2 --target-host "root@$1"
        echo "worker node $2 updated"
      }

      ${(builtins.concatStringsSep "\n" (builtins.map (node: "${
          if node.pool.kind == "controller"
          then "update_controller"
          else "update_worker"
        } ${nodeAddress node} ${nodeFQDN node}")
        nodes))}
    '';
  in
    pkgs.stdenv.mkDerivation {
      src = flake;
      name = "config-update-${cluster.name}";
      installPhase = ''
        mkdir -p $out/bin
        cp ${updateScript} $out/bin/config-update-${cluster.name}
        chmod +x $out/bin/config-update-${cluster.name}
      '';
    };
}
