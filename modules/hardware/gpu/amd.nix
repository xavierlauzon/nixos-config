{ config, lib, pkgs, ... }:
with lib;
let
  device = config.host.hardware ;
in {
  config = mkIf (device.gpu == "amd" || device.gpu == "hybrid-amd" || device.gpu == "integrated-amd")  {
    #boot = lib.mkMerge [
    #  (lib.mkIf (lib.versionAtLeast pkgs.linux.version "6.2") {
    #    kernelModules = [
    #      "amdgpu"
    #    ];
    #    kernelParams = mkIf (device.gpu == "integrated-amd")
    #    [
    #      "amdgpu.sg_display=0"
    #    ];
    #  })
    #];

    host.feature.boot.kernel.parameters = mkIf (device.gpu == "integrated-amd") [
      "amdgpu.sg_display=0"
    ];

    host.feature.boot.kernel.modules = mkIf (device.gpu == "amd") [
      "amdgpu"
    ];

    hardware.graphics.extraPackages = with pkgs; [
      amdvlk
      rocmPackages.clr
      rocmPackages.clr.icd
    ];

    hardware.amdgpu.initrd.enable = true;
    hardware.amdgpu.amdvlk.enable = true;

    services.xserver.videoDrivers = [
      "modesetting"
    ];
  };
}