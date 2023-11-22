{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.k0s-cilium;
  image = {
    useDigest = false;
  };
in {
  options = {
    k0s-cilium = with types; {
      enable = mkEnableOption "";
      podCIDR = mkOption {
        description = "CIDR to for pods";
        type = nullOr (listOf str);
      };
      k8sServiceHost = mkOption {
        description = "Kube apiserver address";
        type = str;
      };
      k8sServicePort = mkOption {
        description = "Kube apiserver port";
        type = number;
      };
      directRoutingDevice = mkOption {
        type = nullOr str;
        description = "Optional direct routing device for cilium";
      };
      operator = {
        replicas = mkOption {
          description = "Number of operator replcias";
          type = number;
          default = 1;
        };
      };
      values = mkOption {
        description = "A set of values which can override the defaults";
        type = attrs;
        default = {};
      };
      kubeconfig = mkOption {
        description = "Optional path to kubeconfig";
        type = str;
        default = "";
      };
    };
  };
  config = mkIf cfg.enable {
    helm = {
      cilium = {
        enable = true;
        kubeconfig = cfg.kubeconfig;
        chart = pkgs.ciliumChart;
        namespace = "kube-system";
        values = {
          ipam =
            if cfg.podCIDR != null
            then {
              operator = {
                clusterPoolIPv4PodCIDRList = cfg.podCIDR;
              };
            }
            else {};
          cgroup = {
            hostRoot = "/sys/fs/cgroup";
          };
          bpf = {
            masquerade = true;
          };
          nodePort =
            if cfg.directRoutingDevice != null
            then {
              directRoutingDevice = cfg.directRoutingDevice;
            }
            else {};
          authentication = {
            mutual = {
              spire = {
                enabled = true;
                install = {
                  enabled = true;
                  # Override spire images to not include digest
                  agent = {
                    image = "ghcr.io/spiffe/spire-agent:1.6.3";
                  };
                  server = {
                    image = "ghcr.io/spiffe/spire-server:1.6.3";
                  };
                };
              };
            };
          };
          kubeProxyReplacement = true;
          k8sServiceHost = cfg.k8sServiceHost;
          k8sServicePort = cfg.k8sServicePort;
          encryption = {
            enabled = true;
            type = "wireguard";
            nodeEncryption = true;
          };
          hostFirewall = {
            enabled = true;
          };
          operator = {
            replicas = cfg.operator.replicas;
          };
          ingressController = {
            enabled = true;
            loadBalancerMode = "shared";
            l7 = {
              backend = "envoy";
            };
          };
          remoteNodeIdentity = true;
          priorityClassName = "system-node-critical";
          libModulesPath = "/run/current-system/kernel-modules/lib/modules";
          # We're already using an airgaped bundle, do not use digest because the it seems to fail
          inherit image;
          certgen = {inherit image;};
          metrics = {
            relay = {inherit image;};
          };
          ui = {
            backend = {inherit image;};
            frontedn = {inherit image;};
          };
          envoy = {inherit image;};
          etcd = {inherit image;};
          operator = {inherit image;};
          preflight = {inherit image;};
          clustermesg = {
            apiserver = {
              inherit image;
              etcd = {
                inherit image;
              };
              kvstoremesg = {
                inherit image;
              };
            };
          };
        } // cfg.values;
      };
    };
  };
}
