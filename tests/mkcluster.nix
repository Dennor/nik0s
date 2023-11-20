{pkgs ? import <nixpkgs> {}}:
with pkgs.lib; let
  clusterLib = import ../lib/cluster.nix {inherit pkgs;};
  mkNet = cfg: addresses:
    builtins.mapAttrs (name: value:
      builtins.mapAttrs (name: value: {
        inherit (cfg) link;
        ipv4 = {
          inherit (cfg) routes;
          addresses = builtins.map (value:
            {
              inherit (cfg) prefixLength;
            }
            // value)
          value.addresses;
        };
      })
      value)
    addresses;
  privateCfg = {
    prefixLength = 12;
    link = "enp7s0";
    routes = [
      {
        address = "172.16.0.0";
        via = "172.16.0.1";
        prefixLength = 12;
      }
    ];
  };
  private = (mkNet privateCfg) {
    controllers-0 = {
      controller-0 = {
        addresses = [{address = "172.16.0.2";}];
      };
    };
    workers-0 = {
      worker-0 = {
        addresses = [{address = "172.16.0.3";}];
      };
      worker-1 = {
        addresses = [{address = "172.16.0.4";}];
      };
      worker-2 = {
        addresses = [{address = "172.16.0.5";}];
      };
    };
  };
  publicCfg = {
    prefixLength = 12;
    link = "enp1s0";
    routes = [
      {
        address = "0.0.0.0";
        via = "172.31.1.1";
        prefixLength = 0;
      }
      {
        address = "172.31.1.1";
        via = "172.31.1.1";
        prefixLength = 32;
      }
    ];
  };
  public = (mkNet privateCfg) {
    controllers-0 = {
      controller-0 = {
        addresses = [
          {
            address = "1.1.1.1";
            prefixLength = 32;
          }
        ];
      };
    };
    workers-0 = {
      worker-0 = {
        addresses = [
          {
            address = "2.2.2.2";
            prefixLength = 32;
          }
        ];
      };
      worker-1 = {
        addresses = [
          {
            address = "3.3.3.3";
            prefixLength = 32;
          }
        ];
      };
      worker-2 = {
        addresses = [
          {
            address = "4.4.4.4";
            prefixLength = 32;
          }
        ];
      };
    };
  };
  cluster = {
    enable = true;
    name = "test-cluster";
    pools = {
      controllers-0 = {
        kind = "controller";
        nodes = {
          controller-0 = {
            network = {
              private = private.controllers-0.controller-0;
              public = public.controllers-0.controller-0;
            };
            master = {
              ca = {
                "/var/lib/k0s/pki/ca" = {
                  key = "/run/secrets/ca.key";
                  crt = "/run/secrets/ca.crt";
                };
              };
            };
          };
        };
      };
      workers-0 = {
        kind = "worker";
        nodes = genAttrs ["worker-0" "worker-1" "worker-2"] (node: {
          network = {
            private = private.workers-0.${node};
            public = private.workers-0.${node};
          };
        });
      };
    };
    machine = {
      pool = "controllers-0";
      node = "controller-0";
    };
    apiHost = "1.1.1.1";
    apiPort = 6443;
  };
  drv = clusterLib.mkCluster cluster;
in
  drv
