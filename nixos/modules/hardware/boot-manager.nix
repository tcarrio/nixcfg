{ lib, config, ... }: {
  options.oxc.boot = {
    device = {
      type = lib.mkOption {
        type = lib.types.enum ["uefi" "bios"];
        default = "uefi";
        description = "Configures which boot manager format to utilize";
      };
      partition = lib.mkOption {
        type = lib.types.string;
        description = "Configure which partition the boot loader will install to";
      };
    };

    manager = lib.mkOption {
      type = lib.types.enum ["systemd-boot" "grub"];
      default = "systemd-boot";
      description = "Configured which boot manager to utilize";
    };
  };
}
