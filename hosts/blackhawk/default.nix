{ config, lib, inputs, pkgs, ...}: {

  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    ../common
  ];

  host = {
    container = {
      socket-proxy.enable = true;
      traefik = {
        enable = false;
        logship = false;
        monitor = false;
        ports = {
            http = {
              enable = true;
            };
            https = {
              enable = true;
            };
            http3 = {
              enable = true;
            };
        };
      };
      traefik-internal = {
        enable = true;
        logship = false;
        monitor = false;
        ports = {
            http = {
              enable = true;
              zerotierNetwork = "e5cd7a9e1cfbc9a8";
            };
            https = {
              enable = true;
              zerotierNetwork = "e5cd7a9e1cfbc9a8";
            };
            http3 = {
              enable = true;
              zerotierNetwork = "e5cd7a9e1cfbc9a8";
            };
        };
      };
    };
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
      networkd = {
        enable = true;
      };
      interfaces = {
        eno1 = {
          mac = "58:47:ca:78:27:ab";
        };
      };
      bridges = {
        public = {
          interfaces = [ "eno1" ];
          mac = "9c:6b:00:96:f8:64";
          ipv4 = {
            enable = true;
            type = "static";
            addresses = [ "192.168.1.215/22" ];
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
  networking.firewall.trustedInterfaces = [ "br-+" "zt+" ]; # Temp fix allowing containers to query public IP of host
  nixpkgs.hostPlatform = "x86_64-linux";
  programs.nix-ld.enable = true;
  programs.nix-ld.package = pkgs.nix-ld-rs;
}
