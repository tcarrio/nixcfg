{ lib, config, pkgs, ... }:
let
  cfg = config.oxc.yubikey;

  inherit (lib) mkDefault mkOption types;
in {
  options.oxc.yubikey.enable = mkOption {
    type = types.bool;
    default = false;
    description = "Whether to enable Yubikey support for macOS";
  };

  config = lib.mkIf cfg.enable {
    # We will utilize the Yubico Authenticator cask for managing Yubikeys
    homebrew.casks = ["yubico-authenticator"];
    environment.systemPackages = with pkgs; [
      yubikey-manager
      yubikey-piv-tool
    ];

    # Support for login with SmartCards like YubiKeys. User pairing will be enabled by default.
    system.defaults.CustomUserPreferences."com.apple.security.smartcard" = {
      "UserPairing" = mkDefault true;
    };
  };
}
