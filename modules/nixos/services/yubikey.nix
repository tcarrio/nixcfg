{ config, lib, ... }:
let
  cfg = config.oxc.services.yubikey;

  defaultKeys = [
    "tcarrio:TvZ3U7bAPWeRtL3t5qbKawJKe69jJqMk4YayOklrXaSA8QePISDg2W1ZT03pvrBbG97YK1Dy/vzpoKmntuuWmw==,ii8jem3VuN7Z4Vw86uA5EAe6PzrKIiclS9cAzeMnP1Agj2+CzTC39EXaoYQ2m2d3KGuVUnWWvKQRRmiDoRTS8w==,es256,+presence";
  ];

  u2fConfig = pkgs.writeFile (lib.concatStringsSep "\n" cfg.keys);
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
      default = defaultKeys;
      description = "Keys to include for system trust.";
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

      

      config.systemd.tmpfiles.rules = [
        "d /home/${username}/.config 0755 ${username} ${username}"
        "d /home/${username}/.config/Yubico 0755 ${username} ${username}"
        "L+ /home/${username}/.config/Yubico/u2f_keys - - - - ${u2fConfig}"
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
