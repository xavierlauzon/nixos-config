{ config, inputs, pkgs, ...}: {

  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    ../common
  ];

  host = {
    feature = {
      virtualization = {
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
            disable = [ "rke2-ingress-nginx" "rke2-traefik" ];
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
  networking.firewall.enable = false;
}
