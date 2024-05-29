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
        imageDigest = "sha256:4ce1666a73815101ec9a4d360af6c5b7f1193ab00d89b7124f8505dee147ca40";
        sha256 = "0k1hmg9yc04v4wakywinvpr6mwdlik5z5i0yj3lrlzm5smnmh5pf";
        finalImageName = "quay.io/cilium/cilium";
        finalImageTag = "v1.15.5";
      }
      {
        imageName = "quay.io/cilium/certgen";
        imageDigest = "sha256:bbc5e65e9dc65bc6b58967fe536b7f3b54e12332908aeb0a96a36866b4372b4e";
        sha256 = "0910bxzwiwz80cy1ynfk47dzwakrcyr8x2d3aca4qm22barq4id6";
        finalImageName = "quay.io/cilium/certgen";
        finalImageTag = "v0.1.12";
      }
      {
        imageName = "quay.io/cilium/hubble-relay";
        imageDigest = "sha256:1d24b24e3477ccf9b5ad081827db635419c136a2bd84a3e60f37b26a38dd0781";
        sha256 = "10dmrsqhvijqdhlll5sjqiakzbjr8bbycqg2lvvy4bv733q1nbg5";
        finalImageName = "quay.io/cilium/hubble-relay";
        finalImageTag = "v1.15.5";
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
        imageDigest = "sha256:bc8dcc3bc008e3a5aab98edb73a0985e6ef9469bda49d5bb3004c001c995c380";
        sha256 = "0x2wp08r48mirx1mq3q8zhvs7lcp5w407894s1j41r8cnwx5pamv";
        finalImageName = "quay.io/cilium/cilium-envoy";
        finalImageTag = "v1.28.3-31ec52ec5f2e4d28a8e19a0bfb872fa48cf7a515";
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
        imageDigest = "sha256:6f480128aa3d3b2c50a8dfa0bd5bc5121e48b1ee0bbc8eec9cae72e904bf10c3";
        sha256 = "0jwzr9hf9szwrv0qdf5a1rbvmw5jxjkvn3v3lcnigk8l2ir46dr5";
        finalImageName = "quay.io/cilium/operator";
        finalImageTag = "v1.15.5";
      }
      {
        imageName = "quay.io/cilium/operator-generic";
        imageDigest = "sha256:f5d3d19754074ca052be6aac5d1ffb1de1eb5f2d947222b5f10f6d97ad4383e8";
        sha256 = "03ivpfcchfa1vqqwqyyfnpaz1bi2rgdxgdr0lf5nf7ygw4vkzmrh";
        finalImageName = "quay.io/cilium/operator-generic";
        finalImageTag = "v1.15.5";
      }
      {
        imageName = "quay.io/cilium/startup-script";
        imageDigest = "sha256:820155cb3b7f00c8d61c1cffa68c44440906cb046bdbad8ff544f5deb1103456";
        sha256 = "0gjgibbdcrb44m0za1vws1w2xs52b7ipk8k6whr3qnrm6czygbfc";
        finalImageName = "quay.io/cilium/startup-script";
        finalImageTag = "19fb149fb3d5c7a37d3edfaf10a2be3ab7386661";
      }
      {
        imageName = "quay.io/cilium/cilium";
        imageDigest = "sha256:4ce1666a73815101ec9a4d360af6c5b7f1193ab00d89b7124f8505dee147ca40";
        sha256 = "0k1hmg9yc04v4wakywinvpr6mwdlik5z5i0yj3lrlzm5smnmh5pf";
        finalImageName = "quay.io/cilium/cilium";
        finalImageTag = "v1.15.5";
      }
      {
        imageName = "quay.io/cilium/clustermesh-apiserver";
        imageDigest = "sha256:914549caf4376a844b5e7696019182dd2a655b89d6a3cad10f9d0f9821759fd7";
        sha256 = "172d7nlpfqbpnrs6h7bxvzwqdald7mhrgglay4wsqv0jqfhx1cl3";
        finalImageName = "quay.io/cilium/clustermesh-apiserver";
        finalImageTag = "v1.15.5";
      }
      {
        imageName = "docker.io/library/busybox";
        imageDigest = "sha256:5eef5ed34e1e1ff0a4ae850395cbf665c4de6b4b83a32a0bc7bcb998e24e7bbb";
        sha256 = "0shv67m1yimab8hpax12rbp46akmz695hii0yxx4jfy4smncqj56";
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
