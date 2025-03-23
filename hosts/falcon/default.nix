{ config, inputs, pkgs, ...}: {

  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    ../common
  ];

  host = {
    feature = {
    };
    filesystem = {
      encryption.enable = true;                 # This line can be removed if not needed as it is already default set by the role template
      impermanence.enable = true;               # This line can be removed if not needed as it is already default set by the role template
      swap = {
        partition = "disk/by-partlabel/swap";
      };
    };
    hardware = {
      cpu = "amd";
      raid.enable = true;                      # This line can be removed if not needed as it is already default set by the role template
    };
    network = {
      dns = {
        enable = true;
        servers = [ "192.168.1.215" ];
        stub = false;
        hostname = "falcon";
      };
      wired = {
        enable = true;
      };
      bridges = {
        br0 = {
          name = "br0";
          interfaces = [ "fc:34:97:b0:bb:9a" ];
          ipv4 = {
            enable = true;
            type = "static";
            addresses = [ "192.168.1.83/22" ];
            gateway = "192.168.0.1";
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
