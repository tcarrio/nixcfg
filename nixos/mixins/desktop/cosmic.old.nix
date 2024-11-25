{ pkgs, ... }:
{
  imports = [
    ../services/xdg-portal.nix
  ];

  # Enable the X11 windowing system.
  services.xserver.enable = false;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Enable udev rules
  services.udev.packages = with pkgs; [ gnome.cosmic-settings-daemon ];

  environment.systemPackages = with pkgs; [
    gnomeExtensions.appindicator
    gnome-tweaks
  ];
}
