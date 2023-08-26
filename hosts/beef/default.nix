{ pkgs, inputs, ...}: {

  imports = [
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-cpu-amd-pstate
    inputs.hardware.nixosModules.common-cpu-amd-raphael-igpu
    inputs.hardware.nixosModules.common-pc-hdd
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.nur.nixosModules.nur
    inputs.vscode-server.nixosModules.default
    ./hardware-configuration.nix

    ../common/global
    ../common/optional/gui/x.nix

    ../../users/dave
    ../../users/root
  ];

  boot = {
    initrd.luks.devices = {
      "pool0_0" = {
         allowDiscards = true;
         bypassWorkqueues = true;
      };
      "pool0_1" = {
         allowDiscards = true;
         bypassWorkqueues = true;
      };
    };

    kernelParams = [
      "quiet"
      "video=DP-3:2560x1440@120"
      "video=DP-2:2560x1440@120"
      "video=HDMI-1:2560x1440@120"
      "amdgpu.sg_display=0"
    ];
  };

  host = {
    feature = {
      boot = {
        efi.enable = true;
        graphical.enable = true;
      };
      development = {
        crosscompilation = {
          enable = true;
          platform = "aarch64-linux";
        };
      };
      gaming = {
        enable = true;
        steam.enable = true;
      };
      powermanagement.enable = true;
      virtualization = {
        docker = {
          enable = true;
        };
        virtd = {
          client.enable = true;
          daemon.enable = true;
        };
      };
    };
    filesystem = {
      btrfs.enable = true;
      encryption.enable = true;
      impermanence.enable = true;
    };
    hardware = {
      bluetooth.enable = true;
      graphics = {
        acceleration.enable = true;
      };
      printing.enable = true;
      wireless.enable = true;
      raid.enable = true;
    };
    network = {
      firewall = {
        fail2ban.enable = true;
        opensnitch.enable = false;
      };
      vpn = {
        tailscale.enable = true;
      };
    };
    service = {
       vscode_server.enable = true;
    };
  };

  networking = {
    hostName = "beef";
    networkmanager= {
      enable = true;
    };
  };

  system.stateVersion = "23.11";
}
