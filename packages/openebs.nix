{
  stdenv,
  fetchurl,
}: let
  mkHelmChart = import ../lib/helm.nix;
in
  mkHelmChart {
    inherit stdenv;
    name = "openebs";
    version = "3.9.0";
    src = fetchurl {
      url = "https://github.com/openebs/charts/releases/download/openebs-3.9.0/openebs-3.9.0.tgz";
      hash = "sha256-aH++jg91zcXECUvRhJOG0/zZk5m5ZnMmeeFlFLV+Ou8=";
    };
  }
