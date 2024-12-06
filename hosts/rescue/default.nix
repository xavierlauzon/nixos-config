{ config, inputs, outputs, lib, pkgs, self, ... }:
  with lib;
{
  imports = [
    inputs.disko.nixosModules.disko
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
    ../common
  ];

  host = {
    feature = {
      secrets.enable = mkForce false;
    };
    filesystem = {
      encryption.enable = false;
      impermanence.enable = false;
      swap = {
        enable = false;
      };
    };
    hardware = {
      cpu = "amd";
      raid.enable = false;
    };
    network = {
      dns = {
        enable = true;
        servers = [ "1.1.1.1" ];
        hostname = "rescue";
      };
      wired.enable = false;
      vpn = {
        zerotier = {
          enable = false;
          networks = [
            "e5cd7a9e1cfbc9a8"
          ];
          port = 9993;
        };
      };
      firewall = {
        opensnitch.enable = false;
      };
    };
    role = "server";
    service = {
      vscode_server.enable = false;
      logrotate.enable = false;
    };
    user = {
      root.enable = true;
      xavier.enable = true;
      sam.enable = true;
    };
  };
  networking = {
    dhcpcd.enable = true;
    useDHCP = true;
    firewall.logRefusedConnections = lib.mkForce false;
  };
  boot.supportedFilesystems = lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" ];
  system.stateVersion = lib.mkForce "25.05";
  systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];
}
