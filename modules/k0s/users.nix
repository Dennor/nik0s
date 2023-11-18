{
  cfg,
  lib,
}:
with lib;
  mkIf (cfg.mode == "controller") {
    users = {
      etcd = {
        isNormalUser = false;
        isSystemUser = true;
        home = "/tool/data";
        group = "etcd";
      };
      kube-apiserver = {
        isNormalUser = false;
        isSystemUser = true;
        home = "/tool/data";
        group = "kube-apiserver";
      };
      konnectivity-server = {
        isNormalUser = false;
        isSystemUser = true;
        home = "/tool/data";
        group = "konnectivity-server";
      };
      kube-scheduler = {
        isNormalUser = false;
        isSystemUser = true;
        home = "/tool/data";
        group = "kube-scheduler";
      };
    };
    groups = {
      etcd = {};
      kube-apiserver = {};
      konnectivity-server = {};
      kube-scheduler = {};
    };
  }
