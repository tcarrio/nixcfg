_: {
  disko.devices = {
    disk = {
      sda = {
        # the same hardware, the same sata port... better be the same pci path.
        device = "/dev/disk/by-path/pci-0000:00:13.0-ata-1";
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

