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
    };
    filesystem = {
      encryption.enable = true;                 # This line can be removed if not needed as it is already default set by the role template
      impermanence.enable = true;               # This line can be removed if not needed as it is already default set by the role template
    };
    hardware = {
      cpu = "amd";
      gpu.type = "amd";
      raid.enable = true;
    };
    network = {
      dns = {
        enable = true;
        servers = [ "192.168.1.215" ];
        stub = false;
        hostname = "spectre";
      };
      networkd = {
        enable = true;
      };
      interfaces = {
        eno1 = {
          mac = "38:05:25:37:3c:91";
        };
      };
      bridges = {
        public = {
          interfaces = [ "eno1" ];
          mac = "38:05:25:37:3c:91";
          ipv4 = {
            enable = true;
            type = "static";
            addresses = [ "192.168.2.5/22" ];
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
      firewall = {
        opensnitch.enable = false;
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
    device = "/dev/disk/by-uuid/2ca5d88d-9775-4ed5-b6aa-ab26b4e086dd";
    fsType = "btrfs";
    options = [ "subvol=data" "compress=zstd:3" "noatime" "space_cache=v2" "autodefrag" ];
  };
  boot.kernelParams = [ "amd_iommu=pgtbl_v2" ]; # Remove in kernel 7.0
}