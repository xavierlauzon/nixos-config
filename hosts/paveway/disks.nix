let
  rawdisk1 = "/dev/nvme0n1";
  rawdisk2 = "/dev/nvme1n1";
  cryptdisk1 = "pool0_0";
  cryptdisk2 = "pool0_1";
in {
  disko.devices = {
    disk = {
      ${rawdisk1} = {
        device = "${rawdisk1}";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              label = "EFI";
              name = "ESP";
              size = "1024M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            swap = {
              label = "swap";
              size = "64G"; # SWAP - Do not Delete this comment
              content = {
                type = "swap";
                resumeDevice = true;
              };
            };
            luks = {
              label = "enc_" + "${cryptdisk1}";
              size = "100%";
              content = {
                type = "luks";
                name = "${cryptdisk1}";
                extraOpenArgs = [ "--allow-discards" ];
                passwordFile = "/tmp/secret.key"; # Interactive
              };
            };
          };
        };
      };
      ${rawdisk2} = {
        device = "${rawdisk2}";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            luks = {
              label = "enc_" + "${cryptdisk2}";
              size = "100%";
              content = {
                type = "luks";
                name = "${cryptdisk2}";
                extraOpenArgs = [ "--allow-discards" ];
                # if you want to use the key for interactive login be sure there is no trailing newline
                # for example use `echo -n "password" > /tmp/secret.key`
                passwordFile = "/tmp/secret.key"; # Interactive
                # or file based
                #settings.keyFile = "/tmp/secret.key";
                #additionalKeyFiles = ["/tmp/additionalSecret.key"];
                content = {
                  type = "btrfs";
                  extraArgs = [
                    "-f"
                    "-m raid1 -d raid1"
                    "/dev/mapper/${cryptdisk1}"
                    "/dev/mapper/${cryptdisk2}"
                  ];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/root-blank" = {
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/home" = {
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/home/active" = {
                      mountpoint = "/home";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/home/snapshots" = {
                      mountpoint = "/home/.snapshots";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/persist" = {
                      mountOptions = [ "noatime" ];
                    };
                    "/persist/active" = {
                      mountpoint = "/persist";
                      mountOptions = [ "noatime" ];
                    };
                    "/persist/snapshots" = {
                      mountpoint = "/persist/.snapshots";
                      mountOptions = [ "noatime" ];
                    };
                    "/var_lib_docker" = {
                      mountpoint = "/var/lib/docker";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/var_local" = {
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/var_local/active" = {
                      mountpoint = "/var/local";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/var_local/snapshots" = {
                      mountpoint = "/var/local/.snapshots";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/var_log" = {
                      mountpoint = "/var/log";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
