{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.k0s;
  yaml = pkgs.formats.yaml {};
  etc = {};
in {
  options.services.k0s = with types; {
    enable = mkEnableOption "Enable k0s service";
    mode = mkOption {
      type = enum ["controller" "worker"];
      default = "controller";
    };
    api = {
      externalAddress = mkOption {
        type = str;
        default = "";
        description = "The loadbalancer address (for k0s controllers running behind a loadbalancer). Configures all cluster components to connect to this address and also configures this address for use when joining new nodes to the cluster.";
      };
      address = mkOption {
        type = str;
        description = "Local address on which to bind an API. Also serves as one of the addresses pushed on the k0s create service certificate on the API. Defaults to first non-local address found on the node.";
      };
      k0sApiPort = mkOption {
        type = number;
        default = 9443;
        description = "Custom port for k0s-api server to listen on (default: 9443)";
      };
      port = mkOption {
        type = number;
        default = 6443;
        description = "Custom port for kube-api server to listen on (default: 6443)";
      };
      sans = mkOption {
        type = listOf str;
        description = "List of additional addresses to push to API servers serving the certificate.";
        default = [];
      };
      extraArgs = mkOption {
        description = "Extra arguments to pass to kube-apiserver";
        type = attrsOf str;
        default = {};
      };
    };
    storage = {
      etcd = {
        peerAddress = mkOption {
          type = str;
          description = "Node address used for etcd cluster peering.";
          default = "";
        };
      };
    };
    manifests = mkOption {
      type = listOf (listOf (either path attrs));
      description = "(Optional) Map of manifests to bootstrap with cluster. <manifest>: [ <resources> ]";
      default = [];
    };
    serviceCIDR = mkOption {
      type = str;
      description = "Service subnet";
      default = "10.96.0.0/12";
    };
    podCIDR = mkOption {
      type = str;
      description = "Pod subnet";
      default = "10.244.0.0/16";
    };
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
      type = nullOr (either path str);
      description = "Join token for node";
      default = null;
    };
    cloudProvider = mkOption {
      type = nullOr (enum ["external"]);
      description = "Configure cloud provider for in kubelet";
      default = null;
    };
    nodeIp = mkOption {
      description = "Kubelete nodeIP";
      type = str;
      default = "";
    };
    bundles = mkOption {
      description = "Airgap packages to include in worker node";
      type = listOf package;
      default = [];
    };
    spec = mkOption {
      description = "An additional configuration for k0s that will update the default values for spec. Refer to https://docs.k0sproject.io/v1.28.4+k0s.0/configuration/#spec-key-detail";
      type = attrs;
      default = {};
    };
    labels = mkOption {
      description = "Set of labels to add to node. Applies only for worker nodes.";
      type = attrsOf str;
      default = {};
    };
    taints = mkOption {
      description = "List of taints that will be added to the node";
      type = nullOr (listOf (submodule {
        options = {
          key = mkOption {
            description = "Key identifing taint";
            type = str;
          };
          value = mkOption {
            description = "Value of a taint";
            type = str;
          };
          effect = mkOption {
            description = "Taint effect";
            type = enum ["NoExecute" "NoSchedule" "PreferNoSchedule"];
          };
        };
      }));
      default = null;
    };
    version = mkOption {
      description = "k0s package version. This is required argument to make sure that there's no accidental update. It should be one of k0s versions in packages without the +k0s suffix. This flake will only support 4 latest k0s minor versions starting from 1.28.3.";
      type = str;
    };
    airgap = mkOption {
      type = bool;
      description = "If true, will bundle k0s images";
      default = false;
    };
  };

  config = mkIf cfg.enable {
    boot.kernel.sysctl."net.bridge.bridge-nf-call-iptables" = mkDefault 1;
    boot.kernelModules = ["br_netfilter" "nf_conntrack" "ip_tables" "overlay"];
    environment.variables = {
      CONTAINER_RUNTIME_ENDPOINT = "unix:///run/k0s/containerd.sock";
    };
    system.activationScripts = import ./user_manifests.nix {inherit yaml lib cfg;};
    systemd.services.k0s = import ./systemd.nix {inherit pkgs config cfg lib;};
    environment.etc =
      if (cfg.mode == "controller")
      then
        {
          "k0s/k0s.yaml" = {
            source = yaml.generate "k0s.yaml" (import ./k0s_yaml.nix {inherit cfg config pkgs;});
            mode = "0400";
          };
        }
        // etc
      else etc;
    users = import ./users.nix {inherit cfg lib;};
  };
}
