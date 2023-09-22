# Device:      Apple M1 Pro
# CPU:         Apple M1 Pro
# RAM:         16GB DDR4
# SATA:        500GB SSD

{ ... }: {
  imports = [
    # TODO: Enable homebrew management
    # ../_mixins/console/homebrew.nix
  ];

  system = {
    defaults = {
      dock = {
        autohide = true;
        orientation = "bottom";
        tilesize = 128;
      };
      finder = {};
      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
      };
    };
    keyboard = { enableKeyMapping = true; };
  };
}