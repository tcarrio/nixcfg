### ROOT DISKS:
# /dev/disk/by-id/ata-Corsair_CMFSSD-256D1_131801888FF00002 -> /dev/sdb

_: {
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        name = "primary-disk";
        device = "/dev/disk/by-id/ata-Corsair_CMFSSD-256D1_131801888FF00002";
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

                # ⚠️ DESTRUCTIVE ACTION.
                # This will destroy and re-create partitions on the device!
                extraArgs = [ "-f" ];

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
                    mountOptions = [ "compress=zstd" "noatime" ];
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
