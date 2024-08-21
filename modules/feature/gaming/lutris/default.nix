{config, lib, pkgs, ...}:

let
  cfg = config.host.feature.gaming.lutris;
in
  with lib;
{
  options = {
    host.feature.gaming.lutris = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Open source video game launcher";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      lutris
      wineasio
      winetricks
      wineWowPackages.stable
    ];

    programs.lutris = {
          package = pkgs.lutris.override {
            extraPkgs = (pkgs: with pkgs; [
              gamemode
            ]);
    };
  };
}
