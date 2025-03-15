{ pkgs, ... }:
{
  imports = [
    ../services/xdg-portal.nix
  ];

  # Enable the graphical windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.desktopManager.cinnamon.enable = true;

  # Use GDM for the display manager (login screen)
  services.xserver.displayManager.gdm.enable = true;

  # Disable Wayland (issues with Electron app rendering)
  services.xserver.displayManager.gdm.wayland = false;

  # Enable udev rules
  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
}
