# Device:      Apple M1 Pro
# CPU:         Apple M1 Pro
# RAM:         16GB DDR4
# SATA:        500GB SSD

_: {
  imports = [
    # TODO: Enable homebrew management
    # ../../_mixins/console/homebrew.nix
    ../../_mixins/desktop/sketchybar.nix
    ../../_mixins/desktop/skhd.nix
    ../../_mixins/desktop/yabai.nix
  ];

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
