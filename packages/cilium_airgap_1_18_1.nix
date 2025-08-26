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
        imageDigest = "sha256:163970884fba18860cac93655dc32b6af85a5dcf2ebb7e3e119a10888eff8fcd";
        sha256 = "sha256-Sec7Ht9t3Rd9yPrEYFOdlBS/SPGzfCcTZ7WNjsPB8xQ=";
        finalImageName = "ghcr.io/spiffe/spire-agent";
        finalImageTag = "1.12.4";
      }
      {
        imageName = "ghcr.io/spiffe/spire-server";
        imageDigest = "sha256:34147f27066ab2be5cc10ca1d4bfd361144196467155d46c45f3519f41596e49";
        sha256 = "sha256-N2Fqn5Ih2Y0OZLK9EpoAy2yqU5axcKbLeu1Ls3Bv47c=";
        finalImageName = "ghcr.io/spiffe/spire-server";
        finalImageTag = "1.12.4";
      }
      {
        imageName = "quay.io/cilium/certgen";
        imageDigest = "sha256:de7b97b1d19a34b674d0c4bc1da4db999f04ae355923a9a994ac3a81e1a1b5ff";
        sha256 = "sha256-tk+QoBGiuAWZQwA68vHoBQgN4KTy3Zacv7HhCFxMZh0=";
        finalImageName = "quay.io/cilium/certgen";
        finalImageTag = "v0.2.4";
      }
      {
        imageName = "quay.io/cilium/cilium-envoy";
        imageDigest = "sha256:247e908700012f7ef56f75908f8c965215c26a27762f296068645eb55450bda2";
        sha256 = "sha256-U3R+YQgYR8Ywn8QUCWg4UuWeNaTInFAQZVbN+8xoskw=";
        finalImageName = "quay.io/cilium/cilium-envoy";
        finalImageTag = "v1.34.4-1754895458-68cffdfa568b6b226d70a7ef81fc65dda3b890bf";
      }
      {
        imageName = "quay.io/cilium/cilium";
        imageDigest = "sha256:65ab17c052d8758b2ad157ce766285e04173722df59bdee1ea6d5fda7149f0e9";
        sha256 = "sha256-sfuXc2QTeZXRbPBN1tMOMXF1IlvrNfdqpm866YDEqbE=";
        finalImageName = "quay.io/cilium/cilium";
        finalImageTag = "v1.18.1";
      }
      {
        imageName = "quay.io/cilium/clustermesh-apiserver";
        imageDigest = "sha256:87ab85f33dc7e895ed6257564bf1a255d12399d9e8a075a8fc400910ff94cbeb";
        sha256 = "sha256-vEzRfr5LHpSZR2Zhtn9VbOldBhZ1KXMymkmK3FSTV/w=";
        finalImageName = "quay.io/cilium/clustermesh-apiserver";
        finalImageTag = "v1.18.1";
      }
      {
        imageName = "quay.io/cilium/hubble-relay";
        imageDigest = "sha256:7e2fd4877387c7e112689db7c2b153a4d5c77d125b8d50d472dbe81fc1b139b0";
        sha256 = "sha256-WfsCFM7EEvPHdv0r45xzZXu5JCnJg9DV+Ew7Evlg0jg=";
        finalImageName = "quay.io/cilium/hubble-relay";
        finalImageTag = "v1.18.1";
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
        imageDigest = "sha256:97f4553afa443465bdfbc1cc4927c93f16ac5d78e4dd2706736e7395382201bc";
        sha256 = "sha256-qFc9j5hSS3d/pfL7a9K+b8z6sf+U7BHA+aEXvyoiL/Q=";
        finalImageName = "quay.io/cilium/operator-generic";
        finalImageTag = "v1.18.1";
      }
      {
        imageName = "quay.io/cilium/startup-script";
        imageDigest = "sha256:8d7b41c4ca45860254b3c19e20210462ef89479bb6331d6760c4e609d651b29c";
        sha256 = "sha256-STolqlIvKAJjohIb1OxF0bnC90sFmTpS7wse024m2Jg=";
        finalImageName = "quay.io/cilium/startup-script";
        finalImageTag = "c54c7edeab7fde4da68e59acd319ab24af242c3f";
      }
    ];
    name = "cilium_airgap_1_18_1";
  }
