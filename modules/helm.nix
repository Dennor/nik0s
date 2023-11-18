{
  config,
  options,
  lib,
  pkgs,
  ...
}:
with lib;
with types; let
  yaml = pkgs.formats.yaml {};
  release = submodule {
    options = {
      enable = mkEnableOption "";
      chart = mkOption {
        description = "Chart to install. Either a string or derivation";
        type = either str package;
      };
      kubeconfig = mkOption {
        description = "Optional path to kubeconfig";
        type = str;
        default = "";
      };
      namespace = mkOption {
        description = "Optional release namespace";
        type = str;
        default = "";
      };
      version = mkOption {
        description = "Optional chart version for non packaged charts";
        type = str;
        default = "";
      };
      repository = mkOption {
        description = "Optional chart repository for non packaged charts";
        type = str;
        default = "";
      };
      values = mkOption {
        description = "Optional chart values. Either path or attribute set";
        type = nullOr (either path attrs);
        default = null;
      };
      set = mkOption {
        description = "List of name value pairs to set";
        type = listOf (submodule {
          options = {
            name = {
              description = "A name of variable to set in helm style";
              type = str;
            };
            value = {
              description = "A value of variable to set in helm style";
              type = str;
            };
          };
        });
        default = [];
      };
    };
  };
  releases = config.helm;
in {
  options.helm = mkOption {
    type = attrsOf release;
    description = "List of helm releases managed as services";
    default = {};
  };
  config.systemd.services = mapAttrs (name: release: let
    environment = filterAttrs (n: v: v != "") {
      KUBECONFIG = release.kubeconfig;
    };
    set = concatStringsSep " " (builtins.map (v: "\"--set=${v.name}=${v.value}\"") release.set);
    values =
      if (builtins.isPath release.values) || release.values == null
      then release.values
      else yaml.generate "values.yaml" release.values;
    valuesOpt =
      if release.values != null
      then "\"--values=${values}\""
      else "";
    namespace =
      if release.namespace != ""
      then "\"--namespace=${release.namespace}\""
      else "";
    startRelease = pkgs.writeShellScript "helm_release.sh" ''
      helm upgrade ${namespace} --install --create-namespace ${name} ${release.chart} ${set} ${(_: break _) valuesOpt}
    '';
  in {
    inherit environment;
    enable = true;
    description = "Installs or upgrades helm release ${name}";
    path = [pkgs.kubernetes-helm];
    serviceConfig = {
      RestartSec = 5;
      Restart = "on-failure";
      Type = "oneshot";
    };
    wantedBy = ["default.target"];
    script = "${startRelease}";
  }) (filterAttrs (n: v: v.enable == true) releases);
}
