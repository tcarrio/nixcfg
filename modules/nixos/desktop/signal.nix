{
  lib,
  config,
  options,
  ...
}:
let
  cfg = config.oxc.desktop.signal;
  signalAppId = "org.signal.Signal";

  # The packages/overrides options come from the declarative-flatpak module,
  # which internal hosts add via the flatpaks flake input. When absent (an
  # external consumer without that input), fall back to asserting flatpak is
  # enabled and skip declarative management.
  hasDeclarativeFlatpak = options.services.flatpak ? packages;
in
{
  options.oxc.desktop.signal = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the Signal Desktop app";
    };

    passwordStore = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "gnome-libsecret"
          "kwallet"
          "keepass"
        ]
      );
      default = "gnome-libsecret";
      description = ''
        Secret-store backend for Signal's password storage. Only backends
        with known-good desktop support are listed; null disables the
        environment override entirely.
      '';
    };
  };

  config = lib.mkIf cfg.enable (
    {
      assertions = [
        {
          assertion = config.services.flatpak.enable;
          message = "Flatpak must be enabled to install Signal Desktop";
        }
      ];
    }
    // lib.optionalAttrs hasDeclarativeFlatpak {
      services.flatpak.packages = [ "flathub-beta:app/${signalAppId}//beta" ];
      services.flatpak.overrides."${signalAppId}" = {
        Environment =
          if cfg.passwordStore != null then { SIGNAL_PASSWORD_STORE = cfg.passwordStore; } else { };
      };
    }
  );
}
