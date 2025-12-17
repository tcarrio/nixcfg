### ROOT DISKS:
# /dev/disk/by-id/ata-Corsair_CMFSSD-256D1_131801888FF00002 -> /dev/sdb

_: {
  disko.devices = {
    disk = {
      nvme0 = {
        type = "disk";
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
              name = "root";
              size = "100%";
              content = {
                type = "filesystem";
                format = "xfs";
                mountOptions = [ "defaults" ];
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
