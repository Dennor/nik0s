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
        imageDigest = "sha256:4981767b787c69126e190e33aee93d5a076639083c21f0e7c29596a519c64a2e";
        sha256 = "09lx6h584lkhmqa4v6mnca0vq4cm1mrd9171cgqyxhcpnb2yj28c";
        finalImageName = "quay.io/cilium/cilium";
        finalImageTag = "v1.14.4";
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
        imageDigest = "sha256:ca81622fd9f04c1316bf4144bde5dbce613758810f6022f6c706b14c9c0815db";
        sha256 = "0n8bw3qqmgak1jrbvgs4pkmfp4my15343sqhahasrv4bsxzys743";
        finalImageName = "quay.io/cilium/hubble-relay";
        finalImageTag = "v1.14.4";
      }
      {
        imageName = "quay.io/cilium/hubble-ui-backend";
        imageDigest = "sha256:1f86f3400827a0451e6332262467f894eeb7caf0eb8779bd951e2caa9d027cbe";
        sha256 = "0p5wa7pk90vwpxhc6af3ypd3vjcbi7439np4z4q71rj6dgsi54lc";
        finalImageName = "quay.io/cilium/hubble-ui-backend";
        finalImageTag = "v0.12.1";
      }
      {
        imageName = "quay.io/cilium/hubble-ui";
        imageDigest = "sha256:9e5f81ee747866480ea1ac4630eb6975ff9227f9782b7c93919c081c33f38267";
        sha256 = "0ldiifpmmwfvkrsz6wxqsl35yj6yv1zzrj4vrpvkkyfi5bqg7gz6";
        finalImageName = "quay.io/cilium/hubble-ui";
        finalImageTag = "v0.12.1";
      }
      {
        imageName = "quay.io/cilium/cilium-envoy";
        imageDigest = "sha256:6b0f2591fef922bf17a46517d5152ea7d6270524bb0e307c77986986677dbcea";
        sha256 = "0qfrprd2gcpyfg6wqv8lx9chzywl0iycsq8q8b5pml4qn1pv321q";
        finalImageName = "quay.io/cilium/cilium-envoy";
        finalImageTag = "v1.26.6-ff0d5d3f77d610040e93c7c7a430d61a0c0b90c1";
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
        imageDigest = "sha256:cfa8013dbac76c01f6fcb793697af6d372c7bc778a3135b9f5f2230c631b0a51";
        sha256 = "1slfilw5d1y974fsaw1qassiwjy9g811h485ns9m0w415h773w0n";
        finalImageName = "quay.io/cilium/operator";
        finalImageTag = "v1.14.4";
      }
      {
        imageName = "quay.io/cilium/operator-generic";
        imageDigest = "sha256:f0f05e4ba3bb1fe0e4b91144fa4fea637701aba02e6c00b23bd03b4a7e1dfd55";
        sha256 = "0cv8l68fx1kb6pbw8ccngdb7zdpjm78yhwdcb5c4vwp14whlk0hc";
        finalImageName = "quay.io/cilium/operator-generic";
        finalImageTag = "v1.14.4";
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
        imageDigest = "sha256:828a74eea2a15c4196633dc50e4b92ba3a5e3ed8418c2a33e255a9281a1ce42f";
        sha256 = "0ib6pqapaqpdwqc8rhyf20xwixilmiadckaqi3fjvd8gmf7ccm6n";
        finalImageName = "quay.io/cilium/clustermesh-apiserver";
        finalImageTag = "v1.14.4";
      }
      {
        imageName = "quay.io/coreos/etcd";
        imageDigest = "sha256:795d8660c48c439a7c3764c2330ed9222ab5db5bb524d8d0607cac76f7ba82a3";
        sha256 = "177vajzzw1rskzqlfydd5pj7xbzlpgk7zhwaidy1fksnxh02hh73";
        finalImageName = "quay.io/coreos/etcd";
        finalImageTag = "v3.5.4";
      }
      {
        imageName = "quay.io/cilium/kvstoremesh";
        imageDigest = "sha256:492cde62cb2def832b3213211cb99d59bd9fe9789be32a181fb24554077368b0";
        sha256 = "04hsnq351448i236bffsg2nky9bsb26mw1m5jp3g3r49j23cfgqj";
        finalImageName = "quay.io/cilium/kvstoremesh";
        finalImageTag = "v1.14.4";
      }
      {
        imageName = "ghcr.io/spiffe/spire-agent";
        imageDigest = "sha256:8eef9857bf223181ecef10d9bbcd2f7838f3689e9bd2445bede35066a732e823";
        sha256 = "18yzp4wglyvqfbqrlay12vgxiwz3d4izq25v93yis5blpkhp9sza";
        finalImageName = "ghcr.io/spiffe/spire-agent";
        finalImageTag = "1.6.3";
      }
      {
        imageName = "ghcr.io/spiffe/spire-server";
        imageDigest = "sha256:f4bc49fb0bd1d817a6c46204cc7ce943c73fb0a5496a78e0e4dc20c9a816ad7f";
        sha256 = "19vqn7w0r4d1pf6vvkskfx087gxal2j1ki19gd18c11rywzzgk25";
        finalImageName = "ghcr.io/spiffe/spire-server";
        finalImageTag = "1.6.3";
      }
      {
        imageName = "busybox";
        imageDigest = "sha256:7ae8447f3a7f5bccaa765926f25fc038e425cf1b2be6748727bbea9a13102094";
        sha256 = "0fm7kkprkmymplhzrsibjknxk3ysxa8sc4f9naj7a8wz0m5prxnb";
        finalImageName = "busybox";
        finalImageTag = "1.35.0";
      }
    ];
    name = "cilium_bundle";
  }
