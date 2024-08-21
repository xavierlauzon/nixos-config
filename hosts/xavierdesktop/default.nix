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
        steam = {
          enable = true;
          protonGE = true;
        };
        lutris.enable = true;

      };
      boot = {
        kernel = {
          parameters = [
            "quiet"
            "video=DP-3:7680x2160@240"
          ];
          modules = [
            "v4l2loopback"
          ];
        };
      };
      graphics = {
        enable = true;
        backend = "wayland";
        displayManager.manager = "sddm";
        windowManager.manager = "hyprland";
      };
      virtualization = {
        flatpak.enable = true;
        waydroid.enable = true;
      };
    };
    filesystem = {
      encryption.enable = false;                 # This line can be removed if not needed as it is already default set by the role template
      impermanence.enable = false;               # This line can be removed if not needed as it is already default set by the role template
      swap = {
        partition = "disk/by-partlabel/swap";
      };
    };
    hardware = {
      cpu = "amd";
      gpu = "amd";
      keyboard.enable = true;
      raid.enable = false;
      sound = {
        server = "pipewire";
      };
    };
    network = {
      hostname = "xavierdesktop";
      wired = {
       enable = true;
       type = "dynamic";
       mac = "f0:2f:74:17:2c:c2";
      };
    };
    role = "desktop";
    user = {
      root.enable = true;
      xavier.enable = true;
    };
  };
  boot.extraModulePackages = with config.boot.kernelPackages; [
     v4l2loopback.out
  ];
}
