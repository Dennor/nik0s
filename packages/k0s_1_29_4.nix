{
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  name = "k0s";
  version = "v1.29.4+k0s.0";
  src = fetchurl {
    url = "https://github.com/k0sproject/k0s/releases/download/${version}/k0s-${version}-amd64";
    hash = "sha256-YSMy0h599XDq2igDqAUXD7DWpRg5bl5aBAjk0WwK/kQ=";
  };
  phases = ["installPhase"];
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/bin
    cp ${src} $out/bin/k0s
    chmod +x $out/bin/k0s
  '';
}
