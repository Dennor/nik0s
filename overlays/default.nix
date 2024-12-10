final: prev:
with prev.lib;
  (builtins.listToAttrs (builtins.map (ver: {
    name = "linuxPackages_${ver}_hardened_bpfilter";
    value = prev.linuxPackagesFor (prev."linux_${ver}_hardened".override {
      structuredExtraConfig = with kernel; {
        STRICT_DEVMEM = mkForce no;
        SCHEDSTATS = mkForce yes;
        RC_CORE = yes;
        BPF_LIRC_MODE2 = yes;
        FPROBE = yes;
        FUNCTION_ERROR_INJECTION = yes;
        PREEMPT_NONE = yes;
      };
      ignoreConfigErrors = true;
    });
  }) ["6_5" "6_6" "6_7" "6_12"]))
  // {
    lib =
      prev.lib
      // {
        k0s-utils =
          {
            mkHelmChart = import ../lib/helm.nix;
            mkBundle = import ../lib/airgap.nix;
          }
          // import ../lib/cluster.nix {pkgs = final;};
      };
  }
  // import ../packages {pkgs = final;}
