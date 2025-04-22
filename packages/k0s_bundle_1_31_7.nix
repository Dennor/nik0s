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
        imageDigest = "sha256:50e8b517241d3c358fd6c2fb4306a27be229fdc47b27448d70a90e96494d0c44";
        sha256 = "189lbws9lmaipkxw9msswli3ck5s8sqs7wfx8clzdk9k4srghq5b";
        finalImageName = "quay.io/k0sproject/calico-cni";
        finalImageTag = "v3.28.2-0";
      }
      {
        imageName = "quay.io/k0sproject/calico-kube-controllers";
        imageDigest = "sha256:e2303a94aac93d539c40173715631cd120dc618c2fbd03d817cef5fec1e4cfcb";
        sha256 = "0zslyy9ibx4cijxvlfcw3m90k83p6h46i2vihxghaaprwhq6y1gz";
        finalImageName = "quay.io/k0sproject/calico-kube-controllers";
        finalImageTag = "v3.28.2-0";
      }
      {
        imageName = "quay.io/k0sproject/calico-node";
        imageDigest = "sha256:f8e85afbf97246c382a66b69aab50a20378c2c39e859f567d0b010dc400fc0e2";
        sha256 = "1lsa30fpbadr7a685c5yg2xgm2p9ms0k12hfapzksw43ckzq6ws1";
        finalImageName = "quay.io/k0sproject/calico-node";
        finalImageTag = "v3.28.2-0";
      }
      {
        imageName = "quay.io/k0sproject/coredns";
        imageDigest = "sha256:396960d5f168eecc33d5c4b02b4526a9f71ed04ddb678113fcb3a57062c98379";
        sha256 = "1b93zwr0cjgpailvvpygllfzkp9c3m15vi8qzd1m1rkdgvbn5dxv";
        finalImageName = "quay.io/k0sproject/coredns";
        finalImageTag = "1.11.4";
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
        imageDigest = "sha256:893d7e9f637de21cf0445a79ec459e19c38020c7d4c63b7b6b409b0c142935cb";
        sha256 = "1hfaqnsmm9pbhhfcg5n9yir3ddrv49gvgrjw5kq0rh0c9xbjbbx9";
        finalImageName = "quay.io/k0sproject/kube-proxy";
        finalImageTag = "v1.31.7";
      }
      {
        imageName = "quay.io/k0sproject/kube-router";
        imageDigest = "sha256:7d123cda213edf7e0f02795d58dcdb75f4ebee0122c62b2f50b4f7d2cef85450";
        sha256 = "0ikh4vfghwz7626dlqlh9lc4kfzkpnvmppy04xzcxv3viryjlpfr";
        finalImageName = "quay.io/k0sproject/kube-router";
        finalImageTag = "v2.2.1-iptables1.8.9-1";
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
        imageDigest = "sha256:ffcb2bf004d6aa0a17d90e0247cf94f2865c8901dcab4427034c341951c239f9";
        sha256 = "1vj0f259yzzcivjd53wkmfxz2xhr2g9nidnzygi7r5pm6cdgqigs";
        finalImageName = "registry.k8s.io/metrics-server/metrics-server";
        finalImageTag = "v0.7.2";
      }
      {
        imageName = "registry.k8s.io/pause";
        imageDigest = "sha256:7031c1b283388d2c2e09b57badb803c05ebed362dc88d84b480cc47f72a21097";
        sha256 = "1qpdlccx3hsc58z7a76xpczdfd301jxfkd95m58hi0r6imsvq8wa";
        finalImageName = "registry.k8s.io/pause";
        finalImageTag = "3.9";
      }
      {
        imageName = "quay.io/k0sproject/pushgateway-ttl";
        imageDigest = "sha256:f4fe08b93061db904ba039db2717c9d5357c83d991e739c53e87d271bd3f34f2";
        sha256 = "0drh4zkhwy63kybli97kq7vdxcikj7b90ljlhrnzjxz6ixq1k0zr";
        finalImageName = "quay.io/k0sproject/pushgateway-ttl";
        finalImageTag = "1.4.0-k0s.0";
      }
      {
        imageName = "quay.io/k0sproject/envoy-distroless";
        imageDigest = "sha256:dad24c3b908ded5d5a6c403a89188d1ba8d61a8bd00c7252e5e03db149423e99";
        sha256 = "1jsg7afca1gyac01bn83l7mzwv7cgarx8wqg2mn6vbfcvfrv42wf";
        finalImageName = "quay.io/k0sproject/envoy-distroless";
        finalImageTag = "v1.31.5";
      }
    ];
    name = "k0s_bundle";
  }
