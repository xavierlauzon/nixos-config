{ config, lib, pkgs, modulesPath, ... }:

{
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "uas" "sd_mod" "rtsx_usb_sdmmc"];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/18e470a3-4942-4e28-8c26-9e9d1663dae7";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };

  boot.initrd.luks.devices."pool0_0".device = "/dev/disk/by-uuid/d1dd4e01-d147-41af-91b4-e736bf96bf78";

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/18e470a3-4942-4e28-8c26-9e9d1663dae7";
      fsType = "btrfs";
      options = [ "subvol=home/active" ];
    };

  fileSystems."/home/.snapshots" =
    { device = "/dev/disk/by-uuid/18e470a3-4942-4e28-8c26-9e9d1663dae7";
      fsType = "btrfs";
      options = [ "subvol=home/snapshots" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/18e470a3-4942-4e28-8c26-9e9d1663dae7";
      fsType = "btrfs";
      options = [ "subvol=nix" ];
    };

  fileSystems."/persist" =
    { device = "/dev/disk/by-uuid/18e470a3-4942-4e28-8c26-9e9d1663dae7";
      fsType = "btrfs";
      options = [ "subvol=persist/active" ];
    };

  fileSystems."/persist/.snapshots" =
    { device = "/dev/disk/by-uuid/18e470a3-4942-4e28-8c26-9e9d1663dae7";
      fsType = "btrfs";
      options = [ "subvol=persist/snapshots" ];
    };

  fileSystems."/var/local" =
    { device = "/dev/disk/by-uuid/18e470a3-4942-4e28-8c26-9e9d1663dae7";
      fsType = "btrfs";
      options = [ "subvol=var_local/active" ];
    };

  fileSystems."/var/local/.snapshots" =
    { device = "/dev/disk/by-uuid/18e470a3-4942-4e28-8c26-9e9d1663dae7";
      fsType = "btrfs";
      options = [ "subvol=var_local/snapshots" ];
    };

  fileSystems."/var/log" =
    { device = "/dev/disk/by-uuid/18e470a3-4942-4e28-8c26-9e9d1663dae7";
      fsType = "btrfs";
      options = [ "subvol=var_log" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/D899-F17E";
      fsType = "vfat";
    };

  nixpkgs.hostPlatform = "x86_64-linux";
}
