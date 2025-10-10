{ config, username, hostname, lib, pkgs, ... }:
let
  cfg = config.sk;
  inherit (lib) fromHexString mkDefault mkIf mkOption optional types;

  ### The following sets up keyboard mapping primitives
  # There is a base code that is always binary OR'ed with the keycode.
  baseCode = fromHexString "700000000";
  # Map a given keycode to the custom keymap code for keyboard mapping.
  keymapCode = hexCode: ((fromHexString hexCode) + baseCode);
  # Extracted from the documentation here:
  # https://developer.apple.com/library/archive/technotes/tn2450/_index.html#//apple_ref/doc/uid/DTS40017618-CH1-KEY_TABLE_USAGES
  keyCodes = {
    CapsLock = "0x39";
    Escape = "0x29";
    F13 = "0x68";
    F14 = "0x69";
    F15 = "0x6A";
    F16 = "0x6B";
    F17 = "0x6C";
    F18 = "0x6D";
    F19 = "0x6E";
    F20 = "0x6F";
    F21 = "0x70";
    F22 = "0x71";
    F23 = "0x72";
    F24 = "0x73";
  };
in {
  options.sk = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable the SK module.";
    };
    homebrew.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable Homebrew.";
    };
    homebrew.defaults = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable the default Homebrew packages";
    };
    spotlight.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable the Spotlight search application and its binding.";
    };
    workspaces.dynamic = mkOption {
      type = types.bool;
      default = false;
      description = "Allows macOS to re-order workspaces based on a most-recently-used algorithm.";
    };
    workspaces.allowApplicationFocus = mkOption {
      type = types.bool;
      default = true;
      description = "Allows opening an application in another workspace to focus that workspace.";
    };
  };

  config = mkIf cfg.enable {
    oxc.homebrew = {
      inherit (cfg.homebrew) enable defaults;
    };
    oxc.services.xcode.acceptLicense = true;
    oxc.services.caffeinated.enable = true;

    networking.hostName = mkDefault hostname;

    environment.systemPackages = with pkgs.unstable; [
      neovide
    ];

    environment.variables = {
      EDITOR = "nvim";
      PAGER = "less";
    };

    system = {
      primaryUser = mkDefault username;
      defaults = {
        dock = {
          autohide = mkDefault true;
          orientation = mkDefault "bottom";
          tilesize = mkDefault 64;
        };
        finder = { };
        trackpad = {
          Clicking = true;
          TrackpadRightClick = true;
        };
        CustomUserPreferences = {
          "com.apple.symbolichotkeys" = {
            AppleSymbolicHotKeys = {
              "64" = {
                # Controls Cmd + Space for Spotlight
                enabled = cfg.spotlight.enable;
              };
              # Move left a space (Ctrl+Left)
              "79" = {
                enabled = true;
                value = {
                  parameters = [
                    65535  # key code for left arrow
                    123
                    262144  # Ctrl modifier
                  ];
                  type = "standard";
                };
              };
              # Move right a space (Ctrl+Right)
              "81" = {
                enabled = true;
                value = {
                  parameters = [
                    65535  # key code for right arrow
                    124
                    262144  # Ctrl modifier
                  ];
                  type = "standard";
                };
              };
            };
          };
          "com.apple.dock" = {
            # Fast mode for application switching across workspaces with app launchers
            "workspaces-auto-swoosh" = cfg.workspaces.allowApplicationFocus;
            # Allows macOS to re-arrange spaces ordering
            "mru-spaces" = cfg.workspaces.dynamic;
          };

          # Support for SmartCards like YubiKeys
          "com.apple.security.smartcard" = {
            "UserPairing" = mkDefault true;
          };
        };
      };

      keyboard = {
        enableKeyMapping = true;
        userKeyMapping = [
          { HIDKeyboardModifierMappingSrc = keymapCode keyCodes.CapsLock; HIDKeyboardModifierMappingDst = keymapCode keyCodes.F24; }
        ];
      };
    };
  };
}
