{ lib, ... }: {
  system = {
    defaults = {
      dock = {
        autohide = lib.mkDefault true;
        orientation = lib.mkDefault "bottom";
        tilesize = lib.mkDefault 64;
      };
      finder = { };
      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
      };
      CustomUserPreferences = {
        "com.apple.symbolichotkeys" = {
          AppleSymbolicHotKeys = {
            # Launch Dictation by double-pressing the left Command key
            "164" = {
              enabled = true;
              value = {
                parameters = [
                  # These were pulled straight from `defaults read com.apple.symbolichotkeys AppleSymbolicHotKeys`
                  # after setting the hotkey for Dictation
                  1048584
                  "18446744073708503031"
                ];
                type = "modifier";
              };
            };
            # Move left a space (Ctrl+Left)
            "79" = {
              enabled = true;
              value = {
                parameters = [
                  65535 # key code for left arrow
                  123
                  262144 # Ctrl modifier
                ];
                type = "standard";
              };
            };
            # Move right a space (Ctrl+Right)
            "81" = {
              enabled = true;
              value = {
                parameters = [
                  65535 # key code for right arrow
                  124
                  262144 # Ctrl modifier
                ];
                type = "standard";
              };
            };
          };
        };
      };
    };
  };
}
