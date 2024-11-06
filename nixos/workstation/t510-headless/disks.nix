_: {
  disko.devices = {
    disk = {
      sda = {
        device = "/dev/disk/by-id/ata-Samsung_SSD_850_PRO_512GB_S250NXAH211618D";
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
    };
  };
}

