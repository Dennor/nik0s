{
  cfg,
  config,
  pkgs,
}: {
  apiVersion = "k0s.k0sproject.io/v1beta1";
  kind = "ClusterConfig";
  metadata = {
    name = "k0s";
  };
  spec =
    {
      api =
        {
          inherit (cfg.api) address k0sApiPort port sans extraArgs;
        }
        // (
          if cfg.api.externalAddress != ""
          then {externalAddress = cfg.api.externalAddress;}
          else {}
        );
      controllerManager = {
        extraArgs =
          {}
          // (
            if (cfg.nodeCidr != "")
            then {
              node-cidr-mask-size-ipv4 = cfg.nodeCidr;
            }
            else {}
          )
          // (
            if (cfg.ipv6NodeCidr != "")
            then {
              node-cidr-mask-size-ipv6 = cfg.ipv6NodeCidr;
            }
            else {}
          );
      };

      extensions = {
        storage = {
          create_default_storage_class = false;
          type = "external_storage";
        };
      };
      installConfig = {
        users = {
          etcdUser = "etcd";
          kineUser = "kube-apiserver";
          konnectivityUser = "konnectivity-server";
          kubeAPIserverUser = "kube-apiserver";
          kubeSchedulerUser = "kube-scheduler";
        };
      };
      konnectivity = {
        adminPort = 8133;
        agentPort = 8132;
      };
      network = {
        dualStack = {
          enabled = cfg.ipv6ServiceCIDR != "" && cfg.ipv6PodCIDR != "";
          IPv6podCIDR = cfg.ipv6PodCIDR;
          IPv6serviceCIDR = cfg.ipv6ServiceCIDR;
        };
        clusterDomain = "cluster.local";
        kubeProxy = {
          disabled = true;
        };
        nodeLocalLoadBalancing = {
          disabled = true;
        };
        provider = "custom";
        serviceCIDR = cfg.serviceCIDR;
        podCIDR = cfg.podCIDR;
      };
      scheduler = {};
      storage = {
        etcd = {
          peerAddress =
            if cfg.storage.etcd.peerAddress != ""
            then cfg.storage.etcd.peerAddress
            else cfg.api.address;
        };
        type = "etcd";
      };
      telemetry = {
        enabled = true;
      };
    }
    // cfg.spec;
}
