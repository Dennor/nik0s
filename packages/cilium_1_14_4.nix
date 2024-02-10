{
  stdenv,
  fetchurl,
}: let
  mkHelmChart = import ../lib/helm.nix;
in
  mkHelmChart {
    inherit stdenv;
    name = "cilium";
    version = "v1.14.4";
    src = fetchurl {
      url = "https://github.com/cilium/charts/raw/master/cilium-1.14.4.tgz";
      hash = "sha256-gw7U4jMke7GVYRIiJPqtAvivWZWhHcwpflTCs4iIhWc=";
    };
    # Very slightly patched cilium chart with an ability to override
    # /lib/modules bind mount.
    patches = [./cilium-1_14_4.patch];
  }
