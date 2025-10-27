{ config, inputs, pkgs, ...}: {

  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    ../common
  ];

  host = {
    feature = {
      virtualization = {
        docker.enable = false;
        rke2 = {
          enable = true;
          cluster = {
            bootstrapMode = "initial";
            nodeName = "paveway";
            nodeIP = "10.0.0.1";
          };
          security = {
            tls = {
              san = [
                "cluster.lumae.net"
                "10.0.0.1"
               ];
            };
          };
          advanced = {
            debug = false;
            disable = [ "rke2-ingress-nginx" "rke2-traefik" "rke2-canal" ];
            extraConfig = [ "--disable-kube-proxy" ];
            configPath = "/persist/etc/rke2/config.yaml";
            dataDir = "/persist/var/lib/rke2";
          };
        };
      };
    };
    filesystem = {
      encryption.enable = true;
      impermanence.enable = true;
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
        hostname = "paveway";
      };
      networkd = {
        enable = true;
      };
      routeTables = {
        "vrack-pool" = 200;
      };
      interfaces = {
        eno1 = {
          mac = "9c:6b:00:96:f8:64";
        };
        vrack = {
          mac = "9c:6b:00:96:f9:53";
          ipv4 = {
            enable = true;
            type = "static";
            addresses = [ "10.0.0.1/24" ];
          };
          routes = [
            {
              Destination = "0.0.0.0/0";          # Default route
              Gateway = "15.235.18.6";            # VRack gateway
              Table = "vrack-pool";               # Custom routing table
              OnLink = true;                      # Gateway is directly reachable
            }
          ];
          routingPolicyRules = [
            {
              From = "15.235.18.0/29";            # Traffic from VRack subnet
              Table = "vrack-pool";               # Use VRack routing table
              Priority = 1000;                    # Rule priority
            }
          ];
        };
      };
      bridges = {
        public = {
          interfaces = [ "eno1" ];
          mac = "9c:6b:00:96:f8:64";
          ipv4 = {
            enable = true;
            type = "static";
            addresses = [ "148.113.221.47/32" ];
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
  networking = {
    firewall.enable = false;
    nftables = {
      enable = true;
      tables = {
        filter = {
          family = "inet";
          content = ''
            chain input {
              type filter hook input priority filter; policy drop;

              # Allow loopback
              iifname "lo" accept

              # Allow ALL RFC1918 traffic
              ip saddr { 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 } accept
              ip6 saddr { fc00::/7, fe80::/10 } accept

              # Allow established connections
              ct state { established, related } accept

              # Allow specific ports on public interface only
              iifname "public" tcp dport { 80, 443, 9993, 9994, 30120, 30110, 30122, 30130, 40120 } accept
              iifname "public" udp dport { 443, 9993, 9994, 30120, 30110, 30122, 30130, 40120 } accept

              # Trust all non-public interfaces completely
              iifname != "public" accept

              # Log and drop everything else
              counter drop
            }
          '';
        };
      };
    };
  };
  boot.kernel.sysctl = {
    "vm.nr_hugepages" = "2048";
  };
}
