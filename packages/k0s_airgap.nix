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
        imageDigest = "sha256:8345c4103027bb12acaa01cb9d463e7028f9827a9b5f92c5a26190c43bb289e3";
        sha256 = "1jh9ggz0nd9c9f28nmcxi1byanmxs5zwpb6vxk3wgiwlk4kz9iki";
        finalImageName = "quay.io/k0sproject/cni-node";
        finalImageTag = "1.1.1-k0s.1";
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
        imageDigest = "sha256:9001185023633d17a2f98ff69b6ff2615b8ea02a825adffa40422f51dfdcde9d";
        sha256 = "0haigghv9z7swwf9z948jsw4hvgq58g0n5p5javcf224zq4bnjh6";
        finalImageName = "registry.k8s.io/pause";
        finalImageTag = "3.8";
      }
    ];
    name = "k0s_bundle";
  }
