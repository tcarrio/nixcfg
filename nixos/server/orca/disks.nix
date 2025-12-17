### ROOT DISKS:
# /dev/disk/by-id/ata-Corsair_CMFSSD-256D1_131801888FF00002 -> /dev/sdb

_: {
  disko.devices = {
    disk = {
      main = {
        device = "/dev/disk/by-id/ata-Corsair_CMFSSD-256D1_131801888FF00002";
        name = "primary-disk";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "500M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot/efi";
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
                  "/rootfs" = {
                    mountpoint = "/";
                  };
                  "/home" = {
                    mountOptions = [ "compress=zstd" ];
                    mountpoint = "/home";
                  };
                  "/nix" = {
                    mountOptions = [ "compress=zstd" "noatime" ];
                    mountpoint = "/nix";
                  };
                };

                mountpoint = "/partition-root";
                swap = {
                  swapfile = {
                    size = "32G";
                  };
                  swapfile1 = {
                    size = "32G";
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
