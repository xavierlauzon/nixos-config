{ config, lib, pkgs, ... }:
let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
  with lib;
{
  options = {
    host.user.sam = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = "Enable Sam";
      };
    };
  };

  config = mkIf config.host.user.sam.enable {
    users.users.sam = {
      isNormalUser = true;
      shell = pkgs.bashInteractive;
      uid = 4237;
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
        "input"
        "libvirtd"
        "lp"
        "mysql"
        "network"
        "podman"
      ];

      openssh.authorizedKeys.keys = [ (builtins.readFile ./ssh.pub) ];
      hashedPasswordFile = mkDefault config.sops.secrets.sam-password.path;
    };

    sops.secrets.sam-password = {
      sopsFile = mkDefault ../secrets.yaml;
      neededForUsers = mkDefault true;
    };
  };
}