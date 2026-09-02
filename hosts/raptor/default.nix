{ config, inputs, pkgs, lib, ...}: {

  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    ../common
  ];

  system.stateVersion = "26.05";

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
    };
    filesystem = {
      encryption.enable = true;                 # This line can be removed if not needed as it is already default set by the role template
      impermanence.enable = true;               # This line can be removed if not needed as it is already default set by the role template
    };
    hardware = {
      cpu = "arm";
      gpu.type = "nvidia";
      dgx-spark.enable = true;
      raid.enable = false;
    };
    network = {
      dns = {
        enable = true;
        servers = [ "192.168.1.215" ];
        stub = false;
        hostname = "raptor";
      };
      networkd = {
        enable = true;
      };
      interfaces = {
        enP7s7 = {
          mac = "30:c5:99:3f:5e:a2 ";
        };
      };
      bridges = {
        public = {
          interfaces = [ "enP7s7" ];
          ipv4 = {
            enable = true;
            type = "static";
            addresses = [ "192.168.1.82/22" ];
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
        };
      };
    };
    role = "server";
    service = {
      herald.enable = true;
      vscode_server.enable = true;
    };
    user = {
      root.enable = true;
      xavier.enable = true;
      sam.enable = true;
    };
  };
  networking.firewall.trustedInterfaces = [ "br-+" "zt+" ];

  ## Testing
  hardware.nvidia-container-toolkit.enable = true;

  programs.nix-ld.enable = true;
  programs.nix-ld.package = pkgs.nix-ld;
}
