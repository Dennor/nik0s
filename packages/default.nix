{pkgs ? import <nixpkgs>, ...}: let
  versionToSuffix = ver: builtins.replaceStrings ["."] ["_"] ver;
  versionsToSuffixes = versions: builtins.map versionToSuffix versions;
  pkgSuffixes = pkg: versions:
    builtins.map (v: {
      name = "${pkg}_${v}";
      value = ./${pkg}_${v}.nix;
    }) (versionsToSuffixes versions);
  versionedPackage = pkg: versions: builtins.listToAttrs (pkgSuffixes pkg versions);
  k0sVersions = ["1.28.3" "1.28.4"];
  k0sPackages = versionedPackage "k0s" k0sVersions;
  k0sBundlePackages = versionedPackage "k0s_bundle" k0sVersions;
in
  builtins.mapAttrs (name: value: pkgs.callPackage value {}) ({
      k0s = ./k0s.nix;
      k0sBundle = ./k0s_airgap.nix;
      ciliumChart = ./cilium.nix;
      ciliumBundle = ./cilium_airgap.nix;
      openebsChart = ./openebs.nix;
      openebsLocalPVBundle = ./openebs_localpv_airgap.nix;
    }
    // k0sPackages
    // k0sBundlePackages)
