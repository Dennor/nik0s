let
  mkHelmChart = {
    src,
    name,
    version,
    patches ? [],
    stdenv,
  }:
    stdenv.mkDerivation {
      inherit src name version patches;
      installPhase = ''
        mkdir -p $out
        cp -r $(ls -A) $out
      '';
    };
in
  mkHelmChart
