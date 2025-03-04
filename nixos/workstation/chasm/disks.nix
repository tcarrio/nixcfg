_: {
  disko.devices = {
    disk = {
      sda = {
        device = "/dev/disk/by-id/ata-WDC_WDS120G2G0A-00JH30_19166R479112";
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
              size = "-8G";
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
    };
  };
}
