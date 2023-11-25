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
          address = cfg.api.address;
          k0sApiPort = cfg.api.k0sApiPort;
          port = cfg.api.port;
          sans = cfg.api.sans;
        }
        // (
          if cfg.api.externalAddress != ""
          then {externalAddress = cfg.api.externalAddress;}
          else {}
        );
      controllerManager = {};
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
