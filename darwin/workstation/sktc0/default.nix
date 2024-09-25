# Device:      Apple M1 Pro
# CPU:         Apple M1 Pro
# RAM:         16GB DDR4
# SATA:        500GB SSD

_: {
  imports = [
    ../../mixins/console/homebrew.nix
    ./brews.nix
  ];

  oxc.services.xcode.acceptLicense = true;
  oxc.services.nextdns.enable = false;

  networking.hostName = "sktc0";

  system = {
    defaults = {
      dock = {
        autohide = true;
        orientation = "bottom";
        tilesize = 80;
      };
      finder = { };
      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
      };
    };
    keyboard = { enableKeyMapping = true; };
  };
}
