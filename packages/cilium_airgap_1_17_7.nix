{
  stdenv,
  dockerTools,
}: let
  mkBundle = import ../lib/airgap.nix;
in
  mkBundle {
    inherit stdenv dockerTools;
    images = [
      {
        imageName = "docker.io/library/busybox";
        imageDigest = "sha256:ab33eacc8251e3807b85bb6dba570e4698c3998eca6f0fc2ccb60575a563ea74";
        sha256 = "sha256-O+GkFMTRxfRWI6qcvdYMosRa7U/ZM5iaQsxBOiL5OIk=";
        finalImageName = "docker.io/library/busybox";
        finalImageTag = "1.37.0";
      }
      {
        imageName = "ghcr.io/spiffe/spire-agent";
        imageDigest = "sha256:5106ac601272a88684db14daf7f54b9a45f31f77bb16a906bd5e87756ee7b97c";
        sha256 = "sha256-DZ5GxFyp75PbgIIsdOwA5IF1mQgP2qVh4zBrYTl++I4=";
        finalImageName = "ghcr.io/spiffe/spire-agent";
        finalImageTag = "1.9.6";
      }
      {
        imageName = "ghcr.io/spiffe/spire-server";
        imageDigest = "sha256:59a0b92b39773515e25e68a46c40d3b931b9c1860bc445a79ceb45a805cab8b4";
        sha256 = "sha256-HwPX2v9dMgZvfhT3AFd8gFXcJf21mxeL9dMIXGYU3tc=";
        finalImageName = "ghcr.io/spiffe/spire-server";
        finalImageTag = "1.9.6";
      }
      {
        imageName = "quay.io/cilium/certgen";
        imageDigest = "sha256:ab6b1928e9c5f424f6b0f51c68065b9fd85e2f8d3e5f21fbd1a3cb27e6fb9321";
        sha256 = "sha256-BKxyVlazXuQ0Ze+1PrCuuLbzLegOYwcpDun2f46Y34I=";
        finalImageName = "quay.io/cilium/certgen";
        finalImageTag = "v0.2.1";
      }
      {
        imageName = "quay.io/cilium/cilium-envoy";
        imageDigest = "sha256:184240a145d656ab111cd2312deb6c46b94bc2c9d159c4811cf708b0848f8948";
        sha256 = "sha256-o5YZfeMSdx+P27TO9bmf54s+s/Syjrs/pVaBmNjfbwA=";
        finalImageName = "quay.io/cilium/cilium-envoy";
        finalImageTag = "v1.33.6-1754542786-4d9638583910acb3e34d77e436cbd745d910a437";
      }
      {
        imageName = "quay.io/cilium/cilium";
        imageDigest = "sha256:b22440f49c61195171aca585c7a57c6a8867271e43a5abc38f2a2f561436ff86";
        sha256 = "sha256-8jEiyaWbq6vDHbQZgSpc+xsTcjG28KKMHa6JINQ5EPc=";
        finalImageName = "quay.io/cilium/cilium";
        finalImageTag = "v1.17.7";
      }
      {
        imageName = "quay.io/cilium/clustermesh-apiserver";
        imageDigest = "sha256:2852feca0d0d936ed0333cd64859f3c5ece2db582ba5fed848f57aff786be4a6";
        sha256 = "sha256-yWq8p8fDA+G0eeUCb60k3DP3kiVWlhREtiA6OnyUe8o=";
        finalImageName = "quay.io/cilium/clustermesh-apiserver";
        finalImageTag = "v1.17.7";
      }
      {
        imageName = "quay.io/cilium/hubble-relay";
        imageDigest = "sha256:9394312ce65c3c253a8c26a6c292f58736e75c78d1446ecfcd244f1418bebe77";
        sha256 = "sha256-FsyRverqqE7IYwO8gzXruB+28JFEbPu+XOQIzQqHIuI=";
        finalImageName = "quay.io/cilium/hubble-relay";
        finalImageTag = "v1.17.7";
      }
      {
        imageName = "quay.io/cilium/hubble-ui-backend";
        imageDigest = "sha256:a034b7e98e6ea796ed26df8f4e71f83fc16465a19d166eff67a03b822c0bfa15";
        sha256 = "sha256-XUv3mLvCn26oEY9CR/twYKVzUrAkS3NkaaB0oxFkybQ=";
        finalImageName = "quay.io/cilium/hubble-ui-backend";
        finalImageTag = "v0.13.2";
      }
      {
        imageName = "quay.io/cilium/hubble-ui";
        imageDigest = "sha256:9e37c1296b802830834cc87342a9182ccbb71ffebb711971e849221bd9d59392";
        sha256 = "sha256-KJ9c/QBibQXE0XCbg1zw5LxzqSKIS/x8MC7dY/5r8qY=";
        finalImageName = "quay.io/cilium/hubble-ui";
        finalImageTag = "v0.13.2";
      }
      {
        imageName = "quay.io/cilium/operator-generic";
        imageDigest = "sha256:a610be2562d0f5a8945a27df7d5681711263ce92e09947e867fc37fc9ab08788";
        sha256 = "sha256-8NcC8AaIiGBCWf/51ximPk0ftr28gqbWuaH+J0Z5s+g=";
        finalImageName = "quay.io/cilium/operator-generic";
        finalImageTag = "v1.17.7";
      }
      {
        imageName = "quay.io/cilium/startup-script";
        imageDigest = "sha256:8d7b41c4ca45860254b3c19e20210462ef89479bb6331d6760c4e609d651b29c";
        sha256 = "sha256-STolqlIvKAJjohIb1OxF0bnC90sFmTpS7wse024m2Jg=";
        finalImageName = "quay.io/cilium/startup-script";
        finalImageTag = "c54c7edeab7fde4da68e59acd319ab24af242c3f";
      }
    ];
    name = "cilium_airgap_1_17_7";
  }
