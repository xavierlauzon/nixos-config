{ config, inputs, pkgs, ...}: {

  imports = [
    inputs.disko.nixosModules.disko
    ../common
  ];

  host = {
    feature = {
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
  };
}
