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
        gamemode.enable = false;
        gamescope.enable = false;
        heroic.enable = false;
        steam = {
          enable = false;
          protonGE = false;
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
      };
    };
    role = "desktop";
    user = {
      root.enable = true;
      xavier.enable = true;
    };
  };
}
