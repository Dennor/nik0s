{
  description = "Defines k0s cluster nodes configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  }:
    with nixpkgs; let
      clusterLib = import ./lib {
        inherit lib;
      };
      forAllSystems = nixpkgs.lib.genAttrs ["x86_64-linux"];
    in {
      overlays.default = import ./overlays;

      packages = forAllSystems (system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in
        import ./packages {inherit pkgs;});

      checks = forAllSystems (system: let
        pkgs = nixpkgs.legacyPackages.${system}.extend self.overlays.default;
        fmt-check = pkgs.stdenv.mkDerivation {
          name = "fmt-check";
          src = ./.;
          nativeBuildInputs = with pkgs; [alejandra];
          doCheck = true;
          checkPhase = ''
            alejandra -c .
          '';
          installPhase = ''
            mkdir -p $out
          '';
        };
        tests = nixpkgs.lib.optionalAttrs pkgs.hostPlatform.isx86_64 (import ./tests {
          inherit pkgs;
          makeTest = import (pkgs.path + "/nixos/tests/make-test-python.nix");
          eval-config = import (pkgs.path + "/nixos/lib/eval-config.nix");
        });
      in
        {inherit fmt-check;} // tests);

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

      nixosModules = import ./modules;
    };
}
