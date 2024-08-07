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
      encryption.enable = false;                 # This line can be removed if not needed as it is already default set by the role template
      impermanence.enable = false;               # This line can be removed if not needed as it is already default set by the role template
      swap = {
        partition = "disk/by-partlabel/swap";
      };
    };
    hardware = {
      cpu = "amd";
      raid.enable = false;                      # This line can be removed if not needed as it is already default set by the role template
    };
    network = {
      hostname = "xavierdesktop";
      wired = {
       enable = true;
       type = "dynamic";
};
    };
    role = "server";
    user = {
      root.enable = true;
      xavier.enable = true;
    };
  };
}
