### HDD DISKS:
# /dev/disk/by-id/ata-WDC_WD10EFRX-68FYTN0_WD-WCC4J7TLCSNX -> /dev/sdc
# /dev/disk/by-id/ata-WDC_WD10EFRX-68PJCN0_WD-WCC4J4XV4KDD -> /dev/sdd
# /dev/disk/by-id/ata-WDC_WD10EFRX-68PJCN0_WD-WCC4J4XR859D -> /dev/sde
# /dev/disk/by-id/ata-WDC_WD10EFRX-68FYTN0_WD-WCC4J2TJHS9P -> /dev/sdf

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
      hdd-1 = mkHddRaidDisk "/dev/disk/by-id/ata-WDC_WD10EFRX-68PJCN0_WD-WCC4J4XV4KDD";
      hdd-2 = mkHddRaidDisk "/dev/disk/by-id/ata-WDC_WD10EFRX-68PJCN0_WD-WCC4J4XR859D";
      hdd-3 = mkHddRaidDisk "/dev/disk/by-id/ata-WDC_WD10EFRX-68FYTN0_WD-WCC4J2TJHS9P";
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
              type = "filesystem";
              format = "ext4";
              mountpoint = "/storage/beorn";
            };
          };
        };
      };
    };
  };
}
