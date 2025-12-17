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
