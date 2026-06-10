# Device:      Apple M1 Pro
# CPU:         Apple M1 Pro
# RAM:         16GB DDR4
# SATA:        500GB SSD

{ pkgs, ... }: {
  sk.enable = true;
  oxc.homebrew.enable = true;
  oxc.sol.enable = true;
  homebrew.casks = [ "discord" ];
  environment.systemPackages = with pkgs.unstable; [
    freetube
  ];
}
