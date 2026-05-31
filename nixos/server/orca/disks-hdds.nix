### HDD DISKS - ZFS RAIDZ2 Configuration
# /dev/disk/by-id/ata-WDC_WD10EFRX-68FYTN0_WD-WCC4J7TLCSNX -> /dev/sdb
# /dev/disk/by-id/ata-WDC_WD10EFRX-68FYTN0_WD-WCC4J2TJHS9P -> /dev/sdc
# /dev/disk/by-id/ata-WDC_WD10EFRX-68PJCN0_WD-WCC4J4XV4KDD -> /dev/sdd
# /dev/disk/by-id/ata-WDC_WD10EFRX-68PJCN0_WD-WCC4J4XR859D -> /dev/sde
# /dev/disk/by-id/ata-WDC_WD10EFRX-68FYTN0_WD-WCC4J0KV5L3F -> /dev/sdf
_:
let
  mkZfsDisk = device: {
    type = "disk";
    inherit device;
    content = {
      type = "gpt";
      partitions = {
        zfs = {
          size = "100%";
          content = {
            type = "zfs";
            pool = "zroot";
          };
        };
      };
    };
  };
in
{
  disko.devices = {
    disk = {
      hdd-0 = mkZfsDisk "/dev/disk/by-id/ata-WDC_WD10EFRX-68FYTN0_WD-WCC4J7TLCSNX";
      hdd-1 = mkZfsDisk "/dev/disk/by-id/ata-WDC_WD10EFRX-68FYTN0_WD-WCC4J2TJHS9P";
      hdd-2 = mkZfsDisk "/dev/disk/by-id/ata-WDC_WD10EFRX-68PJCN0_WD-WCC4J4XV4KDD";
      hdd-3 = mkZfsDisk "/dev/disk/by-id/ata-WDC_WD10EFRX-68PJCN0_WD-WCC4J4XR859D";
      hdd-4 = mkZfsDisk "/dev/disk/by-id/ata-WDC_WD10EFRX-68FYTN0_WD-WCC4J0KV5L3F";
    };

    zpool = {
      zroot = {
        type = "zpool";
        mode = "raidz2";

        # Pool-level options
        options = {
          ashift = "12"; # 4K sector alignment for modern drives
          autotrim = "on";
          compression = "zstd";
          acltype = "posixacl";
          xattr = "sa";
          dnodesize = "auto";
        };

        rootFsOptions = {
          compression = "zstd";
          "com.sun:auto-snapshot" = "false";
          mountpoint = "/";
        };

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
