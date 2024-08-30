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
        imageDigest = "sha256:8aaf30313feb1dce563407ff366f6b3d7b1d495d8d99557894f4fc5304f2facd";
        sha256 = "0vjhs8xzif66lrsp4y7w1swx4bshcldfm1d2bb3j6g270v2vd6hp";
        finalImageName = "quay.io/k0sproject/calico-cni";
        finalImageTag = "v3.27.3-0";
      }
      {
        imageName = "quay.io/k0sproject/calico-kube-controllers";
        imageDigest = "sha256:8a891d48d80d71a38fb6cac37f42ca83ee416103badce97ee425e386ba5f459d";
        sha256 = "1d4x25jp2hm543ybl4w7kbvagdnsdcqvb681mwcnw4gh7rlixb5f";
        finalImageName = "quay.io/k0sproject/calico-kube-controllers";
        finalImageTag = "v3.27.3-0";
      }
      {
        imageName = "quay.io/k0sproject/calico-node";
        imageDigest = "sha256:8f29e8ce4d2085396a0302616f970692cc47b89892bf7fb29aa3e872224b8bf6";
        sha256 = "1xgg3k945l3r0fixjdj988s01ikwyrcj07bdn4nj78dv41n582z1";
        finalImageName = "quay.io/k0sproject/calico-node";
        finalImageTag = "v3.27.3-0";
      }
      {
        imageName = "quay.io/k0sproject/coredns";
        imageDigest = "sha256:990a50a183a7d7392ee6d1a1a36a603a7d9deedab73589a713d8273d0b1d88ff";
        sha256 = "1yp371vbvv3idvh7ab8jv4c41lvf8sdck0hv29gyy95g0gbxzvh5";
        finalImageName = "quay.io/k0sproject/coredns";
        finalImageTag = "1.11.3";
      }
      {
        imageName = "quay.io/k0sproject/apiserver-network-proxy-agent";
        imageDigest = "sha256:6723baf0bf62f76e85bc9120a056d0efb67b4f9dc041acbf5e74ead4b4f5f775";
        sha256 = "1ncj239638r2m8d19mwjm5llm65dkkw3jh6ylhvy8p5npfqyhais";
        finalImageName = "quay.io/k0sproject/apiserver-network-proxy-agent";
        finalImageTag = "v0.30.3";
      }
      {
        imageName = "quay.io/k0sproject/kube-proxy";
        imageDigest = "sha256:c0b00323944163bd8829da2593e7ca4f63cf776d1d9eef655ba0fa471ee8b862";
        sha256 = "1s744c3vsgk9gad63y6arsfcq99vdx6j73nhnjm359xz36i62wgw";
        finalImageName = "quay.io/k0sproject/kube-proxy";
        finalImageTag = "v1.30.4";
      }
      {
        imageName = "quay.io/k0sproject/kube-router";
        imageDigest = "sha256:fbb9c15ef791250f6d4e01939b0117cc630cd10a79981fa1951ea01571368ac4";
        sha256 = "1ns8mjlspv0vw4hbnlrivpmhyj43p090z7jz9yclkn369kc32n79";
        finalImageName = "quay.io/k0sproject/kube-router";
        finalImageTag = "v2.1.0-iptables1.8.9-0";
      }
      {
        imageName = "quay.io/k0sproject/cni-node";
        imageDigest = "sha256:f9ae72f1be998ba3d0a9298d35cbd5577758cc08326406c63fb4804b0664391a";
        sha256 = "002iy6a1dlizrixsns4k747mw56i9dr641ls3q8sxqfdj90zly5a";
        finalImageName = "quay.io/k0sproject/cni-node";
        finalImageTag = "1.3.0-k0s.0";
      }
      {
        imageName = "quay.io/k0sproject/metrics-server";
        imageDigest = "sha256:4dc8977ce65ac70043401326f77ea6f0a9ad45a90a48e2935ff6f6281af2f7e0";
        sha256 = "1dbil5fqafi8pzmsgqwvslyip8hzqqm1lc5bcnyvyvh2iksiilx3";
        finalImageName = "quay.io/k0sproject/metrics-server";
        finalImageTag = "v0.7.1-0";
      }
      {
        imageName = "registry.k8s.io/pause";
        imageDigest = "sha256:7031c1b283388d2c2e09b57badb803c05ebed362dc88d84b480cc47f72a21097";
        sha256 = "1qpdlccx3hsc58z7a76xpczdfd301jxfkd95m58hi0r6imsvq8wa";
        finalImageName = "registry.k8s.io/pause";
        finalImageTag = "3.9";
      }
      {
        imageName = "quay.io/k0sproject/envoy-distroless";
        imageDigest = "sha256:1fc94378d305d1666c979abfffe450391d026dd20696c5088b9b9c99efdf8e13";
        sha256 = "1ixq50mfphkkibhj3l8cjiaaagi518m51p4j9spqmpq4zcjz8wri";
        finalImageName = "quay.io/k0sproject/envoy-distroless";
        finalImageTag = "v1.30.4";
      }
    ];
    name = "k0s_bundle";
  }
