{
  pkgs,
  config,
  lib,
  cfg,
  ...
}: let
  k0sVersionSuffix = "_${builtins.replaceStrings ["."] ["_"] cfg.version}";
  node_name = "${config.networking.hostName}.${config.networking.domain}";
  kubelet_args = "${
    if cfg.cloudProvider != null
    then "--cloud-provider=${cfg.cloudProvider}"
    else ""
  } ${
    if cfg.nodeIp != null
    then "--node-ip=${cfg.nodeIp}"
    else ""
  } --hostname-override=${node_name}";
  labels = builtins.map (label: "${label}=${cfg.labels.${label}}") (builtins.attrNames cfg.labels);
  taints = builtins.map (taint: "${taint.key}=${taint.value}:${taint.effect}") (
    if cfg.taints != null
    then cfg.taints
    else []
  );
  startK0s = joinToken:
    pkgs.writeShellScript "start_k0s.sh" ''
      set -e

      ${pkgs."k0s${k0sVersionSuffix}"}/bin/k0s ${cfg.mode} \
        ${
        if joinToken != null
        then "--token-file=/etc/k0s/token-file"
        else ""
      } ${
        if (cfg.mode == "worker")
        then ''          \
          --kubelet-extra-args='${kubelet_args}' ''
        else ""
      } ${
        if ((builtins.length labels) > 0)
        then ''          \
          --labels='${builtins.concatStringsSep "," labels}' ''
        else ""
      } ${
        if ((builtins.length taints) > 0)
        then ''          \
          --taints='${builtins.concatStringsSep "," taints}' ''
        else ""
      }'';
  k0sBundle =
    if (!cfg.airgap)
    then []
    else [pkgs."k0s_bundle${k0sVersionSuffix}"];
  bundles = k0sBundle ++ cfg.bundles;
  mkCerts = master:
    if master != null
    then ''
      set -e

      OPENSSL=${pkgs.openssl}/bin/openssl
      # This is a one time only thing, do not change already bootstrapped
      # certificates in running cluster. TODO: CA rotation.
      if [ ! -f /var/lib/k0s/pki/ca.key ]; then
        export LIFETIME=365
        mkdir -p /var/lib/k0s/pki/etcd
        cd /var/lib/k0s/pki
        cp "${builtins.toString master.ca."/var/lib/k0s/pki/ca".key}" ca.key
        cp "${builtins.toString master.ca."/var/lib/k0s/pki/ca".crt}" ca.crt
        chmod 640 ca.key ca.crt
        chown kube-apiserver ca.crt
        $OPENSSL genrsa -out sa.key 4096
        $OPENSSL rsa -in sa.key -outform PEM -pubout -out sa.pub
        cd ./etcd
        $OPENSSL genrsa -out ca.key 4096
        $OPENSSL req -x509 -new -nodes -key ca.key -sha256 -days $LIFETIME -out ca.crt -subj "/CN=Custom CA"
      fi
    ''
    else "";
  mkJoinToken = token:
    if token != null
    then ''
      set -e

      mkdir -p /etc/k0s
      cp "${builtins.toString cfg.joinToken}" /etc/k0s/token-file
    ''
    else "";
in {
  preStart = ''
    ${mkCerts cfg.master}
    ${mkJoinToken cfg.joinToken}
  '';
  # k0s does not seem to correctly import images, failing with some but k0s ctr does succeed.
  postStart = ''
    set -e

    if [ "x${cfg.mode}" == "xcontroller" ]; then
      exit 0
    fi
    until k0s ctr info; do
      echo "waiting for containerd"
      sleep 1
    done
    import () {
      until k0s ctr images import --digests --no-unpack --local $1; do
        sleep 1
      done
    }
    ${lib.concatStringsSep "\n" (
      lib.forEach bundles (bundle: "for img in ${bundle}/*; do import $img; done")
    )}
  '';
  path = [pkgs."k0s${k0sVersionSuffix}" pkgs.mount pkgs.util-linux pkgs.kmod];
  wants = ["network-online.target"];
  documentation = ["https://docs.k0sproject.io"];
  description = "k0s - Zero Friction Kubernetes";
  after = ["network-online.target"];
  startLimitIntervalSec = 5;
  startLimitBurst = 10;
  script = "${startK0s cfg.joinToken}";
  wantedBy = ["default.target"];
  unitConfig = {
    ConditionFileIsExecutable = "${pkgs."k0s${k0sVersionSuffix}"}/bin/k0s";
  };
  serviceConfig = {
    RestartSec = 120;
    Delegate = "yes";
    KillMode = "control-group";
    LimitCORE = "infinity";
    TasksMax = "infinity";
    TimeoutStartSec = "0";
    LimitNOFILE = 999999;
    Restart = "on-failure";
  };
}
