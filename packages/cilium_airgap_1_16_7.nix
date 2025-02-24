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
        imageDigest = "sha256:7a5342b7662db8de99e045a2b47b889c5701b8dde0ce5ae3f1577bf57a15ed40";
        sha256 = "0is64qyxfvj85mf74is314dan2bb9h3q643khy2bisc045xib3nh";
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
      {
        imageName = "quay.io/cilium/certgen";
        imageDigest = "sha256:169d93fd8f2f9009db3b9d5ccd37c2b753d0989e1e7cd8fe79f9160c459eef4f";
        sha256 = "053cdkxjwkylkdbcaz1fi4n3y7wv2zcdjvi6s5ki4p2jizqzww66";
        finalImageName = "quay.io/cilium/certgen";
        finalImageTag = "v0.2.0";
      }
      {
        imageName = "quay.io/cilium/cilium-envoy";
        imageDigest = "sha256:fc708bd36973d306412b2e50c924cd8333de67e0167802c9b48506f9d772f521";
        sha256 = "1z9bcwfpi6km5iacjgc0n843bd841pv906m15n03xa65iydpihp2";
        finalImageName = "quay.io/cilium/cilium-envoy";
        finalImageTag = "v1.31.5-1739264036-958bef243c6c66fcfd73ca319f2eb49fff1eb2ae";
      }
      {
        imageName = "quay.io/cilium/cilium";
        imageDigest = "sha256:294d2432507fed393b26e9fbfacb25c2e37095578cb34dabac7312b66ed0782e";
        sha256 = "0irjx9cgbwp9ykqwh1mkzb8zcc7g88ph9gql5lya0p9zm49x3blr";
        finalImageName = "quay.io/cilium/cilium";
        finalImageTag = "v1.16.7";
      }
      {
        imageName = "quay.io/cilium/clustermesh-apiserver";
        imageDigest = "sha256:8e7eda5b194d45c3b1607f5bf31cbb3fecd0f1cf85ce32b41f93b2bd832bf02f";
        sha256 = "1r97p818490v9gkjcyzqa3gfkkhivgd8k8n88q1g31h4yx6gbshn";
        finalImageName = "quay.io/cilium/clustermesh-apiserver";
        finalImageTag = "v1.16.7";
      }
      {
        imageName = "quay.io/cilium/hubble-relay";
        imageDigest = "sha256:8f408ed921cd534394aa1c57b313741cec6aec03a14ea243b2173cbf2c88c91e";
        sha256 = "1jl8zmmn0sfaqyg885yyvgkn8mcjwkkh6189mpfqy073djq66n7k";
        finalImageName = "quay.io/cilium/hubble-relay";
        finalImageTag = "v1.16.7";
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
        imageName = "quay.io/cilium/operator-generic";
        imageDigest = "sha256:25a41ac50bcebfb780ed2970e55a5ba1a5f26996850ed5a694dc69b312e0b5a0";
        sha256 = "0y5dqk6blyf0szjrhp0riw8jxvw4diciskgl7gdbsv80z7hldg84";
        finalImageName = "quay.io/cilium/operator-generic";
        finalImageTag = "v1.16.7";
      }
      {
        imageName = "quay.io/cilium/startup-script";
        imageDigest = "sha256:8d7b41c4ca45860254b3c19e20210462ef89479bb6331d6760c4e609d651b29c";
        sha256 = "166q4rpd67hbxx93m6859gvw5ffi8pnd86qjl9ih4a1gaam2afj9";
        finalImageName = "quay.io/cilium/startup-script";
        finalImageTag = "c54c7edeab7fde4da68e59acd319ab24af242c3f";
      }
    ];
    name = "cilium_airgap_1_16_7";
  }
