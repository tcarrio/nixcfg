{ pkgs, ... }: {
  imports = [
    ../services/sane.nix
  ];

  oxc.services.flatpak.enable = true;

  # Add some packages to complete the MATE desktop
  environment.systemPackages = with pkgs; [
    celluloid
    gnome.gucharmap
    gnome-firmware
    gthumb
    usbimager
  ];

  # Enable some programs to provide a complete desktop
  programs = {
    gnome-disks.enable = true;
    seahorse.enable = true;
  };
}
