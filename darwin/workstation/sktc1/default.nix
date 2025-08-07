# Device:      Apple M1 Pro
# CPU:         Apple M1 Pro
# RAM:         16GB DDR4
# SATA:        500GB SSD

{ username, ... }: {
  imports = [
    ../../mixins/console/homebrew.nix
    ../../mixins/console/brews.nix

    # ../../mixins/console/podman.nix
    ../../mixins/desktop/mac-launcher.nix
    ../../mixins/desktop/neovide.nix
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
      CustomUserPreferences = {
        "com.apple.symbolichotkeys" = {
          AppleSymbolicHotKeys = {
            "64" = { # Disable Cmd + Space for Spotlight
              enabled = false;
            };
          };
        };
      };
    };

    keyboard = {
      enableKeyMapping = true;
      userKeyMapping = [
        # Maps Caps Lock to Escape key
        { HIDKeyboardModifierMappingSrc = 30064771129; HIDKeyboardModifierMappingDst = 30064771113; }
      ];
    };
  };
}
