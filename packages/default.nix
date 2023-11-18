{pkgs ? import <nixpkgs>, ...}:
builtins.mapAttrs (name: value: pkgs.callPackage value {}) {
  k0s = ./k0s.nix;
  k0sBundle = ./k0s_airgap.nix;
  ciliumChart = ./cilium.nix;
  ciliumBundle = ./cilium_airgap.nix;
  openebsChart = ./openebs.nix;
  openebsLocalPVBundle = ./openebs_localpv_airgap.nix;
}
