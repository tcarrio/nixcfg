# /dev/disk/by-id/ata-WDC_WD3200AAKS-00L9A0_WD-WCAV21751761 -> /dev/sda
# /dev/disk/by-id/ata-Corsair_CMFSSD-256D1_131801888FF00002 -> /dev/sdb
# /dev/disk/by-id/ata-WDC_WD10EFRX-68FYTN0_WD-WCC4J7TLCSNX -> /dev/sdc
# /dev/disk/by-id/ata-WDC_WD10EFRX-68PJCN0_WD-WCC4J4XV4KDD -> /dev/sdd
# /dev/disk/by-id/ata-WDC_WD10EFRX-68PJCN0_WD-WCC4J4XR859D -> /dev/sde
# /dev/disk/by-id/ata-WDC_WD10EFRX-68FYTN0_WD-WCC4J2TJHS9P -> /dev/sdf
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
      main = {
        device = "/dev/disk/by-id/ata-Corsair_CMFSSD-256D1_131801888FF00002";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              # for grub MBR
              type = "EF02";
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

      ssd-0 = mkSsdRaidDisk "/dev/disk/by-id/ata-WDC_WDS120G2G0A-00JH30_19166R479906";
      ssd-1 = mkSsdRaidDisk "/dev/disk/by-id/ata-WDC_WDS120G2G0A-00JH30_19166R479914";
      ssd-2 = mkSsdRaidDisk "/dev/disk/by-id/ata-WDC_WDS120G2G0A-00JH30_19166R440706";
      ssd-3 = mkSsdRaidDisk "/dev/disk/by-id/ata-WDC_WDS120G2G0A-00JH30_19166R471806";
      ssd-4 = mkSsdRaidDisk "/dev/disk/by-id/ata-WDC_WDS120G2G0A-00JH30_19166R463915";
      ssd-5 = mkSsdRaidDisk "/dev/disk/by-id/ata-WDC_WDS120G2G0A-00JH30_19166R458505";
      ssd-6 = mkSsdRaidDisk "/dev/disk/by-id/ata-WDC_WDS120G2G0A-00JH30_19166R463905";
      ssd-7 = mkSsdRaidDisk "/dev/disk/by-id/ata-WDC_WDS120G2G0A-00JH30_19166R451904";

      hdd-0 = mkHddRaidDisk "/dev/disk/by-id/ata-WDC_WD10EFRX-68FYTN0_WD-WCC4J7TLCSNX";
      hdd-1 = mkHddRaidDisk "/dev/disk/by-id/ata-WDC_WD10EFRX-68PJCN0_WD-WCC4J4XV4KDD";
      hdd-2 = mkHddRaidDisk "/dev/disk/by-id/ata-WDC_WD10EFRX-68PJCN0_WD-WCC4J4XR859D";
      hdd-3 = mkHddRaidDisk "/dev/disk/by-id/ata-WDC_WD10EFRX-68FYTN0_WD-WCC4J2TJHS9P";
    };

    mdadm = {
      # SSD array
      md126 = {
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

      # HDD array
      md127 = {
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
  };
}
