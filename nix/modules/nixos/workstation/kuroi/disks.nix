_: {
  disko.devices = {
    disk = {
      sda = {
        device = "/dev/disk/by-id/ata-Samsung_SSD_850_PRO_512GB_S250NXAH211618D";
        name = "primary-disk";
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
                mountpoint = "/boot/efi";
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
      sdb = {
        device = "/dev/disk/by-id/ata-ADATA_SP600NS34_2F4820062537";
        name = "home-disk";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            data = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/data";
              };
            };
          };
        };
      };
    };
  };
}
