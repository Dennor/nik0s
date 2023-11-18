{
  cilium = import ./cilium.nix;
  cluster = import ./cluster.nix;
  k0s = import ./k0s;
  helm = import ./helm.nix;
}
