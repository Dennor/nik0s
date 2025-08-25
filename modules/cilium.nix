{
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
  kind = config.cluster.pools.${config.cluster.machine.pool}.kind;
in {
  options = {
    k0s-cilium = with types; {
      enable = mkEnableOption "";
      k8sServiceHost = mkOption {
        description = "Kube apiserver address";
        type = str;
      };
      k8sServicePort = mkOption {
        description = "Kube apiserver port";
        type = number;
      };
      operator = {
        replicas = mkOption {
          description = "Number of operator replcias";
          type = number;
          default = 1;
        };
      };
      spire = mkOption {
        description = "Enable spire authentication";
        type = bool;
        default = false;
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
      chart = mkOption {
        description = "Optional chart package";
        type = package;
        default = pkgs.ciliumChart;
      };
    };
  };
  config = mkIf cfg.enable {
    boot.kernelModules = mkIf (kind == "worker") [
      "nft_compat"
      "xt_socket"
      "xt_mark"
      "xt_set"
      "xt_TPROXY"
      "xt_CT"
      "xt_comment"
      "xt_multiport"
      "xt_conntrack"
      "vxlan"
      "sch_ingress"
      "sha1-ssse3"
      "algif_hash"
      "ip_set"
      "ip_set_hash_ip"
      "sch_fq"
      "wireguard"
      "nft_chain_nat"
      "cls_bpf"
      "veth"
      "xfrm_algo"
      "xfrm_user"
      "ip6table_filter"
      "ip6table_mangle"
      "ip6table_raw"
      "ip6_tables"
      "iptable_filter"
      "iptable_mangle"
      "iptable_nat"
      "iptable_raw"
      "ip_tables"
    ];
    helm = mkIf (kind == "controller") {
      cilium = {
        inherit (cfg) chart;
        enable = true;
        kubeconfig = cfg.kubeconfig;
        namespace = "kube-system";
        values =
          {
            cgroup = {
              hostRoot = "/sys/fs/cgroup";
            };
            bpf = {
              masquerade = true;
            };
            authentication = {
              mutual = {
                spire = {
                  enabled = cfg.spire;
                  install = {
                    initImage = image;
                    # Override spire images to not include digest
                    agent = {
                      inherit image;
                    };
                    server = {
                      inherit image;
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
          }
          // cfg.values;
      };
    };
  };
}
