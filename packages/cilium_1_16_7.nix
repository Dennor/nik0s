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
      url = "https://github.com/cilium/charts/raw/master/cilium-1.16.7.tgz";
      hash = "sha256-mrx9C3E+SW07dscZHgbNE79CWip1F8T7TDU8/yoWkzY=";
    };
    # Very slightly patched cilium chart with an ability to override
    # /lib/modules bind mount.
    patches = [./cilium-1_16_7.patch];
  }
