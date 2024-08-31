{ config, inputs, pkgs, ...}: {

  imports = [
    ../common
  ];

  host = {
    feature = {
      appimage.enable = true;
      virtualization = {
        flatpak.enable = true;
        waydroid.enable = true;
      };
    };
    network = {
      hostname = "xaviermacbook";
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
    role = "darwin";
    user = {
      root.enable = true;
      xavier.enable = true;
    };
  };
}
