{
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  name = "k0s";
  version = "v1.29.1+k0s.1";
  src = fetchurl {
    url = "https://github.com/k0sproject/k0s/releases/download/${version}/k0s-${version}-amd64";
    hash = "sha256-BL2X05nD1HtXcmNQXDC7kw7suP2mnl1Hq61brOf4KsY=";
  };
  phases = ["installPhase"];
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/bin
    cp ${src} $out/bin/k0s
    chmod +x $out/bin/k0s
  '';
}
