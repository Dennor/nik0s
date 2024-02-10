{
  stdenv,
  fetchurl,
}: let
  mkHelmChart = import ../lib/helm.nix;
in
  mkHelmChart {
    inherit stdenv;
    name = "cilium";
    version = "v1.15.0";
    src = fetchurl {
      url = "https://github.com/cilium/charts/raw/master/cilium-1.15.0.tgz";
      hash = "sha256-70TCMznmLfeZTqsNqVb5mbZyidnzbvyybO/VWJGXXao=";
    };
    # Very slightly patched cilium chart with an ability to override
    # /lib/modules bind mount.
    patches = [./cilium-1_15_0.patch];
  }
