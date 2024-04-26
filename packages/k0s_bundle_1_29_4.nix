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
        imageName = "quay.io/k0sproject/calico-cni";
        imageDigest = "sha256:e745caa996dc42056ab1c89329a69db0dae413f7d12b7566eae95cdccb505e8f";
        sha256 = "14s4790f7bvcgydqc6aga8f0xlkld3m7qmpngnjj74g5c52vlsvm";
        finalImageName = "quay.io/k0sproject/calico-cni";
        finalImageTag = "v3.26.1-1";
      }
      {
        imageName = "quay.io/k0sproject/calico-kube-controllers";
        imageDigest = "sha256:621b5ee3116aec2bbe88d487e220764faa4bf0731c793442f9d0e3f3de51ac7b";
        sha256 = "1sd0cq29xxw4dxm2hmfdrpl1j217dbz4p6gwwh1ni5kzwbs42vfb";
        finalImageName = "quay.io/k0sproject/calico-kube-controllers";
        finalImageTag = "v3.26.1-1";
      }
      {
        imageName = "quay.io/k0sproject/calico-node";
        imageDigest = "sha256:de3cc243f97bec22989463c484c2b98940b608460d67afb256bda5013646be9b";
        sha256 = "1rp9qrqxhwyykjcnz49y9bp86iaifcj2p717cxhyb7msl41sg6by";
        finalImageName = "quay.io/k0sproject/calico-node";
        finalImageTag = "v3.26.1-1";
      }
      {
        imageName = "quay.io/k0sproject/coredns";
        imageDigest = "sha256:737a3dff9b04427059609596f20e0178166becb21802cc3c8e75cafe14200c81";
        sha256 = "10mkafbcqgjr4s4xk2gapjisjwzjrj060w9gdcbpqs4qkz3r2iww";
        finalImageName = "quay.io/k0sproject/coredns";
        finalImageTag = "1.11.1";
      }
      {
        imageName = "quay.io/k0sproject/apiserver-network-proxy-agent";
        imageDigest = "sha256:99752affee2737563ad667dd5331742c195132969d735af023e5192dddaa9c41";
        sha256 = "1gjzh5cg0pfl74qj2f566hp8i42l3mnlp4qq2hflra5m327xa2fx";
        finalImageName = "quay.io/k0sproject/apiserver-network-proxy-agent";
        finalImageTag = "v0.1.4";
      }
      {
        imageName = "quay.io/k0sproject/kube-proxy";
        imageDigest = "sha256:c8e0d8b4bc439613a3e3b7508b4cdcdc353fea20d1bcf165b9c532ee4d0d61d6";
        sha256 = "0c4q11qb3cy5rlxjnjl0m4m5sj26xr2qyjpkrfb4k6w3qgl04vzr";
        finalImageName = "quay.io/k0sproject/kube-proxy";
        finalImageTag = "v1.29.4";
      }
      {
        imageName = "quay.io/k0sproject/kube-router";
        imageDigest = "sha256:a637c44f7fbc3cd6207696e8d4b687fcaba41727fba99ca7b95eff0ac16688bb";
        sha256 = "1p7hk11pifbbzg5lqn9vyma89fqq01phfnmk50jngs8sy0alaz16";
        finalImageName = "quay.io/k0sproject/kube-router";
        finalImageTag = "v1.6.1-iptables1.8.9-0";
      }
      {
        imageName = "quay.io/k0sproject/cni-node";
        imageDigest = "sha256:f9ae72f1be998ba3d0a9298d35cbd5577758cc08326406c63fb4804b0664391a";
        sha256 = "002iy6a1dlizrixsns4k747mw56i9dr641ls3q8sxqfdj90zly5a";
        finalImageName = "quay.io/k0sproject/cni-node";
        finalImageTag = "1.3.0-k0s.0";
      }
      {
        imageName = "registry.k8s.io/metrics-server/metrics-server";
        imageDigest = "sha256:ee4304963fb035239bb5c5e8c10f2f38ee80efc16ecbdb9feb7213c17ae2e86e";
        sha256 = "1xw9nmhs19nhignlvii8nfl8qang3r53x10c36p42c51a3jzczy3";
        finalImageName = "registry.k8s.io/metrics-server/metrics-server";
        finalImageTag = "v0.6.4";
      }
      {
        imageName = "registry.k8s.io/pause";
        imageDigest = "sha256:7031c1b283388d2c2e09b57badb803c05ebed362dc88d84b480cc47f72a21097";
        sha256 = "1qpdlccx3hsc58z7a76xpczdfd301jxfkd95m58hi0r6imsvq8wa";
        finalImageName = "registry.k8s.io/pause";
        finalImageTag = "3.9";
      }
    ];
    name = "k0s_bundle";
  }
