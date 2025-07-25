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
            bootstrapMode = "server";
            nodeName = "hellfire";
            nodeIP = "10.0.0.2";
            serverURL = "https://10.0.0.1:9345";
          };
          advanced = {
            debug = false;
            disable = [ "rke2-ingress-nginx" "rke2-traefik" "rke2-canal" ];
            extraConfig = [ "--disable-kube-proxy" ];
            cisHardening = false;
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
        hostname = "hellfire";
      };
      networkd = {
        enable = true;
      };
      routeTables = {
        "vrack-pool" = 200;
      };
      interfaces = {
        eno1 = {
          mac = "9c:6b:00:96:f6:7f";
        };
        vrack = {
          mac = "9c:6b:00:96:fb:bf";
          ipv4 = {
            enable = true;
            type = "static";
            addresses = [ "10.0.0.2/24" ];
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
          mac = "9c:6b:00:96:f6:7f";
          arpAccept = true;
          ipv4 = {
            enable = true;
            type = "static";
            addresses = [ "148.113.221.56/32" ];
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
  networking.firewall = {
    enable = false;
    allowedTCPPorts = [ 80 443 30120 30110 30122 30130 40120 ];
    allowedUDPPorts = [ 443 30120 30110 30122 30130 40120 ];
    trustedInterfaces = [ "lo" "vrack" "zt+" "lxc+" "cilium+" "veth" ];
  };
}
