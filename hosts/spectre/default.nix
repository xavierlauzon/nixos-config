{ config, lib, inputs, pkgs, ...}: {

  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    ../common
  ];

  host = {
    container = {
      #coredns = {
      #  enable = true;
      #  image = {
      #    update = true;
      #  };
      #  logship = false;
      #  monitor = false;
      #  ports = {
      #    tcp = {
      #      enable = true;
      #      method = "address";
      #      address = "0.0.0.0";
      #    };
      #    udp = {
      #      enable = true;
      #      method = "address";
      #      address = "0.0.0.0";
      #    };
      #  };
      #};
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
        servers = [ "127.0.0.1" "9.9.9.9" ];
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
      herald = {
        enable = true;
        general = {
          log_level = "info";
        };
        api = {
          enabled = true;
          port = 4753;
          listen = [ "zt*" ];
        };
        domains = {
          domain01 = {
            profiles = {
              inputs = [ "docker_pub" ];
              outputs = [ "cf" ];
            };
            record = {
              target = "${config.host.network.dns.hostname}.${config.host.network.dns.domain}";
              type = "CNAME";
            };
          };
          domain02 = {
            profiles = {
              inputs = lib.mkForce [ "docker_int" "zerotier_network" ];
              outputs = [ "api" ];
            };
            record = {
              target = "${config.host.network.dns.hostname}.${config.host.network.dns.domain}";
              type = "CNAME";
            };
          };
        };
        outputs = {
          #api_aggregate = {
          #  type = "file";
          #  format = "zone";
          #  path = "/var/local/data/_system/coredns/data/%domain%.zone";
          #  default_ttl = 120;
          #  ns_records = [
          #    "aragorn.ns.cloudflare.com"
          #    "ruth.ns.cloudflare.com"
          #  ];
          #  soa = {
          #    primary_ns = "aragorn.ns.cloudflare.com";
          #    admin_email = "admin@%domain%";
          #    serial = "auto";
          #    refresh = 3600;
          #    retry = 900;
          #    expire = 604800;
          #    minimum = 300;
          #  };
          #};
          api_aggregate = {
            type = "dns";
            provider = "powerdns";
            api_host = "http://172.19.129.3:8081/api/v1";
            tls = {
              skip_verify = "false";
            };
            log_level = "verbose";
          };
        };
      };
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