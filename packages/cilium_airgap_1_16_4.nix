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
        imageName = "quay.io/cilium/cilium";
        imageDigest = "sha256:d55ec38938854133e06739b1af237932b9c4dd4e75e9b7b2ca3acc72540a44bf";
        sha256 = "0sl1i9xhlkqwjl27ni806f028xffhplfc22f8pjc3zsn4pszpdag";
        finalImageName = "quay.io/cilium/cilium";
        finalImageTag = "v1.16.4";
      }
      {
        imageName = "quay.io/cilium/certgen";
        imageDigest = "sha256:169d93fd8f2f9009db3b9d5ccd37c2b753d0989e1e7cd8fe79f9160c459eef4f";
        sha256 = "053cdkxjwkylkdbcaz1fi4n3y7wv2zcdjvi6s5ki4p2jizqzww66";
        finalImageName = "quay.io/cilium/certgen";
        finalImageTag = "v0.2.0";
      }
      {
        imageName = "quay.io/cilium/hubble-relay";
        imageDigest = "sha256:fb2c7d127a1c809f6ba23c05973f3dd00f6b6a48e4aee2da95db925a4f0351d2";
        sha256 = "1vn3qp1yqrvnkx4ka25l36gwpy023dyqpxxh4ih2i27sb7pahz4b";
        finalImageName = "quay.io/cilium/hubble-relay";
        finalImageTag = "v1.16.4";
      }
      {
        imageName = "quay.io/cilium/hubble-ui-backend";
        imageDigest = "sha256:0e0eed917653441fded4e7cdb096b7be6a3bddded5a2dd10812a27b1fc6ed95b";
        sha256 = "0yynwffa26za8vmr036m79ccn47b5xkx4x31ibkyz5crs79dsz6x";
        finalImageName = "quay.io/cilium/hubble-ui-backend";
        finalImageTag = "v0.13.1";
      }
      {
        imageName = "quay.io/cilium/hubble-ui";
        imageDigest = "sha256:e2e9313eb7caf64b0061d9da0efbdad59c6c461f6ca1752768942bfeda0796c6";
        sha256 = "0zw9mds0gf2hq8jmr736f92a2v1q5svc0vib6qpxcdaqywk48gzx";
        finalImageName = "quay.io/cilium/hubble-ui";
        finalImageTag = "v0.13.1";
      }
      {
        imageName = "quay.io/cilium/cilium-envoy";
        imageDigest = "sha256:0287b36f70cfbdf54f894160082f4f94d1ee1fb10389f3a95baa6c8e448586ed";
        sha256 = "094f9raiaf979i7g1sj99n7yhbwyagr693sj61aa6i6cmlixj3qm";
        finalImageName = "quay.io/cilium/cilium-envoy";
        finalImageTag = "v1.30.7-1731393961-97edc2815e2c6a174d3d12e71731d54f5d32ea16";
      }
      {
        imageName = "quay.io/cilium/operator";
        imageDigest = "sha256:c77643984bc17e1a93d83b58fa976d7e72ad1485ce722257594f8596899fdfff";
        sha256 = "09x1i76q3zvz5y5xdm21py7mjy5r6q1sykh1cq45prky2igrjqix";
        finalImageName = "quay.io/cilium/operator";
        finalImageTag = "v1.16.4";
      }
      {
        imageName = "quay.io/cilium/operator-generic";
        imageDigest = "sha256:c55a7cbe19fe0b6b28903a085334edb586a3201add9db56d2122c8485f7a51c5";
        sha256 = "1h3h9szqddn8vlkfbqib02m1l3qq4iidl5qrf9bi3gr7ib624fpq";
        finalImageName = "quay.io/cilium/operator-generic";
        finalImageTag = "v1.16.4";
      }
      {
        imageName = "quay.io/cilium/startup-script";
        imageDigest = "sha256:8d7b41c4ca45860254b3c19e20210462ef89479bb6331d6760c4e609d651b29c";
        sha256 = "166q4rpd67hbxx93m6859gvw5ffi8pnd86qjl9ih4a1gaam2afj9";
        finalImageName = "quay.io/cilium/startup-script";
        finalImageTag = "c54c7edeab7fde4da68e59acd319ab24af242c3f";
      }
      {
        imageName = "quay.io/cilium/clustermesh-apiserver";
        imageDigest = "sha256:b41ba9c1b32e31308e17287a24a5b8e8ed0931f70d168087001c9679bc6c5dd2";
        sha256 = "0vk3c1sy6aml0542wid0gd75xk260gw8qamrvl66ii7dih69qdr6";
        finalImageName = "quay.io/cilium/clustermesh-apiserver";
        finalImageTag = "v1.16.4";
      }
      {
        imageName = "docker.io/library/busybox";
        imageDigest = "sha256:d75b758a4fea99ffff4db799e16f853bbde8643671b5b72464a8ba94cbe3dbe3";
        sha256 = "038l61i57m2h7i18wrcfk5szyna7bwvph5xfpyhs2zaj96ciiwv0";
        finalImageName = "docker.io/library/busybox";
        finalImageTag = "1.36.1";
      }
      {
        imageName = "ghcr.io/spiffe/spire-agent";
        imageDigest = "sha256:5106ac601272a88684db14daf7f54b9a45f31f77bb16a906bd5e87756ee7b97c";
        sha256 = "13pqgqwn2srhwdhsbnhg12cpb0g403n78b42h3dr7vx9bk24d7hd";
        finalImageName = "ghcr.io/spiffe/spire-agent";
        finalImageTag = "1.9.6";
      }
      {
        imageName = "ghcr.io/spiffe/spire-server";
        imageDigest = "sha256:59a0b92b39773515e25e68a46c40d3b931b9c1860bc445a79ceb45a805cab8b4";
        sha256 = "1myy2ik5q26kyn5ig6xmzljxqmc0gibh1xqlgrphccjxzzddf0qz";
        finalImageName = "ghcr.io/spiffe/spire-server";
        finalImageTag = "1.9.6";
      }
    ];
    name = "cilium_airgap_1_16_4";
  }
