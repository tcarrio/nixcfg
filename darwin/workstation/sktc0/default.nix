# Device:      Apple M1 Pro
# CPU:         Apple M1 Pro
# RAM:         16GB DDR4
# SATA:        500GB SSD

{ username, ... }: {
  imports = [
    ../../mixins/console/homebrew.nix
    ./brews.nix
  ];
  
  oxc.services.xcode.acceptLicense = true;
  oxc.services.nextdns.enable = false;
  oxc.services.colima.enable = false;

  networking.hostName = "sktc0";

  system = {
    primaryUser = username;
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
