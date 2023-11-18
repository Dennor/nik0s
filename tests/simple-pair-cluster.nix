{
  makeTest ? import <nixpkgs/nixos/tests/make-test-python.nix>,
  eval-config ? import <nixpkgs/nixos/lib/eval-config.nix>,
  system ? builtins.currentSystem,
  pkgs ?
    import <nixpkgs> {
      inherit system;
      overlays = [(import ../overlays)];
    },
}: let
  public = {
    link = "eth1";
    net = "192.168.1.0";
    gateway = "192.168.1.1";
    # Starting pretty high to avoid possible IP conflicts and since I don't think I'll ever be
    # testing on more than 128 VMs concurrently so this should be safe:)
    controller = "192.168.1.128";
    worker = "192.168.1.129";
  };
  private = {
    link = "eth2";
    net = "192.168.2.0";
    gateway = "192.168.2.1";
    controller = "192.168.2.128";
    worker = "192.168.2.129";
  };
  iface = {
    conf,
    node,
  }: {
    link = conf.link;
    ipv4 = {
      addresses = [
        {
          address = conf.${node};
          prefixLength = 24;
        }
      ];
      routes = [
        {
          address = conf.net;
          prefixLength = 24;
          via = conf.gateway;
        }
      ];
    };
  };
  network = node: {
    public = iface {
      inherit node;
      conf = public;
    };
    private = iface {
      inherit node;
      conf = private;
    };
  };

  testLib = import ../lib/test.nix {inherit makeTest eval-config pkgs;};
  auth = import ./auth.nix;
  test = testLib {
    inherit auth;
    apiHosts = [public.controller private.controller];
    cluster = {
      clusterName = "simple-pair-cluster";
      pools = {
        testcontrollers = {
          kind = "controller";
          nodes = {
            testcontroller = {
              network = network "controller";
              master = {
                ca = {
                  "/var/lib/k0s/pki/ca" = {
                    key = ./ca.key;
                    crt = ./ca.crt;
                  };
                };
              };
            };
          };
        };
        testworkers = {
          kind = "worker";
          nodes = {
            testworker = {
              network = network "worker";
              joinToken = auth.worker.token;
            };
          };
        };
      };
    };
    # For a 1-to-1 cluster, controller neither token nor manifest should be necessary
    # but test anyways to see if it works with it
    # manifests = testCase: node:
    #     if node.config.pool.kind == "controller"
    #     then [[auth.worker.manifest]]
    #     else [];
  };
in
  test
