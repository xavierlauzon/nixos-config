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
#      swap = {
#        partition = "disk/by-partlabel/swap";
#      };
    };
    hardware = {
      cpu = "amd";
    };
    network = {
      dns = {
        enable = true;
        servers = [ "127.0.0.1" ];
        stub = false;
        hostname = "blackhawk";
      };
      wired = {
        enable = true;
        interfaces = {
          blackhawknet = {
           type = "static";
           ip = "192.168.1.215/22";
           gateway = "192.168.0.1";
           mac = "58:47:ca:78:27:ab";
          };
        };
      };
      bridges = {
        br0 = {
          name = "br0";
          interfaces = [ "enp3s0" ];
           type = "static";
           ip = "192.168.1.215/22";
           gateway = "192.168.0.1";
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
      firewall = {
        opensnitch.enable = false;
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
  networking.firewall.enable = false;
  nixpkgs.hostPlatform = "x86_64-linux";
}
