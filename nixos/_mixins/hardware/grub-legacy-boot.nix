{ ... }: {
  boot.loader.grub = {
    enable = true;
    efiSupport = false;
  };
}