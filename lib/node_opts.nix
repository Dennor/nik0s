{lib}:
with lib;
with types; {
  enable = mkEnableOption "";
  machine = {
    pool = mkOption {
      description = "A name of node pool";
      type = str;
    };
    node = mkOption {
      description = "Node name";
      type = str;
    };
  };
}
