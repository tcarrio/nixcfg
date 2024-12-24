{ pkgs, ... }: {
  # links /libexec from derivations to /run/current-system/sw 
  environment.pathsToLink = [ "/libexec" ];

  services.xserver = {
    enable = true;

    desktopManager = {
      xterm.enable = false;
    };

    windowManager.i3 = with pkgs; {
      enable = true;
      package = i3-gaps;
      extraPackages = [
        rofi
        i3lock
        i3blocks
        i3status
      ];
    };
  };

  services.displayManager.defaultSession = "none+i3";
}
