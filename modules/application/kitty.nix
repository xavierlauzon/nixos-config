{config, lib, pkgs, ...}:

let
  cfg = config.host.application.kitty;
in
  with lib;
{
  options = {
    host.application.kitty = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enables kitty";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      kitty
    ];
  };
}