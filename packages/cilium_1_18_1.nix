{
  stdenv,
  fetchurl,
}: let
  mkHelmChart = import ../lib/helm.nix;
in
  mkHelmChart {
    inherit stdenv;
    name = "cilium";
    version = "v1.18.1";
    src = fetchurl {
      url = "https://github.com/cilium/charts/raw/master/cilium-1.18.1.tgz";
      hash = "sha256-NqqIK+KjWsafcI9uYuHh+XX/SMVhzgedNa01cYKEryI=";
    };
    patches = [./cilium-1_18_1.patch];
  }
