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
        enable = false;
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
      appimage.enable = true;
      gaming = {
        gamemode.enable = true;
        gamescope.enable = true;
        heroic.enable = true;
        steam.enable = true;
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
      printing.enable = false;
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
      };
      bridges = {
        br0 = {
          name = "br0";
          interfaces = [ "10:ff:e0:3a:3f:e6" ];
          ipv4 = {
            enable = true;
            type = "static";
            addresses = [ "192.168.2.10/22" ];
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
  boot.extraModulePackages = with config.boot.kernelPackages; [ r8125 ];
  nixpkgs.config.allowBroken = true;
}
