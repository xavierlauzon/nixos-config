{ inputs, pkgs, ...}: {

  imports = [
    inputs.nur.nixosModules.nur

    ./hardware-configuration.nix
    ../common/global
  ];


  host = {
    filesystem = {
      encryption.enable = false;
      swap = {
        partition = "disk/by-uuid/c49b427e-53a4-4224-9c3a-d0d9daf2ba72";
      };
    };
    hardware = {
      cpu = "vm-intel";
    };
    role = "server";
    service = {
      vscode_server.enable = true;
    };
    network = {
      hostname = "butcher";
      ip = "192.168.137.5/24";
      gateway = "192.168.137.1";
      mac = "2A:BE:78:89:51:A5";
    };
    user = {
      dave.enable = true;
      root.enable = false;
    };
  };
}
