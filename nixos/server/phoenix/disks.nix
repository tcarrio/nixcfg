### ROOT DISKS:
# /dev/disk/by-id/ata-Samsung_SSD_860_EVO_500GB_S598NJ0MB47097R -> /dev/sda

_: {
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        name = "primary-disk";
        device = "/dev/disk/by-id/ata-Samsung_SSD_860_EVO_500GB_S598NJ0MB47097R";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              name = "boot";
              size = "1M";
              type = "EF02";
            };
            esp = {
              name = "ESP";
              size = "1024M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountOptions = [
                  "defaults"
                  "umask=0077"
                ];
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";

                # Subvolumes must set a mountpoint in order to be mounted,
                # unless their parent is mounted
                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                  };
                  "@home" = {
                    mountOptions = [ "compress=zstd" ];
                    mountpoint = "/home";
                  };
                  "@nix" = {
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                    mountpoint = "/nix";
                  };
                  "@swap" = {
                    mountpoint = "/.swapvol";
                    swap = {
                      swapfile.size = "32G";
                    };
                  };
                };

                mountpoint = "/partition-root";
              };
            };
          };
        };
      };
    };
  };
}
