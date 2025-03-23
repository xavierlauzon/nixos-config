{ config, inputs, pkgs, ...}: {

  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    ../common
  ];

  host = {
    feature = {
      boot = {
        initrd = {
          modules = [ "xhci_pci" "ehci_pci" "uhci_hcd" "hpsa" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];
        };
        loader = "grub";
      };
      virtualization = {
        rke2 = {
          enable = true;
          cluster = {
            bootstrapMode = "server";
            nodeName = "ms2";
            nodeIP = "192.168.191.3";
            serverURL = "https://cluster.xavierlauzon.com:9345";
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
        servers = [ "192.168.191.1" ];
        stub = false;
        hostname = "ms2";
      };
      wired = {
        enable = true;
      };
      bridges = {
        br0 = {
          name = "br0";
          interfaces = [ "94:57:a5:52:6d:2c" ];
          ipv4 = {
            enable = true;
            type = "static";
            addresses =  [ "10.0.0.151/24" ];
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
#      firewall = {
#        opensnitch.enable = false;
#      };
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
  networking.firewall.enable = false;
  nixpkgs.hostPlatform = "x86_64-linux";

}
