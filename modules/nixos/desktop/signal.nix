{ lib, config, inputs, desktop, ... }:
let
  cfg = config.oxc.desktop.signal;
  signalAppId = "org.signal.Signal";
  passwordStore = rec {
    gnome = "gnome-libsecret";
    cinnamon = gnome;
    mate = gnome;
    # TODO: Support for other desktop's respective secret manager
  }."${desktop}" or null;
in
{
  options.oxc.desktop.signal = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the Signal Desktop app";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions =
      [ { assertion = config.services.flatpak.enable;
          message = "Flatpak must be enabled to install Signal Desktop";
        }
      ];

    services.flatpak.packages = ["flathub-beta:app/${signalAppId}//beta"];
    services.flatpak.overrides."${signalAppId}" = {
      Environment = if passwordStore != null
        then { SIGNAL_PASSWORD_STORE = passwordStore; }
        else {};
    };
  };
}
