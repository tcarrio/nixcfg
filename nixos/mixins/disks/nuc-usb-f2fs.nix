{
  boot.loader.grub.devices = [ "/dev/sda" ];

  disko.devices = {
    disk = {
      sda = {
        # the same hardware, the same usb port... better be the same pci path.
        device = "/dev/disk/by-path/pci-0000:00:14.0-usb-0:1:1.0-scsi-0:0:0:0";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              end = "500M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              name = "root";
              end = "-0";
              content = {
                type = "filesystem";
                format = "f2fs";
                mountpoint = "/";
                extraArgs = [
                  "-O"
                  "extra_attr,inode_checksum,sb_checksum,compression"
                ];
                mountOptions = [
                  "compress_algorithm=zstd:6,compress_chksum,atgc,gc_merge,lazytime,nodiscard"
                ];
              };
            };
          };
        };
      };
    };
  };
}
