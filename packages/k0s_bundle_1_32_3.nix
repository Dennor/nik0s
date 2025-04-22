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
        imageDigest = "sha256:fd83e368d170d6f10e9f4ac7fb6f1e5d104cba5788a922ce67dca1c6a9f4c686";
        sha256 = "1cl1fx3aaz5xgk6c8hgsb1xdgdhswazp9mfh2qr68py3sfr2i9bn";
        finalImageName = "quay.io/k0sproject/calico-cni";
        finalImageTag = "v3.29.3-0";
      }
      {
        imageName = "quay.io/k0sproject/calico-kube-controllers";
        imageDigest = "sha256:23936891e3a36031557a394711ff545a692888f30b3e4ac157ca28a4ef72688e";
        sha256 = "0gxf4qdk1nm6xvmad2axzi2pgj8qf801c7rfqrfyah9212zdnz1w";
        finalImageName = "quay.io/k0sproject/calico-kube-controllers";
        finalImageTag = "v3.29.3-0";
      }
      {
        imageName = "quay.io/k0sproject/calico-node";
        imageDigest = "sha256:5572811f09c4459f1b237acc723c9bc2d2b0c34667d17e804a8eac1428d61ee9";
        sha256 = "09gjzikcpriqn9jpb91l4bvqf7467yxvzg7fvkzgl2s7lbaim8bh";
        finalImageName = "quay.io/k0sproject/calico-node";
        finalImageTag = "v3.29.3-0";
      }
      {
        imageName = "quay.io/k0sproject/coredns";
        imageDigest = "sha256:4b173553f994316e677a5d09584906afc022395a4c3989f7a9c69c1d1363326c";
        sha256 = "1agsg4f3i2dfdda62m4fwjy9fm6gqn6cza5cjwmfmvq50kw1bvhi";
        finalImageName = "quay.io/k0sproject/coredns";
        finalImageTag = "1.12.0";
      }
      {
        imageName = "quay.io/k0sproject/apiserver-network-proxy-agent";
        imageDigest = "sha256:6c4234bd508111e1a7144a5bb755cd8935ad9c7ca9ff23607f551611171e3690";
        sha256 = "11y8ggqfs419yyg8yb8zq0f8zz4q90id41b1ri27q4d56aja1aq3";
        finalImageName = "quay.io/k0sproject/apiserver-network-proxy-agent";
        finalImageTag = "v0.31.0";
      }
      {
        imageName = "quay.io/k0sproject/kube-proxy";
        imageDigest = "sha256:508ad00304be19a491b4bc8c1e2caae7c570927a3e4277d8cdd0bc3e9434ddf9";
        sha256 = "1bs6jrvd5zsmid2zsfcw0bs8zswlkizcmajaplxj3kjy9bg8ycqw";
        finalImageName = "quay.io/k0sproject/kube-proxy";
        finalImageTag = "v1.32.3";
      }
      {
        imageName = "quay.io/k0sproject/kube-router";
        imageDigest = "sha256:badf324c57b6f503d6093cc3ce10b888ce08fc0b2a5113c66860339ad59bb8a2";
        sha256 = "0ym6k794pw42gv6270ppbq8lqmli36m2fv3q1a8g60rrlrm5gcmq";
        finalImageName = "quay.io/k0sproject/kube-router";
        finalImageTag = "v2.4.1-iptables1.8.9-0";
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
