{pkgs}: {
  mkCluster = cluster:
    with pkgs.lib; let
      clusterFields = builtins.attrNames (import ./cluster_opts.nix {inherit (pkgs) lib;});
      filterFields = name: _: (builtins.any (v: v == name) clusterFields);
    in
      (pkgs.formats.json {}).generate "cluster.json"
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
}
