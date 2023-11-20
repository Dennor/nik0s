{
  config,
  options,
  lib,
  ...
}:
with lib; let
  cfg = config.cluster;
in {
  imports = [./base_cluster.nix];
  # Describes which node in cluster this config represents.
  options.cluster = import ../lib/node_opts.nix {inherit lib;};
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
