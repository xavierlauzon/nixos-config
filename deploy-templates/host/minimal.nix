{ config, inputs, pkgs, ...}: {

  imports = [
    inputs.disko.nixosModules.disko
    ./disks.nix
    ../common
  ];

  host = {
    feature = {
    };
    filesystem = {
      swap = {
        partition = "disk/by-partlabel/swap";
      };
    };
    hardware = {
      cpu = "amd";
    };
    network = {
      hostname = "minimal-template";
    };
    role = "minimal";
    user = {
      root.enable = true;
      xavier.enable = true;
    };
  };
}
