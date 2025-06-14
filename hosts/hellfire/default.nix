{ config, inputs, pkgs, ...}: {

  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    ../common
  ];

  host = {
    container = {
      socket-proxy.enable = true;
      traefik = {
        enable = true;
        logship = "false";
        monitor = "false";
      };
      traefik-internal = {
        enable = true;
        logship = "false";
        monitor = "false";
      };
    };
    feature = {
    };
    filesystem = {
      encryption.enable = true;
      impermanence.enable = true;
      swap = {
        partition = "disk/by-partlabel/swap";
      };
    };
    hardware = {
      cpu = "amd";
      raid.enable = true;
    };
    network = {
      dns = {
        enable = true;
        servers = [ "1.1.1.1" ];
        stub = false;
        hostname = "hellfire";
      };
      networkd = {
        enable = true;
      };
      interfaces = {
        eno1 = {
          mac = "9c:6b:00:96:f6:7f";
        };
      };
      bridges = {
        public = {
          interfaces = [ "eno1" ];
          mac = "9c:6b:00:96:f6:7f";
          ipv4 = {
            enable = true;
            type = "static";
            addresses = [ "148.113.221.56/32" ];
            gateway = "100.64.0.1";
          };
        };
      };
      vpn = {
        zerotier = {
          enable = true;
          networks = [
            "e5cd7a9e1cfbc9a8"
          ];
          port = 9993;
        };
      };
    };
    role = "server";
    service = {
      vscode_server.enable = true;
    };
    user = {
      root.enable = true;
      xavier.enable = true;
      sam.enable = true;
    };
  };
}
