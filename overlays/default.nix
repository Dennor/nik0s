final: prev:
{
  linuxPackages_xanmod_bpfilter_stable = with prev.lib;
    prev.linuxPackagesFor (prev.linux_xanmod_stable.override {
      structuredExtraConfig = with kernel; {
        SCHEDSTATS = mkForce yes;
        RC_CORE = yes;
        BPF_LIRC_MODE2 = yes;
        BPFILTER = yes;
        FPROBE = yes;
        FUNCTION_ERROR_INJECTION = yes;
      };
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
