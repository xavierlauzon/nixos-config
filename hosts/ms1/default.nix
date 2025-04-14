{ config, inputs, pkgs, ...}: {

  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    ../common
  ];

  host = {
    container = {
      socket-proxy.enable = true;
      traefik = {
        enable = true;
        logship = "false";
        monitor = "false";
      };
      traefik-internal = {
        enable = true;
        logship = "false";
        monitor = "false";
      };
    };
    feature = {
      boot = {
        initrd = {
          modules = [ "xhci_pci" "ehci_pci" "uhci_hcd" "hpsa" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];
        };
        loader = "grub";
      };
      virtualization = {
        rke2 = {
          enable = false;
          cluster = {
            bootstrapMode = "initial";
            nodeName = "ms1";
            nodeIP = "192.168.191.2";
          };
          networking = {
            clusterDomain = "cluster.xavierlauzon.com";
          };
          security = {
            tls = {
              san = [
                "ms1.xavierlauzon.com"
                "cluster.xavierlauzon.com"
               ];
            };
          };
        };
      };
    };
    filesystem = {
      encryption.enable = true;                 # This line can be removed if not needed as it is already default set by the role template
      impermanence.enable = true;               # This line can be removed if not needed as it is already default set by the role template
      swap = {
        type = "partition";
      };
    };
    hardware = {
      cpu = "intel";
      raid.enable = true;                      # This line can be removed if not needed as it is already default set by the role template
    };
    network = {
      dns = {
        enable = true;
        servers = [ "192.168.191.1" "1.1.1.1" ];
        stub = false;
        hostname = "ms1";
      };
      wired = {
        enable = true;
      };
      bridges = {
        br0 = {
          name = "publicbr0";
          interfaces = [ "94:57:a5:6b:1c:04" ];
          ipv4 = {
            enable = true;
            type = "static";
            addresses = [ "10.0.0.150/24" ];
            gateway = "10.0.0.1";
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
    user = {
      root.enable = true;
      xavier.enable = true;
      sam.enable = true;
    };
    service = {
      vscode_server.enable = true;
    };
  };
}
