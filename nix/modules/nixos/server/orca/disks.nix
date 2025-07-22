### ROOT DISKS:
# /dev/disk/by-id/ata-Corsair_CMFSSD-256D1_131801888FF00002 -> /dev/sdb

_:
{
  disko.devices.disk.main = {
    device = "/dev/disk/by-id/ata-Corsair_CMFSSD-256D1_131801888FF00002";
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
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
