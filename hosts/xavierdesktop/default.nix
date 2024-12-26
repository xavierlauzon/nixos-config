{ config, inputs, pkgs, ...}: {

  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    ../common
  ];

  host = {
    feature = {
      appimage.enable = true;
      gaming = {
        gamemode.enable = true;
        gamescope.enable = true;
        heroic.enable = true;
        steam.enable = true;
      };
      boot = {
        kernel = {
          parameters = [
            "video=DP-3:7680x2160@240"
            "video=DP-2:3840x1080@120"
          ];
          #modules = [
          #  "r8125"
          #];
        };

      };
      graphics = {
        enable = true;
        backend = "wayland";
        displayManager.manager = "greetd";
        windowManager.manager = "hyprland";
      };
      virtualization = {
        flatpak.enable = true;
        waydroid.enable = true;
        rke2.enable = false;
      };
    };
    filesystem = {
      encryption.enable = true;                 # This line can be removed if not needed as it is already default set by the role template
      impermanence.enable = true;               # This line can be removed if not needed as it is already default set by the role template
      swap = {
        partition = "disk/by-partlabel/swap";
      };
    };
    hardware = {
      cpu = "amd";
      gpu = "amd";
      keyboard.enable = true;
      raid.enable = true;
      sound = {
        server = "pipewire";
      };
    };
    network = {
      dns = {
        servers = [ "192.168.1.215" ];
        hostname = "xavierdesktop";
      };
      wired = {
        enable = true;
        interfaces = {
          xnet = {
           type = "static";
           ip = "192.168.2.10/22";
           gateway = "192.168.0.1";
           mac = "10:ff:e0:3a:3f:e6";
          };
        };
      };
      bridges = {
        br0 = {
          name = "br0";
          interfaces = [ "enp18s0" ];
           type = "static";
           ip = "192.168.2.10/22";
           gateway = "192.168.0.1";
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
    role = "desktop";
    user = {
      root.enable = true;
      xavier.enable = true;
      sam.enable = true;
    };
  };
  networking.nameservers = [ "192.168.1.215" ];
  sops.validateSopsFiles = false;
  nixpkgs.hostPlatform = "x86_64-linux";
  boot.extraModulePackages = with config.boot.kernelPackages; [ r8125 ];
  nixpkgs.config.allowBroken = true;
}
