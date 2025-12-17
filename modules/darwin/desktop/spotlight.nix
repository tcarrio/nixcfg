{ lib, config, ... }:
let
  enabled = config.oxc.spotlight.enable;

  inherit (lib) mkOption types;
in
{
  options.oxc.spotlight.enable = mkOption {
    type = types.bool;
    default = true;
    description = "Whether to enable the Spotlight search application and its binding.";
  };

  config = {
    system.defaults.CustomUserPreferences."com.apple.symbolichotkeys" = {
      AppleSymbolicHotKeys = {
        # Disable 'Cmd + Space' for Spotlight Search (Key ID 64)
        "64" = { inherit enabled; };
        # Optional: Disable Finder Search (Cmd + Alt + Space, Key ID 65)
        "65" = { inherit enabled; };
      };
    };
  };
}
