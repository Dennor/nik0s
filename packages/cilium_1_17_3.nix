{
  stdenv,
  fetchurl,
}: let
  mkHelmChart = import ../lib/helm.nix;
in
  mkHelmChart {
    inherit stdenv;
    name = "cilium";
    version = "v1.17.3";
    src = fetchurl {
      url = "https://github.com/cilium/charts/raw/master/cilium-1.17.3.tgz";
      hash = "sha256-XJIoj90a1dayjCtoA7fuzOej1fWwuS6YLWEjOC+w9Yg=";
    };
    # Very slightly patched cilium chart with an ability to override
    # /lib/modules bind mount.
    # patches = [./cilium-1_17_3.patch];
  }
