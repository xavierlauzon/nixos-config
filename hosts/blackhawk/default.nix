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
      encryption.enable = true;                 # This line can be removed if not needed as it is already default set by the role template
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
      hostname = "blackhawk";
      wired = {
       enable = true;
       type = "dynamic";
       mac = "58:47:ca:78:27:ab";
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
    role = "server";
    user = {
      root.enable = true;
      xavier.enable = true;
    };
  };
}
