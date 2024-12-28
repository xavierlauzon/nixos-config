{ config, lib, pkgs, ... }:
let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
  with lib;
{
  options = {
    host.user.xavier = {
      enable = mkOption {
        default = true;
        type = with types; bool;
        description = "Enable Xavier";
      };
    };
  };

  config = mkIf config.host.user.xavier.enable {
    users.users.xavier = {
      isNormalUser = true;
      shell = pkgs.bashInteractive;
      uid = 4236;
      group = "users" ;
      extraGroups = [
        "wheel"
        "video"
        "audio"
      ] ++ ifTheyExist [
        "adbusers"
        "deluge"
        "dialout"
        "docker"
        "git"
        "i2c"
        "input"
        "libvirtd"
        "lp"
        "mysql"
        "network"
        "podman"
      ];

      openssh.authorizedKeys.keys = [ (builtins.readFile ./ssh.pub) ];
      hashedPasswordFile = mkDefault config.sops.secrets.xavier-password.path;
    };

    sops.secrets.xavier-password = {
      sopsFile = mkDefault ../secrets.yaml;
      neededForUsers = mkDefault true;
    };
  };
}
