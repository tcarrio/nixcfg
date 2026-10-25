### ROOT DISKS - ZFS L2ARC Cache Device
# /dev/disk/by-id/ata-Corsair_CMFSSD-256D1_131801888FF00002 -> /dev/sdb
### HDD DISKS - ZFS RAIDZ2 Configuration
# /dev/disk/by-id/ata-WDC_WD10EFRX-68FYTN0_WD-WCC4J7TLCSNX -> /dev/sdb
# /dev/disk/by-id/ata-WDC_WD10EFRX-68FYTN0_WD-WCC4J2TJHS9P -> /dev/sdc
# /dev/disk/by-id/ata-WDC_WD10EFRX-68PJCN0_WD-WCC4J4XV4KDD -> /dev/sdd
# /dev/disk/by-id/ata-WDC_WD10EFRX-68PJCN0_WD-WCC4J4XR859D -> /dev/sde
# /dev/disk/by-id/ata-WDC_WD10EFRX-68FYTN0_WD-WCC4J0KV5L3F -> /dev/sdf
_:
let
  type = "gpt";

  fillZfsPartition = {
    size = "100%";
    content = {
      type = "zfs";
      pool = "zroot";
    };
  };
  mkZfsDisk = device: {
    type = "disk";
    inherit device;
    content = {
      inherit type;
      partitions = {
        zfs = fillZfsPartition;
      };
    };
  };
in
{
  disko.devices = {
    disk = {
      cache-0 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-Corsair_CMFSSD-256D1_131801888FF00002";
        content = {
          inherit type;
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
            # With disko the naming MUST be 'zfs' for the lookup to match
            zfs = fillZfsPartition;
          };
        };
      };
      data-0 = mkZfsDisk "/dev/disk/by-id/ata-WDC_WD10EFRX-68FYTN0_WD-WCC4J7TLCSNX";
      data-1 = mkZfsDisk "/dev/disk/by-id/ata-WDC_WD10EFRX-68FYTN0_WD-WCC4J2TJHS9P";
      data-2 = mkZfsDisk "/dev/disk/by-id/ata-WDC_WD10EFRX-68PJCN0_WD-WCC4J4XV4KDD";
      data-3 = mkZfsDisk "/dev/disk/by-id/ata-WDC_WD10EFRX-68PJCN0_WD-WCC4J4XR859D";
      data-4 = mkZfsDisk "/dev/disk/by-id/ata-WDC_WD10EFRX-68FYTN0_WD-WCC4J0KV5L3F";
    };

    zpool = {
      zroot = {
        type = "zpool";
        mode = {
          topology = {
            type = "topology";
            vdev = [
              {
                mode = "raidz2";
                members = [
                  "data-0"
                  "data-1"
                  "data-2"
                  "data-3"
                  "data-4"
                ];
              }
            ];
            cache = [ "cache-0" ];
          };
        };

        # Pool-level options
        options = {
          ashift = "12";
          autotrim = "on";
        };

        rootFsOptions = {
          compression = "zstd";
          acltype = "posixacl";
          xattr = "sa";
          dnodesize = "auto";
          "com.sun:auto-snapshot" = "false";
        };
        mountpoint = "/";

        # Initial datasets
        datasets = {
          "etc" = {
            type = "zfs_fs";
            mountpoint = "/etc";
            options = {
              compression = "zstd";
              "com.sun:auto-snapshot" = "true";
              "com.sun:auto-snapshot:frequent" = "0";
              "com.sun:auto-snapshot:hourly" = "0";
              "com.sun:auto-snapshot:daily" = "91";
              "com.sun:auto-snapshot:weekly" = "0";
            };
          };
          "home" = {
            type = "zfs_fs";
            mountpoint = "/home";
            options = {
              compression = "zstd";
              acltype = "posixacl";
              xattr = "sa";
              "com.sun:auto-snapshot" = "true";
              "com.sun:auto-snapshot:frequent" = "0";
              "com.sun:auto-snapshot:hourly" = "0";
              "com.sun:auto-snapshot:daily" = "0";
              "com.sun:auto-snapshot:weekly" = "13";
            };
          };
          "nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options = {
              compression = "zstd";
              "com.sun:auto-snapshot" = "false";
            };
          };
          "var" = {
            type = "zfs_fs";
            mountpoint = "/var";
            options = {
              compression = "zstd";
              "com.sun:auto-snapshot" = "true";
              "com.sun:auto-snapshot:frequent" = "0";
              "com.sun:auto-snapshot:hourly" = "2184";
              "com.sun:auto-snapshot:daily" = "0";
              "com.sun:auto-snapshot:weekly" = "0";
            };
          };
        };
      };
    };
  };
}
