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
