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
  mkRaidDisk = name: dev: {
    type = "disk";
    device = dev;
    content = {
      type = "mdraid";
      inherit name;
    };
  };
  mkSsdRaidDisk = mkRaidDisk "md126";
  mkHddRaidDisk = mkRaidDisk "md127";
in
{
  disko.devices = {
    disk = {
      root = {
        type = "disk";
        device = "/dev/disk/by-id/ata-Corsair_CMFSSD-256D1_131801888FF00002";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              # for grub MBR
              type = "EF02";
            };
            root = {
              start = "1M";
              end = "-16G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
            swap = {
              size = "100%";
              content = {
                type = "swap";
                discardPolicy = "both";
                resumeDevice = true;
              };
            }; 
          };
        };
      };



      ssd-a = mkSsdRaidDisk "/dev/disk/by-id/ata-WDC_WDS120G2G0A-00JH30_19166R479906";
      ssd-b = mkSsdRaidDisk "/dev/disk/by-id/ata-WDC_WDS120G2G0A-00JH30_19166R479914";
      ssd-c = mkSsdRaidDisk "/dev/disk/by-id/ata-WDC_WDS120G2G0A-00JH30_19166R440706";
      ssd-d = mkSsdRaidDisk "/dev/disk/by-id/ata-WDC_WDS120G2G0A-00JH30_19166R471806";
      ssd-e = mkSsdRaidDisk "/dev/disk/by-id/ata-WDC_WDS120G2G0A-00JH30_19166R463915";
      ssd-f = mkSsdRaidDisk "/dev/disk/by-id/ata-WDC_WDS120G2G0A-00JH30_19166R458505";
      ssd-g = mkSsdRaidDisk "/dev/disk/by-id/ata-WDC_WDS120G2G0A-00JH30_19166R463905";
      ssd-h = mkSsdRaidDisk "/dev/disk/by-id/ata-WDC_WDS120G2G0A-00JH30_19166R451904";

      hdd-k = mkHddRaidDisk "/dev/disk/by-id/ata-WDC_WD10EFRX-68FYTN0_WD-WCC4J7TLCSNX";
      hdd-l = mkHddRaidDisk "/dev/disk/by-id/ata-WDC_WD10EFRX-68PJCN0_WD-WCC4J4XV4KDD";
      hdd-m = mkHddRaidDisk "/dev/disk/by-id/ata-WDC_WD10EFRX-68PJCN0_WD-WCC4J4XR859D";
      hdd-n = mkHddRaidDisk "/dev/disk/by-id/ata-WDC_WD10EFRX-68FYTN0_WD-WCC4J2TJHS9P";
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
