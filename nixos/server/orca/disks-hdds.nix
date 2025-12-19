### HDD DISKS:
# /dev/disk/by-id/ata-WDC_WD10EFRX-68FYTN0_WD-WCC4J7TLCSNX -> /dev/sdb
# /dev/disk/by-id/ata-WDC_WD10EFRX-68FYTN0_WD-WCC4J2TJHS9P -> /dev/sdc
# /dev/disk/by-id/ata-WDC_WD10EFRX-68PJCN0_WD-WCC4J4XV4KDD -> /dev/sdd
# /dev/disk/by-id/ata-WDC_WD10EFRX-68PJCN0_WD-WCC4J4XR859D -> /dev/sde
# /dev/disk/by-id/ata-WDC_WD10EFRX-68FYTN0_WD-WCC4J0KV5L3F -> /dev/sdf
_:
let
  mkRaidDisk = name: device: {
    inherit device;
    type = "disk";
    content = {
      inherit name;
      type = "mdraid";
    };
  };

  mkHddRaidDisk = mkRaidDisk "md127";
in
{
  disko.devices = {
    disk = {
      hdd-0 = mkHddRaidDisk "/dev/disk/by-id/ata-WDC_WD10EFRX-68FYTN0_WD-WCC4J7TLCSNX";
      hdd-1 = mkHddRaidDisk "/dev/disk/by-id/ata-WDC_WD10EFRX-68FYTN0_WD-WCC4J2TJHS9P";
      hdd-2 = mkHddRaidDisk "/dev/disk/by-id/ata-WDC_WD10EFRX-68PJCN0_WD-WCC4J4XV4KDD";
      hdd-3 = mkHddRaidDisk "/dev/disk/by-id/ata-WDC_WD10EFRX-68PJCN0_WD-WCC4J4XR859D";
      hdd-4 = mkHddRaidDisk "/dev/disk/by-id/ata-WDC_WD10EFRX-68FYTN0_WD-WCC4J0KV5L3F";
    };

    mdadm.md127 = {
      type = "mdadm";
      level = 5;
      content = {
        type = "gpt";
        partitions = {
          primary = {
            size = "100%";
            content = {
              type = "btrfs";

              subvolumes = {
                "@media" = {
                  mountpoint = "/var/lib/media";
                  mountOptions = [ "compress=zstd" ];
                };
              };

              mountpoint = "/md-hdd-array";
            };
          };
        };
      };
    };
  };
}
