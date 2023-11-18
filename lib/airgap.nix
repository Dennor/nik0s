{
  stdenv,
  dockerTools,
  images,
  name,
}: let
  srcs = builtins.map (img: dockerTools.pullImage img) images;
in
  stdenv.mkDerivation {
    inherit srcs name;
    dontUnpack = true;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out
      cp ${builtins.concatStringsSep " " srcs} $out
    '';
  }
