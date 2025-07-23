{ config, inputs, outputs, lib, pkgs, self, ... }:
  with lib;
{
  imports = [
    inputs.nixos-modules.nixosModules
    inputs.nix-networkd.nixosModules.default
    ./locale.nix
    ./nix.nix
    ../../users
  ];

  boot = {
    kernel.sysctl = {
      "vm.dirty_ratio" = mkDefault 6;                   # sync disk when buffer reach 6% of memory
    };
    kernelPackages = pkgs.linuxPackages_latest;         # Latest kernel
  };

  environment = {
    defaultPackages = [];                               # Don't install any default programs, force everything
    enableAllTerminfo = mkDefault false;
  };

  hardware.enableRedistributableFirmware = mkDefault true;
  host = {
    application = {
      bash.enable = mkDefault true;
      bind.enable = mkDefault true;
      binutils.enable = mkDefault true;
      coreutils.enable = mkDefault true;
      curl.enable = mkDefault true;
      diceware.enable = mkDefault true;
      dust.enable = mkDefault true;
      e2fsprogs.enable = mkDefault true;
      fzf.enable = mkDefault true;
      git.enable = mkDefault true;
      htop.enable = mkDefault true;
      iftop.enable = mkDefault true;
      inetutils.enable = mkDefault true;
      iotop.enable = mkDefault true;
      kitty.enable = mkDefault true;
      less.enable = mkDefault true;
      links.enable = mkDefault true;
      lsof.enable = mkDefault true;
      mtr.enable = mkDefault true;
      nano.enable = mkDefault true;
      ncdu.enable = mkDefault true;
      openssl.enable = mkDefault true;
      pciutils.enable = mkDefault true;
      psmisc.enable = mkDefault true;
      rsync.enable = mkDefault true;
      strace.enable = mkDefault true;
      tmux.enable = mkDefault true;
      tree.enable = mkDefault true;
      wget.enable = mkDefault true;
    };
    feature = {
      home-manager.enable = mkDefault true;
      secrets.enable = mkDefault true;
    };
    network.dns = {
      domain = mkDefault "xavierlauzon.com";
      search = mkDefault [ "xavierlauzon.com" ];
    };
    service = {
      logrotate = {
        enable = mkDefault true;
      };
      ssh = {
        enable = mkDefault true;
        harden = mkDefault true;
      };
    };
    configDir = mkForce self.outPath;
  };

  security = {
    pam.loginLimits = [
      # Increase open file limit for sudoers
      {
        domain = "@wheel";
        item = "nofile";
        type = "soft";
        value = "524288";
      }
      {
        domain = "@wheel";
        item = "nofile";
        type = "hard";
        value = "1048576";
      }
    ];
    sudo.wheelNeedsPassword = mkDefault false;
  };
  services.fstrim.enable = mkDefault true;
  users.mutableUsers = mkDefault false;

  ## TODO: IMPLEMENT ELSEWHERE
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;
}
