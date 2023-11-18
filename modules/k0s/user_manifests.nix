{
  yaml,
  lib,
  cfg,
}:
with lib;
  if cfg.mode == "controller" && (builtins.length cfg.manifests) > 0
  then {
    userManifests = let
      manifestPath = "/var/lib/k0s/manifests/user_manifests";
      manifestYAML = "${manifestPath}/manifests.yaml";
      mkResourceYAMLs = manifest:
        builtins.map (res:
          if builtins.isPath res
          then res
          else yaml.generate "resource.yaml" res)
        manifest;
      mkResourceScript = yaml: ''
        echo "---" >> ${manifestYAML}
        cat ${yaml} >> ${manifestYAML}
      '';
      mkManifest = manifestYAMLs: builtins.map mkResourceScript (builtins.concatLists manifestYAMLs);
    in
      stringAfter ["var"] ''
        mkdir -p ${manifestPath}
        rm -f ${manifestYAML}

        ${builtins.concatStringsSep "\n" (mkManifest (builtins.map mkResourceYAMLs cfg.manifests))}
      '';
  }
  else {}
