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
    controller0 = "192.168.1.128";
    controller1 = "192.168.1.129";
    controller2 = "192.168.1.130";
    worker0 = "192.168.1.131";
    worker1 = "192.168.1.132";
    worker2 = "192.168.1.133";
  };
  private = {
    link = "eth2";
    net = "192.168.2.0";
    gateway = "192.168.2.1";
    controller0 = "192.168.2.128";
    controller1 = "192.168.2.129";
    controller2 = "192.168.2.130";
    worker0 = "192.168.2.131";
    worker1 = "192.168.2.132";
    worker2 = "192.168.2.133";
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
    apiHosts = [
      public.controller0
      public.controller1
      public.controller2
      private.controller0
      private.controller1
      private.controller2
    ];
    cluster = {
      clusterName = "three-to-three-cluster";
      pools = {
        testcontrollers = {
          kind = "controller";
          nodes = {
            controller0 = {
              network = network "controller0";
              master = {
                ca = {
                  "/var/lib/k0s/pki/ca" = {
                    key = ./ca.key;
                    crt = ./ca.crt;
                  };
                };
              };
            };
            controller1 = {
              network = network "controller1";
              joinToken = auth.controller.token;
            };
            controller2 = {
              network = network "controller2";
              joinToken = auth.controller.token;
            };
          };
        };
        testworkers = {
          kind = "worker";
          nodes = {
            worker0 = {
              network = network "worker0";
              joinToken = auth.worker.token;
            };
            worker1 = {
              network = network "worker1";
              joinToken = auth.worker.token;
            };
            worker2 = {
              network = network "worker2";
              joinToken = auth.worker.token;
            };
          };
        };
      };
    };
  };
in
  test
