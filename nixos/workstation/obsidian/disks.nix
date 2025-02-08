_: {
  disko.devices = {
    disk = {
      main = {
        device = "/dev/disk/by-id/nvme-WD_BLACK_SN770_2TB_24483J805376";
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
                  "/home/tcarrio" = {
                    # Parent subvolume is already mounted at /home
                  };
                  "/nix" = {
                    mountOptions = [ "compress=zstd" "noatime" ];
                    mountpoint = "/nix";
                  };
                  "/swap" = {
                    mountpoint = "/.swapvol";
                    swap = {
                      swapfile.size = "32GB";
                      swapfile2.size = "32GB";
                      swapfile2.path = "rel-path";
                    };
                  };
                };

                mountpoint = "/partition-root";
                swap = {
                  swapfile = {
                    size = "20M";
                  };
                  swapfile1 = {
                    size = "20M";
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
