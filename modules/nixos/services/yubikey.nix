{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.oxc.services.yubikey;

  u2fConfig = pkgs.writeText "u2f_keys" (lib.concatStringsSep "\n" cfg.keys);
in
{
  options.oxc.services.yubikey = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable 0xc Yubikey support.";
    };

    keys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        PAM U2F keys to include for system trust. Generate with
        `pamu2fcfg > u2f_keys`; empty by default — hosts supply their own.
      '';
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "root";
      description = "User whose ~/.config/Yubico receives the u2f_keys link.";
    };

    exclusiveKeyLogin = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Allow only Yubikey login on device.";
    };

    removedKeyLogout = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Log out users when Yubikey is removed.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      security.pam.services = {
        login = {
          u2fAuth = true;
          unixAuth = !cfg.exclusiveKeyLogin;
        };
        sudo = {
          u2fAuth = true;
          unixAuth = !cfg.exclusiveKeyLogin;
        };
      };

      systemd.tmpfiles.rules = [
        "d /home/${cfg.user}/.config 0755 ${cfg.user} ${cfg.user}"
        "d /home/${cfg.user}/.config/Yubico 0755 ${cfg.user} ${cfg.user}"
        "L+ /home/${cfg.user}/.config/Yubico/u2f_keys - - - - ${u2fConfig}"
      ];
    })
    (lib.mkIf (cfg.enable && cfg.removedKeyLogout) {
      services.udev.extraRules = ''
        ACTION=="remove",\
          ENV{ID_BUS}=="usb",\
          ENV{ID_MODEL_ID}=="0407",\
          ENV{ID_VENDOR_ID}=="1050",\
          ENV{ID_VENDOR}=="Yubico",\
          RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
      '';
    })
  ];
}
