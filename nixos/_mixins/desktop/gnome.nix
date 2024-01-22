{ pkgs, ... }:
{
  imports = [
    ../services/xdg-portal.nix
  ];

  # Enable the graphical windowing system.
  # NOTE: xserver is a legacy naming convention, DEs may still use Wayland over X11
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = false;

  services.xserver.desktopManager.gnome.enable = true;

  # Enable udev rules
  services.udev.packages = with pkgs.unstable; [ gnome.gnome-settings-daemon ];

  environment.systemPackages = with pkgs.unstable; [
    gnomeExtensions.appindicator
    gnome3.gnome-tweaks
  ];
}
