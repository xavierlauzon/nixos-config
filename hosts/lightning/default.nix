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
      graphics = {
        displayManager.manager = "greetd";
        windowManager.manager = "hyprland";
      };
    };
    filesystem = {
      encryption.enable = true;
      impermanence.enable = true;
    };
    hardware = {
      cpu = "amd";
      gpu.type = "amd";
      printing.enable = false;
      raid.enable = false;
    };
    network = {
      dns = {
        servers = [ "192.168.191.2" "9.9.9.9" ];
        hostname = "lightning";
      };
      networkd = {
        enable = true;
      };
      interfaces = {
        eno1 = {
          mac = "10:ff:e0:c6:f7:dd";
        };
      };
      bridges = {
        public = {
          interfaces = [ "eno1" ];
          ipv4 = {
            enable = true;
            type = "dynamic";
          };
        };
      };
      vpn = {
        zerotier = {
          enable = true;
          networks = [
            "8d1c312afa3be618" # LM
            "e5cd7a9e1cfbc9a8" # XL
          ];
        };
      };
    };
    role = "desktop";
    user = {
      root.enable = true;
      sam.enable = true;
      xavier.enable = true;
    };
  };
  boot.extraModulePackages = with config.boot.kernelPackages; [ r8125 ];
  programs.gnupg.agent.enableSSHSupport = lib.mkForce false;
  hardware.amdgpu.overdrive.enable = true;
  programs.nix-ld.enable = true;
}
