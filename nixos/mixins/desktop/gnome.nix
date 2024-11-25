{ pkgs, ... }:
{
  imports = [
    ../services/xdg-portal.nix
  ];

  # Enable the graphical windowing system.
  # NOTE: xserver is a legacy naming convention, DEs may still use Wayland over X11
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.desktopManager.gnome.enable = true;

  services.xserver.displayManager.gdm.enable = true;

  # Disable Wayland (issues with Electron app rendering)
  services.xserver.displayManager.gdm.wayland = false;

  # Enable udev rules
  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];

  environment.systemPackages = with pkgs; [
    gnomeExtensions.appindicator
    gnome-tweaks
    gnome-clocks
    gnome-sound-recorder
  ];
}
