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
      impermanence.enable = false;               # This line can be removed if not needed as it is already default set by the role template
      swap = {
        partition = "disk/by-partlabel/swap";
      };
    };
    hardware = {
      cpu = "amd";
      raid.enable = false;                      # This line can be removed if not needed as it is already default set by the role template
    };
    network = {
      hostname = "blackhawk";
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
    user = {
      root.enable = true;
      xavier.enable = true;
      sam.enable = true;
    };
  };
  networking.firewall.enable = false;
  networking.nameservers = [ "127.0.0.1" ];
  services.resolved.extraConfig = "DNSStubListener=no";
}
