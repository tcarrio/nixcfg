### SSD DISKS:
# /dev/disk/by-id/ata-WDC_WDS120G2G0A-00JH30_19166R479906 -> /dev/sdh
# /dev/disk/by-id/ata-WDC_WDS120G2G0A-00JH30_19166R479914 -> /dev/sdi
# /dev/disk/by-id/ata-WDC_WDS120G2G0A-00JH30_19166R440706 -> /dev/sdj
# /dev/disk/by-id/ata-WDC_WDS120G2G0A-00JH30_19166R471806 -> /dev/sdk
# /dev/disk/by-id/ata-WDC_WDS120G2G0A-00JH30_19166R463915 -> /dev/sdl
# /dev/disk/by-id/ata-WDC_WDS120G2G0A-00JH30_19166R458505 -> /dev/sdm
# /dev/disk/by-id/ata-WDC_WDS120G2G0A-00JH30_19166R463905 -> /dev/sdn
# /dev/disk/by-id/ata-WDC_WDS120G2G0A-00JH30_19166R451904 -> /dev/sdo

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
  mkSsdRaidDisk = mkRaidDisk "md126";
  mkHddRaidDisk = mkRaidDisk "md127";
in
{
  disko.devices = {
    disk = {
      ssd-0 = mkSsdRaidDisk "/dev/disk/by-id/ata-WDC_WDS120G2G0A-00JH30_19166R479906";
      ssd-1 = mkSsdRaidDisk "/dev/disk/by-id/ata-WDC_WDS120G2G0A-00JH30_19166R479914";
      ssd-2 = mkSsdRaidDisk "/dev/disk/by-id/ata-WDC_WDS120G2G0A-00JH30_19166R440706";
      ssd-3 = mkSsdRaidDisk "/dev/disk/by-id/ata-WDC_WDS120G2G0A-00JH30_19166R471806";
      ssd-4 = mkSsdRaidDisk "/dev/disk/by-id/ata-WDC_WDS120G2G0A-00JH30_19166R463915";
      ssd-5 = mkSsdRaidDisk "/dev/disk/by-id/ata-WDC_WDS120G2G0A-00JH30_19166R458505";
      ssd-6 = mkSsdRaidDisk "/dev/disk/by-id/ata-WDC_WDS120G2G0A-00JH30_19166R463905";
      ssd-7 = mkSsdRaidDisk "/dev/disk/by-id/ata-WDC_WDS120G2G0A-00JH30_19166R451904";
    };

    mdadm.md126 = {
      type = "mdadm";
      level = 6;
      content = {
        type = "gpt";
        partitions = {
          primary = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/storage/thorin";
            };
          };
        };
      };
    };
  };
}
