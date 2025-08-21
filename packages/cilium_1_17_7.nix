{
  stdenv,
  fetchurl,
}: let
  mkHelmChart = import ../lib/helm.nix;
in
  mkHelmChart {
    inherit stdenv;
    name = "cilium";
    version = "v1.17.7";
    src = fetchurl {
      url = "https://github.com/cilium/charts/raw/master/cilium-1.17.7.tgz";
      hash = "sha256-XqNcDriErZYfxzhxbnPQOm8UtPtzrkbQtHopoEQsCf4=";
    };
    # Very slightly patched cilium chart with an ability to override
    # /lib/modules bind mount.
    patches = [./cilium-1_17_7.patch];
  }
