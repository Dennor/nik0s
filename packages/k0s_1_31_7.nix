{
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  name = "k0s";
  version = "v1.31.7+k0s.0";
  src = fetchurl {
    url = "https://github.com/k0sproject/k0s/releases/download/${version}/k0s-${version}-amd64";
    hash = "sha256-l6z4IWZ2r4KWmp/7NfxaK5sxx2qx48MDEab1c7ua9eI=";
  };
  phases = ["installPhase"];
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/bin
    cp ${src} $out/bin/k0s
    chmod +x $out/bin/k0s
  '';
}
