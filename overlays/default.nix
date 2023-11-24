final: prev:
{
  linuxPackages_6_5_hardened_bpfilter = with prev.lib;
    prev.linuxPackagesFor (prev.linux_6_5_hardened.override {
      structuredExtraConfig = with kernel; {
        STRICT_DEVMEM = mkForce no;
        SCHEDSTATS = mkForce yes;
        RC_CORE = yes;
        BPF_LIRC_MODE2 = yes;
        BPFILTER = yes;
        FPROBE = yes;
        FUNCTION_ERROR_INJECTION = yes;
      };
      ignoreConfigErrors = true;
    });
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
