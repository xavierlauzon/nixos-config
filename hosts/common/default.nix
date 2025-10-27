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
      comma.enable = mkDefault true;
      coreutils.enable = mkDefault true;
      curl.enable = mkDefault true;
      diceware.enable = mkDefault true;
      direnv.enable = mkDefault true;
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
      liquidprompt.enable = mkDefault true;
      lsof.enable = mkDefault true;
      mtr.enable = mkDefault true;
      nano.enable = mkDefault true;
      ncdu.enable = mkDefault true;
      openssl.enable = mkDefault true;
      pciutils.enable = mkDefault true;
      psmisc.enable = mkDefault true;
      rclone.enable = mkDefault true;
      ripgrep.enable = mkDefault true;
      rsync.enable = mkDefault true;
      strace.enable = mkDefault true;
      tmux.enable = mkDefault true;
      tree.enable = mkDefault true;
      wget.enable = mkDefault true;
      zoxide.enable = mkDefault true;
    };
    feature = {
      home-manager.enable = mkDefault true;
      secrets.enable = mkDefault true;
    };
    network.dns = {
      domain = mkDefault "lauzon.xyz";
      search = mkDefault [ "lauzon.xyz" ];
    };
    service = {
      herald = {
        general = {
          log_level = mkDefault "verbose";
        };
        inputs = {
          docker_pub = mkDefault {
            type = "docker";
            api_url = "unix:///var/run/docker.sock";
            expose_containers = true;
            process_existing = true;
            record_remove_on_stop = true;
            filter = [
              {
                type = "label";
                conditions = [
                  {
                    key = "traefik.proxy.visibility";
                    value = "public";
                  }
                  {
                    key = "traefik.proxy.visibility";
                    value = "any";
                    logic = "or";
                  }
                ];
              }
            ];
          };
          docker_int = mkDefault {
            type = "docker";
            api_url = "unix:///var/run/docker.sock";
            expose_containers = true;
            process_existing = true;
            record_remove_on_stop = true;
            filter = [
              {
                type = "label";
                conditions = [
                  {
                    key = "traefik.proxy.visibility";
                    value = "internal";
                  }
                  {
                    key = "traefik.proxy.visibility";
                    value = "any";
                    logic = "or";
                  }
                ];
              }
            ];
          };
        };
        domains = {
          domain01 = mkDefault {
            profiles = {
              inputs = [ "docker_pub" ];
              outputs = [ "cf" ];
            };
            record = {
              target = "${config.host.network.dns.hostname}.${config.host.network.dns.domain}";
              type = "CNAME";
            };
          };
          domain02 = mkDefault {
            profiles = {
              inputs = [ "docker_int" ];
              outputs = [ "api" ];
            };
            record = {
              target = "${config.host.network.dns.hostname}.${config.host.network.dns.domain}";
              type = "CNAME";
            };
          };
        };
        outputs = {
          cf = {
            type = "dns";
            provider = "cloudflare";
          };
          api = {
            type = "remote";
          };
        };
      };
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
