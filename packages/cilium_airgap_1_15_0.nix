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
        imageDigest = "sha256:9cfd6a0a3a964780e73a11159f93cc363e616f7d9783608f62af6cfdf3759619";
        sha256 = "1aapgckd13gk8madbc28sxrpwjnqjrb6yjym3yrq2fa9s4y26034";
        finalImageName = "quay.io/cilium/cilium";
        finalImageTag = "v1.15.0";
      }
      {
        imageName = "quay.io/cilium/certgen";
        imageDigest = "sha256:89a0847753686444daabde9474b48340993bd19c7bea66a46e45b2974b82041f";
        sha256 = "0r83yb0jwb6450v3vy3ddnjqpa4337sc51win624d0rfqh19gw1k";
        finalImageName = "quay.io/cilium/certgen";
        finalImageTag = "v0.1.9";
      }
      {
        imageName = "quay.io/cilium/hubble-relay";
        imageDigest = "sha256:45b3ea70b73aee01644f800b8f6138c36446bfb130d2b88b0f75775ebe6a9ab6";
        sha256 = "16bz110r4bh9bfg9c5m0fryvw2lwi4ak4brm0lajf7gd2fncw3yl";
        finalImageName = "quay.io/cilium/hubble-relay";
        finalImageTag = "v1.15.0";
      }
      {
        imageName = "quay.io/cilium/hubble-ui-backend";
        imageDigest = "sha256:1cd84251cec46e20f9e839ee0afba9b51c8de59d35681234f701d7f42062f138";
        sha256 = "0502zdi9cpl4a382a3mnqc53iz13z6c9nl94lhiwi5vv4s717dcm";
        finalImageName = "quay.io/cilium/hubble-ui-backend";
        finalImageTag = "v0.12.3";
      }
      {
        imageName = "quay.io/cilium/hubble-ui";
        imageDigest = "sha256:e6b825302fc1e406b1305363fe0bcd1fdf95730b32c2b99a2b36dfa37bdaeec2";
        sha256 = "1r6w8zy0nqs6dfd64mfraqnsfh7438ql9ivmhyyd4gfvqzfvy0ww";
        finalImageName = "quay.io/cilium/hubble-ui";
        finalImageTag = "v0.12.3";
      }
      {
        imageName = "quay.io/cilium/cilium-envoy";
        imageDigest = "sha256:bf37c46d3d6bd5f51ff11d09de81671ced070e27912e080083c58a6d3fbb740f";
        sha256 = "0gshwj6f2j7nvfmljkjd3x57n2d0jc2czqyqxzxz8f1yl6inq7ba";
        finalImageName = "quay.io/cilium/cilium-envoy";
        finalImageTag = "v1.27.2-13f6142b9c02268b10d547c8b093ef16724538e3";
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
        imageDigest = "sha256:949ec05e962d370437deb6ca4b27b05b8e9c8077bfa6a5b9b4d80d08a26d4fee";
        sha256 = "0s10jj493l495a4q6zg88xh29czddbgm368168z2h6c4hbjnn2zm";
        finalImageName = "quay.io/cilium/operator";
        finalImageTag = "v1.15.0";
      }
      {
        imageName = "quay.io/cilium/operator-generic";
        imageDigest = "sha256:e26ecd316e742e4c8aa1e302ba8b577c2d37d114583d6c4cdd2b638493546a79";
        sha256 = "0nz6ggn5adh3y62yh1dh1x4asppy3sfhanq3csl0sw8sys7l8hgr";
        finalImageName = "quay.io/cilium/operator-generic";
        finalImageTag = "v1.15.0";
      }
      {
        imageName = "quay.io/cilium/startup-script";
        imageDigest = "sha256:e1d442546e868db1a3289166c14011e0dbd32115b338b963e56f830972bc22a2";
        sha256 = "0vcqbl1jw1b977b3kg7wpnh8lm501kqspjxa2fnkgsi4rq7kwwzy";
        finalImageName = "quay.io/cilium/startup-script";
        finalImageTag = "62093c5c233ea914bfa26a10ba41f8780d9b737f";
      }
      {
        imageName = "quay.io/cilium/clustermesh-apiserver";
        imageDigest = "sha256:43feb49dfbaa82388dc653ce12c7626ce40ae375e9853d71b9f5cff0ce61d54a";
        sha256 = "0zdxc06c5h9q7xcl1g327xbcnsfkyf8h7lk1l5r0x8zlcfw7afkf";
        finalImageName = "quay.io/cilium/clustermesh-apiserver";
        finalImageTag = "v1.15.0";
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
      {
        imageName = "docker.io/library/busybox";
        imageDigest = "sha256:6d9ac9237a84afe1516540f40a0fafdc86859b2141954b4d643af7066d598b74";
        sha256 = "0p16mdxrlm8f9y9zwzhwbnr4rpwfqwyk6jfdgkhqdp7sq4v32f6l";
        finalImageName = "docker.io/library/busybox";
        finalImageTag = "1.36.1";
      }
    ];
    name = "cilium_airgap_1_15_0";
  }
