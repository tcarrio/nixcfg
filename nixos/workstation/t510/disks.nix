{ disks ? [ "/dev/sda" ], ... }: {
  disko.devices = {
    disk = {
      main = {
        device = "ata-Samsung_SSD_850_PRO_512GB_S250NXAH211618D";
        name = "Samsung 500GB 2.5\" SATA";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            # compatibility for BIOS 
            boot = {
              size = "1M";
              type = "EF02";
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
            swap = {
              size = "16G";
              content = {
                type = "swap";
                discardPolicy = "both";
                resumeDevice = true; # resume from hiberation from this device
              };
            };
          };
        };
      };
    };
  };
}

