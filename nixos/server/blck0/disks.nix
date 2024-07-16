{ disks ? [
    "/dev/sda"
    "/dev/sdb"
    "/dev/sdc"
    "/dev/sdd"
    "/dev/sde"
    "/dev/sdf"
    "/dev/sdg"
    "/dev/sdh"
    "/dev/sdi"
    "/dev/sdj"
    "/dev/sdk"
    "/dev/sdl"
    "/dev/sdm"
    "/dev/sdn"
  ]
, ...
}:
let
  mkRaidDisk = name: dev: {
    type = "disk";
    device = "/dev/${dev}";
    content = {
      type = "mdraid";
      name = name;
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
        device = "/dev/sdj";
        content = {
          type = "table";
          format = "msdos";
          partitions = [
            {
              start = "1M";
              end = "-16G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            }
            {
              size = "100%";
              content = {
                type = "swap";
                resumeDevice = true;
              };
            }
          ]
            };
        };

        ssd-a = mkSsdRaidDisk "sda";
        ssd-b = mkSsdRaidDisk "sdb";
        ssd-c = mkSsdRaidDisk "sdc";
        ssd-d = mkSsdRaidDisk "sdd";
        ssd-e = mkSsdRaidDisk "sde";
        ssd-f = mkSsdRaidDisk "sdf";
        ssd-g = mkSsdRaidDisk "sdg";
        ssd-h = mkSsdRaidDisk "sdh";

        # NOTE: /dev/sdi is the system OS

        hdd-k = mkHddRaidDisk "sdk";
        hdd-l = mkHddRaidDisk "sdl";
        hdd-m = mkHddRaidDisk "sdm";
        hdd-n = mkHddRaidDisk "sdn";
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
                  mountpoint = "/storage/sdds";
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
                  mountpoint = "/storage/hdds";
                };
              };
            };
          };
        };
      };
    };
  }
