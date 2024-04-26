{
  stdenv,
  fetchurl,
}: let
  mkHelmChart = import ../lib/helm.nix;
in
  mkHelmChart {
    inherit stdenv;
    name = "cilium";
    version = "v1.15.4";
    src = fetchurl {
      url = "https://github.com/cilium/charts/raw/master/cilium-1.15.4.tgz";
      hash = "sha256-eA9tOv7JvqhWz9XK/vWg53ykOUBt1ZlbpD10XMdzGDg=";
    };
    # Very slightly patched cilium chart with an ability to override
    # /lib/modules bind mount.
    patches = [./cilium-1_15_4.patch];
  }
