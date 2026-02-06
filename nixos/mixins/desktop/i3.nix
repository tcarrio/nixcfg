{ pkgs, ... }: {
  # links /libexec from derivations to /run/current-system/sw 
  environment.pathsToLink = [ "/libexec" ];

  services.xserver = {
    enable = true;

    desktopManager.xterm.enable = false;

    windowManager.i3 = with pkgs; {
      enable = true;
      package = i3;
      extraPackages = [
        rofi
        i3lock
        i3blocks
        i3status
        polybar
      ];
    };
  };

  services.picom.enable = true;

  services.displayManager.defaultSession = "none+i3";

  xdg.portal.extralPortals = [(pkgs.xdg-desktop-portal-gtk.override {
    buildPortalsInGnome = true;
  })];
}
