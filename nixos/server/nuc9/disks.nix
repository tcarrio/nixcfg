_: {
  disko.devices = {
    disk = {
      sda = {
        device = "/dev/disk/by-id/ata-WDC_WDS120G2G0A-00JH30_19166R463905";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
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

