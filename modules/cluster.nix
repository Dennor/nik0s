{
  config,
  options,
  lib,
  ...
}:
with lib; let
  cfg = config.cluster;
in {
  # Describes the whole topology of the cluster
  options.cluster = with types; let
    addrOpts = v:
      assert v == 4 || v == 6; {
        options = {
          address = mkOption {
            type = str;
            description = ''
              IPv${toString v} address of the interface. Leave empty to configure the
              interface using DHCP.
            '';
          };

          prefixLength = mkOption {
            type = addCheck int (n:
              n
              >= 0
              && n
              <= (
                if v == 4
                then 32
                else 128
              ));
            description = ''
              Subnet mask of the interface, specified as the number of
              bits in the prefix (`${
                if v == 4
                then "24"
                else "64"
              }`).
            '';
          };
        };
      };

    routeOpts = v: {
      options = {
        address = mkOption {
          type = str;
          description = "IPv${toString v} address of the network.";
        };

        prefixLength = mkOption {
          type = addCheck int (n:
            n
            >= 0
            && n
            <= (
              if v == 4
              then 32
              else 128
            ));
          description = ''
            Subnet mask of the network, specified as the number of
            bits in the prefix (`${
              if v == 4
              then "24"
              else "64"
            }`).
          '';
        };

        type = mkOption {
          type = nullOr (enum [
            "unicast"
            "local"
            "broadcast"
            "multicast"
          ]);
          default = null;
          description = ''
            Type of the route.  See the `Route types` section
            in the `ip-route(8)` manual page for the details.

            Note that `prohibit`, `blackhole`,
            `unreachable`, and `throw` cannot
            be configured per device, so they are not available here. Similarly,
            `nat` hasn't been supported since kernel 2.6.
          '';
        };

        via = mkOption {
          type = nullOr str;
          default = null;
          description = "IPv${toString v} address of the next hop.";
        };

        options = mkOption {
          type = attrsOf str;
          default = {};
          example = {
            mtu = "1492";
            window = "524288";
          };
          description = ''
            Other route options. See the symbol `OPTIONS`
            in the `ip-route(8)` manual page for the details.
            You may also specify `metric`,
            `src`, `protocol`,
            `scope`, `from`
            and `table`, which are technically
            not route options, in the sense used in the manual.
          '';
        };
      };
    };
    ipvx = v:
      submodule {
        options = {
          addresses = mkOption {
            description = "List of addresses in IPv${v}";
            type = listOf (submodule (addrOpts v));
            default = [];
          };
          routes = mkOption {
            description = "List of routes in IPv${v}";
            type = listOf (submodule (routeOpts v));
            default = [];
          };
        };
      };
    interface = submodule {
      options = {
        link = mkOption {
          description = "Predictable Network Interface Name";
          type = str;
        };
        dhcp = mkOption {
          description = "Enable DHCP, false by default.";
          type = nullOr bool;
          default = null;
        };
        vlan = mkOption {
          description = "VLAN interface";
          type = nullOr (submodule {
            options = {
              id = mkOption {
                type = int;
              };
              interface = mkOption {
                type = string;
              };
            };
          });
          default = null;
        };
        ipv4 = mkOption {
          description = "List of ipv4 addresses";
          type = ipvx 4;
          default = {};
        };
        ipv6 = mkOption {
          description = "List of ipv4 addresses";
          type = ipvx 6;
          default = {};
        };
      };
    };
    network = {
      public = mkOption {
        description = "Main ingress interface";
        type = interface;
      };
      private = mkOption {
        description = "An optional private interface preferred for cluster communication.";
        type = nullOr interface;
      };
    };
    node = submodule {
      options = {
        network = network;
        master = mkOption {
          type = nullOr (submodule {
            options = {
              ca = mkOption {
                description = "Atribute set of CAs and target paths";
                type = attrsOf (submodule {
                  options = {
                    key = mkOption {
                      type = either path str;
                      description = "Cluster CA key.";
                    };
                    crt = mkOption {
                      type = either path str;
                      description = "Cluster CA certificate.";
                    };
                  };
                });
              };
            };
          });
          description = "Indicates master bootstrap node. For master certificates are created during bootstrap, for non-master nodes join token is created.";
          default = null;
        };
        joinToken = mkOption {
          type = nullOr str;
          description = "Node join token";
          default = null;
        };
      };
    };
    pool = submodule {
      options = {
        kind = mkOption {
          description = "A role of nodes belonging to this pool in cluster.";
          type = enum ["controller" "single" "worker" "controller+worker"];
        };
        nodes = mkOption {
          description = "Nodes belonging to the pool";
          type = attrsOf node;
        };
      };
    };
  in {
    enable = mkEnableOption "";
    name = mkOption {
      description = "A name of cluster";
      type = str;
    };
    pools = mkOption {
      description = "Pools in cluster";
      type = attrsOf pool;
    };
    machine = {
      pool = mkOption {
        description = "A name of node pool";
        type = str;
      };
      node = mkOption {
        description = "Node name";
        type = str;
      };
    };
    apiHost = mkOption {
      type = str;
      description = "Kube apiserver host";
    };
    apiPort = mkOption {
      type = number;
      description = "Kube apiserver number";
    };
  };
  config = mkIf cfg.enable {
    networking = let
      poolName = cfg.machine.pool;
      pool = cfg.pools.${poolName};
      nodeName = cfg.machine.node;
      node = pool.nodes.${nodeName};
      public = node.network.public;
      private = node.network.private;
      publicVLAN =
        if public.vlan != null
        then {
          "${public.link}" = public.vlan;
        }
        else {};
      privateVLAN =
        if private.vlan != null
        then {
          "${private.link}" = private.vlan;
        }
        else {};
    in
      if private != null
      then {
        dhcpcd.enable = public.dhcp == true || private.dhcp == true;
        hostName = nodeName;
        domain = "${poolName}.${cfg.name}";
        nftables = {
          enable = true;
        };
        vlans = publicVLAN // privateVLAN;
        nameservers = ["1.1.1.1" "1.0.0.1"];
        interfaces = {
          ${public.link} = {
            useDHCP = public.dhcp == true;
            ipv4 = public.ipv4;
            ipv6 = public.ipv6;
          };
          ${private.link} = {
            useDHCP = private.dhcp == true;
            ipv4 = private.ipv4;
            ipv6 = private.ipv6;
          };
        };
        firewall = {
          # Only enable firewall for controller node, worker nodes and controller+worker are
          # managed by cilium host firewall.
          #
          # Reference for controller ports:
          # 2380 - etcd peers
          # 6443 - worker kube api
          # 9443 - controller api
          # 8132 - konnectivity server

          enable = pool.kind == "controller";
          allowPing = true;
          interfaces = {
            ${public.link} = {
              allowedTCPPorts = [6443]; # CLI access
            };
            ${private.link} = {
              allowedTCPPorts =
                [2380] #etcd peers
                ++ [6443 9443] # api for workers and controllers
                ++ [8132]; # konnectivity server
            };
          };
        };
      }
      else throw "to be implemented";
  };
}
