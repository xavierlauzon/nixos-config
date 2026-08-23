{ config, inputs, pkgs, lib, ...}: {

  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    ../common
  ];

  host = {
    application = {
      firejail.enable = true;
    };
    container = {
      #socket-proxy.enable = true;
      #traefik = {
      #  enable = false;
      #  logship = "false";
      #  monitor = "false";
      #};
      #traefik-internal = {
      #  enable = true;
      #  logship = "false";
      #  monitor = "false";
      #};
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
        waydroid.enable = false;
        rke2.enable = false;
      };
    };
    filesystem = {
      encryption.enable = true;                 # This line can be removed if not needed as it is already default set by the role template
      impermanence.enable = true;               # This line can be removed if not needed as it is already default set by the role template
    };
    hardware = {
      alientware.enable = true;
      cpu = "amd";
      gpu.type = "nvidia";
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
      networkd = {
        enable = true;
      };
      interfaces = {
        eno1 = {
          mac = "10:ff:e0:3a:3f:e6";
        };
      };
      bridges = {
        br0 = {
          interfaces = [ "eno1" ];
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
            "8d1c312afa3be618" # LM
            "e5cd7a9e1cfbc9a8"
            "dade4211851dff13" #im
            "dade421185de795d" #is
          ];
        };
      };
    };
    role = "desktop";
    user = {
      root.enable = true;
      xavier.enable = true;
    };
  };
  programs.gnupg.agent.enableSSHSupport = lib.mkForce false;
  hardware.amdgpu.overdrive.enable = true;
  programs.nix-ld.enable = true;
}
