{
  stdenv,
  fetchurl,
}: let
  mkHelmChart = import ../lib/helm.nix;
in
  mkHelmChart {
    inherit stdenv;
    name = "cilium";
    version = "v1.16.4";
    src = fetchurl {
      url = "https://github.com/cilium/charts/raw/master/cilium-1.16.4.tgz";
      hash = "sha256-6Wofug82GSa7Kea8L+Vl1f42vpxRlPrYXo7S6CjQmGQ=";
    };
    # Very slightly patched cilium chart with an ability to override
    # /lib/modules bind mount.
    patches = [./cilium-1_16_4.patch];
  }
