# Device:      Apple M1 Pro
# CPU:         Apple M1 Pro
# RAM:         16GB DDR4
# SATA:        500GB SSD

{ pkgs, ... }: {
  sk.enable = false;
  oxc.homebrew.enable = true;
  oxc.homebrew.defaults = true;

  environment.systemPackages = [
    pkgs.unstable.pomodoro-gtk
  ];

  homebrew.casks = [
    "synology-drive"
  ];
}
