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
        imageDigest = "sha256:b760a4831f5aab71c711f7537a107b751d0d0ce90dd32d8b358df3c5da385426";
        sha256 = "061v9nn5wg52lidk6h99awgh0r280lvgy7ld90irbkyz6p44nv06";
        finalImageName = "quay.io/cilium/cilium";
        finalImageTag = "v1.15.4";
      }
      {
        imageName = "quay.io/cilium/certgen";
        imageDigest = "sha256:5586de5019abc104637a9818a626956cd9b1e827327b958186ec412ae3d5dea6";
        sha256 = "1m05bc88yfd96gax8s4nkr2cpcsgm31pnkwcy7xcfian6zjkq3bv";
        finalImageName = "quay.io/cilium/certgen";
        finalImageTag = "v0.1.11";
      }
      {
        imageName = "quay.io/cilium/hubble-relay";
        imageDigest = "sha256:03ad857feaf52f1b4774c29614f42a50b370680eb7d0bfbc1ae065df84b1070a";
        sha256 = "06wwdvcsin5cqn32fpcsq1kip8q73m5acq7a8s145qw055mnm6xn";
        finalImageName = "quay.io/cilium/hubble-relay";
        finalImageTag = "v1.15.4";
      }
      {
        imageName = "quay.io/cilium/hubble-ui-backend";
        imageDigest = "sha256:1e7657d997c5a48253bb8dc91ecee75b63018d16ff5e5797e5af367336bc8803";
        sha256 = "0yyg3wnr1p2fg425kn9habmgl2cmvan13yhwgmp6hpq2ax16rgzr";
        finalImageName = "quay.io/cilium/hubble-ui-backend";
        finalImageTag = "v0.13.0";
      }
      {
        imageName = "quay.io/cilium/hubble-ui";
        imageDigest = "sha256:7d663dc16538dd6e29061abd1047013a645e6e69c115e008bee9ea9fef9a6666";
        sha256 = "0jl4hg47wc82vx8jphnhkvk9vc2bfpa0pqhmqqfakyynmfrxxasz";
        finalImageName = "quay.io/cilium/hubble-ui";
        finalImageTag = "v0.13.0";
      }
      {
        imageName = "quay.io/cilium/cilium-envoy";
        imageDigest = "sha256:d52f476c29a97c8b250fdbfbb8472191a268916f6a8503671d0da61e323b02cc";
        sha256 = "116qykn7dnh3l54llnqi3nd8llld4dc4g98da8m79x3rxv2cx354";
        finalImageName = "quay.io/cilium/cilium-envoy";
        finalImageTag = "v1.27.4-21905253931655328edaacf3cd16aeda73bbea2f";
      }
      {
        imageName = "quay.io/cilium/cilium-etcd-operator";
        imageDigest = "sha256:04b8327f7f992693c2cb483b999041ed8f92efc8e14f2a5f3ab95574a65ea2dc";
        sha256 = "1084znjn4wswnd6ikzkkbj17sgdpsydji4rvzp9gbb2x66m4av3s";
        finalImageName = "quay.io/cilium/cilium-etcd-operator";
        finalImageTag = "v2.0.7";
      }
      {
        imageName = "quay.io/cilium/operator";
        imageDigest = "sha256:4e42b867d816808f10b38f555d6ae50065ebdc6ddc4549635f2fe50ed6dc8d7f";
        sha256 = "1ksy4fnkf3m61qkkr1vlk12nx3ayvxdrscax4k96li9pbnh4y5wb";
        finalImageName = "quay.io/cilium/operator";
        finalImageTag = "v1.15.4";
      }
      {
        imageName = "quay.io/cilium/operator-generic";
        imageDigest = "sha256:404890a83cca3f28829eb7e54c1564bb6904708cdb7be04ebe69c2b60f164e9a";
        sha256 = "1qqdka0bgm7ky76f0afvp3ng79bn41lki7bnnz7a2gh0w0b72ryz";
        finalImageName = "quay.io/cilium/operator-generic";
        finalImageTag = "v1.15.4";
      }
      {
        imageName = "quay.io/cilium/startup-script";
        imageDigest = "sha256:e1d442546e868db1a3289166c14011e0dbd32115b338b963e56f830972bc22a2";
        sha256 = "0vcqbl1jw1b977b3kg7wpnh8lm501kqspjxa2fnkgsi4rq7kwwzy";
        finalImageName = "quay.io/cilium/startup-script";
        finalImageTag = "62093c5c233ea914bfa26a10ba41f8780d9b737f";
      }
      {
        imageName = "quay.io/cilium/cilium";
        imageDigest = "sha256:b760a4831f5aab71c711f7537a107b751d0d0ce90dd32d8b358df3c5da385426";
        sha256 = "061v9nn5wg52lidk6h99awgh0r280lvgy7ld90irbkyz6p44nv06";
        finalImageName = "quay.io/cilium/cilium";
        finalImageTag = "v1.15.4";
      }
      {
        imageName = "quay.io/cilium/clustermesh-apiserver";
        imageDigest = "sha256:3fadf85d2aa0ecec09152e7e2d57648bda7e35bdc161b25ab54066dd4c3b299c";
        sha256 = "10gkk3q9z62qjfw0qzlpjpaq80dwswg5g4xzlhv57vsnd54zpdvw";
        finalImageName = "quay.io/cilium/clustermesh-apiserver";
        finalImageTag = "v1.15.4";
      }
      {
        imageName = "docker.io/library/busybox";
        imageDigest = "sha256:c3839dd800b9eb7603340509769c43e146a74c63dca3045a8e7dc8ee07e53966";
        sha256 = "07lkyq8vw2sdqp95p7515n052bvm3ri0ic24phwd1sz3knqwp1yi";
        finalImageName = "docker.io/library/busybox";
        finalImageTag = "1.36.1";
      }
      {
        imageName = "ghcr.io/spiffe/spire-agent";
        imageDigest = "sha256:99405637647968245ff9fe215f8bd2bd0ea9807be9725f8bf19fe1b21471e52b";
        sha256 = "1ygaib50iacfhp2d2mzh4g20ljrrmavvxbx82yxfjn5pchnl7l1m";
        finalImageName = "ghcr.io/spiffe/spire-agent";
        finalImageTag = "1.8.5";
      }
      {
        imageName = "ghcr.io/spiffe/spire-server";
        imageDigest = "sha256:28269265882048dcf0fed32fe47663cd98613727210b8d1a55618826f9bf5428";
        sha256 = "1h46bgb1bamzh1cbxp2a3ynpqahgsphspz965125klsd3awdm2yh";
        finalImageName = "ghcr.io/spiffe/spire-server";
        finalImageTag = "1.8.5";
      }
    ];
    name = "cilium_airgap_1_15_4";
  }
