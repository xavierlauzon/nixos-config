{ inputs, modulesPath, pkgs, ...}: {

  imports = [
    inputs.disko.nixosModules.disko
    ../../templates/disko/efi-btrfs-impermanence-swap.nix
    ../../templates/machine/virtd-vm.nix
    inputs.nur.nixosModules.nur

    ../common/global
  ];

  host = {
    feature = {
      graphics = {
        enable = false;
      };
    };
    filesystem = {
      btrfs.enable = true;
      encryption.enable = false;
      impermanence.enable = true;
    };
    hardware = {
      cpu = "vm-amd";
      raid.enable = true;
      sound = {
        enable = false;
        server = "pulseaudio";
      };
    };
    role = "vm";
    user = {
      dave.enable = true;
      root.enable = true;
    };
  };

  networking = {
    hostName = "disko";
  };
}
