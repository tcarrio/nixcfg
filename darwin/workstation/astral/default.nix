# Device:      Apple M4 Pro
# CPU:         Apple M4 Pro
# RAM:         64GB DDR4
# SATA:        1TB SSD

{ pkgs, ... }: {
  oxc.homebrew.enable = true;
  oxc.homebrew.defaults = false;
  oxc.sol.enable = false;
  homebrew.casks = [];
  environment.systemPackages = [];
}
