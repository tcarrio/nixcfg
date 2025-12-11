{ config, username, hostname, lib, pkgs, ... }:
let
  cfg = config.sk;
  inherit (lib) fromHexString mkIf mkOption optional types;
  mkSkDefault = value: lib.mkOverride 777 value;

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
  };

  config = mkIf cfg.enable {
    oxc.homebrew = {
      inherit (cfg.homebrew) enable defaults;
    };
    homebrew.casks = lib.optionals cfg.homebrew.enable [
      "cursor"
      "docker-desktop"
      "sequel-ace"
      "visual-studio-code"
    ];

    oxc.services.xcode.acceptLicense = true;
    oxc.services.caffeinated.enable = true;

    networking.hostName = mkSkDefault hostname;

    system = {
      keyboard = {
        enableKeyMapping = true;
        userKeyMapping = [
          # Maps Caps Lock to F24, a useful binding for various applications such as Cursor Tab
          { HIDKeyboardModifierMappingSrc = keymapCode keyCodes.CapsLock; HIDKeyboardModifierMappingDst = keymapCode keyCodes.F24; }
        ];
      };
    };
  };
}
