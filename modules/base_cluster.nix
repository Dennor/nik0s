{
  config,
  options,
  lib,
  ...
}: {
  # Describes the whole topology of the cluster
  options.cluster = import ../lib/cluster_opts.nix {inherit lib;};
  config = {};
}
