{pkgs ? import <nixpkgs>, ...}: let
  versionToSuffix = ver: builtins.replaceStrings ["."] ["_"] ver;
  versionsToSuffixes = versions: builtins.map versionToSuffix versions;
  pkgSuffixes = pkg: versions:
    builtins.map (v: {
      name = "${pkg}_${v}";
      value = ./${pkg}_${v}.nix;
    }) (versionsToSuffixes versions);
  versionedPackage = pkg: versions: builtins.listToAttrs (pkgSuffixes pkg versions);
  k0sVersions = ["1.30.4" "1.31.7" "1.32.3"];
  k0sPackages = versionedPackage "k0s" k0sVersions;
  k0sBundlePackages = versionedPackage "k0s_bundle" k0sVersions;
  ciliumVersions = ["1.15.0" "1.15.4" "1.15.5" "1.16.4" "1.16.7" "1.17.3" "1.17.7"];
  ciliumPackages = versionedPackage "cilium" ciliumVersions;
  ciliumAirgapPackages = versionedPackage "cilium_airgap" ciliumVersions;
in
  builtins.mapAttrs (name: value: pkgs.callPackage value {}) ({
      k0s = ./k0s.nix;
      k0sBundle = ./k0s_airgap.nix;
      ciliumChart = ./cilium_1_16_4.nix;
      ciliumBundle = ./cilium_airgap_1_16_4.nix;
      openebsChart = ./openebs.nix;
      openebsLocalPVBundle = ./openebs_localpv_airgap.nix;
    }
    // k0sPackages
    // k0sBundlePackages
    // ciliumPackages
    // ciliumAirgapPackages)
