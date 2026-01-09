{ config, inputs, pkgs, ...}: {

  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    ../common
  ];

  host = {
    container = {
      socket-proxy = {
        enable = true;
        logship = false;
        monitor = false;
      };
      traefik = {
        enable = true;
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
      cpu = "amd";
      gpu = "amd";
      raid.enable = false;
    };
    network = {
      dns = {
        enable = true;
        servers = [ "192.168.1.215" ];
        stub = false;
        hostname = "falcon";
      };
      networkd = {
        enable = true;
      };
      interfaces = {
        eno1pn0 = {
          mac = "7c:c2:55:e3:dc:6f";
        };
      };
      bridges = {
        public = {
          interfaces = [ "eno1pn0" ];
          ipv4 = {
            enable = true;
            type = "static";
            addresses = [ "192.168.1.172/22" ];
            gateway = "192.168.0.1";
          };
        };
      };
      vpn = {
        zerotier = {
          enable = true;
          networks = [
            "743993800f23a70e" # Lab
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
  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-label/bulk-storage";
    fsType = "btrfs";
    options = [ "subvol=data" "compress=zstd:1" "noatime" "space_cache=v2" "discard=async" ];
  };
   #new label for disk = "bulk-storage" uuid = "32ea10ca-089a-4eae-8851-4054689f1848"
}
