{
  makeTest ? import <nixpkgs/nixos/tests/make-test-python.nix>,
  eval-config ? import <nixpkgs/nixos/lib/eval-config.nix>,
  pkgs ? import <nixpkgs> {},
  ...
}: let
  tests = builtins.listToAttrs (pkgs.lib.forEach [
      {
        name = "simple-pair-cluster";
        test = ./simple-pair-cluster.nix;
      }
      {
        name = "three-to-three-cluster";
        test = ./three-to-three-cluster.nix;
      }
    ] (testCase: let
      test = import testCase.test {inherit makeTest eval-config pkgs;};
    in {
      name = testCase.name;
      value = test;
    }));
in
  tests
