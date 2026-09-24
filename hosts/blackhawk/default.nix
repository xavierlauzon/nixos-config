{ config, lib, inputs, pkgs, ...}: {

  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    ../common
  ];

  host = {
    container = {
      socket-proxy = {
        enable = true;
        image = {
          update = true;
        };
        logship = false;
        monitor = false;
      };
      traefik = {
        enable = true;
        image = {
          update = true;
        };
        logship = false;
        monitor = false;
        ports = {
            http = {
              enable = true;
              excludeInterfacePattern = "docker|veth|br-|zt";
            };
            https = {
              enable = true;
              excludeInterfacePattern = "docker|veth|br-|zt";
            };
            http3 = {
              enable = true;
              excludeInterfacePattern = "docker|veth|br-|zt";
            };
        };
      };
      traefik-internal = {
        enable = true;
        image = {
          update = true;
        };
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
      graphics = {
        displayManager.manager = "greetd";
        windowManager.manager = "hyprland";
      };
    };
    filesystem = {
    };
    hardware = {
      cpu = "amd";
      gpu.type = "amd";
    };
    network = {
      dns = {
        enable = true;
        servers = [ "192.168.2.5" ];
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
            "8d1c312afa3be618"
            "e5cd7a9e1cfbc9a8"
          ];
        };
      };
    };
    role = "desktop";
    service = {
      herald = {
        enable = true;
      };
      vscode_server.enable = true;
    };
    user = {
      root.enable = true;
      xavier.enable = true;
      sam.enable = true;
    };
  };
  networking.firewall.trustedInterfaces = [ "br-+" "zt+" ]; # Temp fix allowing containers to query public IP of host
  #programs.nix-ld.enable = true;
  #programs.nix-ld.package = pkgs.nix-ld;
  hardware.amdgpu.overdrive.enable = true;

}