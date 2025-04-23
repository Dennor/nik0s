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
        imageDigest = "sha256:37f7b378a29ceb4c551b1b5582e27747b855bbfaa73fa11914fe0df028dc581f";
        sha256 = "1psfy671zxjwayyjhv7pm5p0v26hq19096ml29bxpc3051mn8hnv";
        finalImageName = "docker.io/library/busybox";
        finalImageTag = "1.37.0";
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
        imageDigest = "sha256:ab6b1928e9c5f424f6b0f51c68065b9fd85e2f8d3e5f21fbd1a3cb27e6fb9321";
        sha256 = "10nzk277zxp91qlhfqqfx0nz7dmqmsq3xdggclsf8pmkarb75b04";
        finalImageName = "quay.io/cilium/certgen";
        finalImageTag = "v0.2.1";
      }
      {
        imageName = "quay.io/cilium/cilium-envoy";
        imageDigest = "sha256:a01cadf7974409b5c5c92ace3d6afa298408468ca24cab1cb413c04f89d3d1f9";
        sha256 = "1xw47k92myc1s8xq529hw6kfgvsif68pwvbdn1kfdkgxjk4054qk";
        finalImageName = "quay.io/cilium/cilium-envoy";
        finalImageTag = "v1.32.5-1744305768-f9ddca7dcd91f7ca25a505560e655c47d3dec2cf";
      }
      {
        imageName = "quay.io/cilium/cilium";
        imageDigest = "sha256:1782794aeac951af139315c10eff34050aa7579c12827ee9ec376bb719b82873";
        sha256 = "1dsycr2sr72cq9qc2gjbn3l70qhywxcxv2205ipgy54mmvg14cpy";
        finalImageName = "quay.io/cilium/cilium";
        finalImageTag = "v1.17.3";
      }
      {
        imageName = "quay.io/cilium/clustermesh-apiserver";
        imageDigest = "sha256:98d5feaf67dd9b5d8d219ff5990de10539566eedc5412bcf52df75920896ad42";
        sha256 = "1wg1i91ybd976534k62mmhwivxqa9d0jny1zp2a5rmhhlamgxds8";
        finalImageName = "quay.io/cilium/clustermesh-apiserver";
        finalImageTag = "v1.17.3";
      }
      {
        imageName = "quay.io/cilium/hubble-relay";
        imageDigest = "sha256:f8674b5139111ac828a8818da7f2d344b4a5bfbaeb122c5dc9abed3e74000c55";
        sha256 = "0yn3kf8agr9yd68qk1q22d87k9qlp5i8q2gvmlk8hy77k2b3pacp";
        finalImageName = "quay.io/cilium/hubble-relay";
        finalImageTag = "v1.17.3";
      }
      {
        imageName = "quay.io/cilium/hubble-ui-backend";
        imageDigest = "sha256:a034b7e98e6ea796ed26df8f4e71f83fc16465a19d166eff67a03b822c0bfa15";
        sha256 = "1d69ch8s6x50d5j76jr4n19779b0f3xlfhlg26l6x7y2pfcgfjsx";
        finalImageName = "quay.io/cilium/hubble-ui-backend";
        finalImageTag = "v0.13.2";
      }
      {
        imageName = "quay.io/cilium/hubble-ui";
        imageDigest = "sha256:9e37c1296b802830834cc87342a9182ccbb71ffebb711971e849221bd9d59392";
        sha256 = "19pjdgz67p9f61ygqjw84alp7g74y1f876vhs720avb203ymr7r8";
        finalImageName = "quay.io/cilium/hubble-ui";
        finalImageTag = "v0.13.2";
      }
      {
        imageName = "quay.io/cilium/operator-generic";
        imageDigest = "sha256:8bd38d0e97a955b2d725929d60df09d712fb62b60b930551a29abac2dd92e597";
        sha256 = "12lr5nabd8r2x0kpgyikv54pcf2g1x6xx1rimvipcf4bndaw43wq";
        finalImageName = "quay.io/cilium/operator-generic";
        finalImageTag = "v1.17.3";
      }
      {
        imageName = "quay.io/cilium/startup-script";
        imageDigest = "sha256:8d7b41c4ca45860254b3c19e20210462ef89479bb6331d6760c4e609d651b29c";
        sha256 = "166q4rpd67hbxx93m6859gvw5ffi8pnd86qjl9ih4a1gaam2afj9";
        finalImageName = "quay.io/cilium/startup-script";
        finalImageTag = "c54c7edeab7fde4da68e59acd319ab24af242c3f";
      }
    ];
    name = "cilium_airgap_1_17_3";
  }
