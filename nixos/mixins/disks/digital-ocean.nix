# Example configuration from the booted base image:
#
# /dev/disk/by-label/nixos / ext4 x-systemd.growfs,x-initrd.mount 0 1

_: {
  boot.loader.grub.devices = [ "/dev/vda" ];

  disko.devices = {
    disk = {
      vda = {
        device = "/dev/disk/by-label/nixos";
        name = "/dev/vda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
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

