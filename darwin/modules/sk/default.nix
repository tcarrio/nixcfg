{ config, username, hostname, lib, pkgs, ... }:
let
  cfg = config.sk;
  inherit (lib) mkDefault mkIf mkOption optional types;
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
    spotlight.enabled = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable the Spotlight search application and its binding.";
    };
    keyboard.mapCapLockToEscape = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to use the Caps Lock key as an Escape key.";
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
                enabled = mkDefault true;
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
        userKeyMapping = [] ++ (
          optional cfg.keyboard.mapCapLockToEscape
          { HIDKeyboardModifierMappingSrc = 30064771129; HIDKeyboardModifierMappingDst = 30064771113; }
        );
      };
    };
  };
}
