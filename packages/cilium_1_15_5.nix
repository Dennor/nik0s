{
  stdenv,
  fetchurl,
}: let
  mkHelmChart = import ../lib/helm.nix;
in
  mkHelmChart {
    inherit stdenv;
    name = "cilium";
    version = "v1.15.5";
    src = fetchurl {
      url = "https://github.com/cilium/charts/raw/master/cilium-1.15.5.tgz";
      hash = "sha256-oIuZb3T8YYUxNcPSFrUS8rxTvYM8Jaa7CZFjLDDxD5o=";
    };
    # Very slightly patched cilium chart with an ability to override
    # /lib/modules bind mount.
    patches = [./cilium-1_15_4.patch];
  }
