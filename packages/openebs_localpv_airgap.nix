{
  stdenv,
  dockerTools,
}: let
  mkBundle = import ../lib/airgap.nix;
in
  mkBundle rec {
    inherit stdenv dockerTools;
    images = [
      {
        imageName = "openebs/provisioner-localpv";
        imageDigest = "sha256:b68b8a104faa9294571b6d1b0f3c3ec15ff8ba06f6b3f8d193865f324025636a";
        finalImageTag = "3.4.0";
        sha256 = "0srlhzk9wvqznsa4y9xvvnnv1v9krk5b8rjwhddd9aqkq2dnmg70";
        os = "linux";
      }
      {
        imageName = "openebs/node-disk-operator";
        imageDigest = "sha256:6afe2123c457d863e5db0f29a4b071f750d2570d3d240373aa9ad0a04db9b929";
        sha256 = "1xza7xbyrwq2j19mv4psjisq3m7j5cvrfyai7cljpb6mq4hg3ylx";
        finalImageName = "openebs/node-disk-operator";
        finalImageTag = "2.1.0";
      }
      {
        imageName = "openebs/node-disk-manager";
        imageDigest = "sha256:f6c18b0f8c8a523a1e307e9f355c1557ac3fb713fb06486f95942b12924d3034";
        sha256 = "0wcqagkwaxww79zivlc41jlyqpzqkbrc5lncq92wi7szq2pnhls2";
        finalImageName = "openebs/node-disk-manager";
        finalImageTag = "2.1.0";
      }
      {
        imageName = "openebs/linux-utils";
        imageDigest = "sha256:57bd9afd259596c86f3130bd80d1cba799c76fa9fa32dcc218c3c3191f298463";
        sha256 = "1vgjxrngfr3b8wmzld99n93743gk04wmzcj5ha4rjmws7slmsg6k";
        finalImageName = "openebs/linux-utils";
        finalImageTag = "3.4.0";
      }
    ];
    name = "openebs_localpv_bundle";
  }
