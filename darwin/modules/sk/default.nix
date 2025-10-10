{ config, username, hostname, lib, pkgs, ... }:
let
  cfg = config.sk;
  inherit (lib) fromHexString mkDefault mkIf mkOption optional types;

  # The following sets up keyboard mapping primitives
  #
  # For a reference of apple key codes, you could look at either:
  # /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/System/Library/Frameworks/Carbon.framework/Versions/A/Frameworks/HIToolbox.framework/Versions/A/Headers/Events.h
  # or for older macOS versions, you can use the following:
  # /System/Library/Frameworks/Carbon.framework/Versions/A/Frameworks/HIToolbox.framework/Versions/A/Headers/Events.h
  #
  # These keycodes do not appear to translate to the symbolic hotkeys or values used there.
  # They are used to create custom keyboard mappings.
  # @see: system.keyboard.userKeyMapping

  # Always binary OR'ed with the keycode. Some keys require debugging since CapsLock is correct, but others haven't mapped correctly.
  baseCode = fromHexString "700000000";
  keymapCode = hexCode: ((fromHexString hexCode) + baseCode);

  # Extracted from the enum definition in Events.h
  keyCodes = {
    Return        = "0x24";
    Tab           = "0x30";
    Space         = "0x31";
    Delete        = "0x33";
    Escape        = "0x35";
    Command       = "0x37";
    Shift         = "0x38";
    CapsLock      = "0x39";
    Option        = "0x3A";
    Control       = "0x3B";
    RightCommand  = "0x36";
    RightShift    = "0x3C";
    RightOption   = "0x3D";
    RightControl  = "0x3E";
    Function      = "0x3F";
    F17           = "0x40";
    VolumeUp      = "0x48";
    VolumeDown    = "0x49";
    Mute          = "0x4A";
    F18           = "0x4F";
    F19           = "0x50";
    F20           = "0x5A";
    F5            = "0x60";
    F6            = "0x61";
    F7            = "0x62";
    F3            = "0x63";
    F8            = "0x64";
    F9            = "0x65";
    F11           = "0x67";
    F13           = "0x69";
    F16           = "0x6A";
    F14           = "0x6B";
    F10           = "0x6D";
    ContextualMenu= "0x6E";
    F12           = "0x6F";
    F15           = "0x71";
    Help          = "0x72";
    Home          = "0x73";
    PageUp        = "0x74";
    ForwardDelete = "0x75";
    F4            = "0x76";
    End           = "0x77";
    F2            = "0x78";
    PageDown      = "0x79";
    F1            = "0x7A";
    LeftArrow     = "0x7B";
    RightArrow    = "0x7C";
    DownArrow     = "0x7D";
    UpArrow       = "0x7E";
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
          {
            HIDKeyboardModifierMappingSrc = keymapCode keyCodes.CapsLock;
            # Important note: This actually gets interpreted as F19 in Cursor but it works.
            HIDKeyboardModifierMappingDst = keymapCode keyCodes.ContextualMenu;
          }
        ];
      };
    };
  };
}
