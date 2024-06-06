{ ... }: {
  # services.displayManager.sddm.enable = true;
  # services.desktopManager.plasma6.enable = true;
  services.xserver = {
    enable = true;

    displayManager = {
      defaultSession = "plasma";
      sddm = {
        enable = true;
        wayland.enable = true;
      };
    };

    desktopManager.plasma6.enable = true;
  };
}