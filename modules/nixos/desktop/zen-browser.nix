{ lib, config, ... }:
let
  cfg = config.oxc.desktop.zen-browser;
in
{
  options.oxc.desktop.zen-browser = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the Zen browser";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions =
      [{
        assertion = config.services.flatpak.enable;
        message = "Flatpak must be enabled to install Zen Browser";
      }];

    services.flatpak.packages = [ "flathub:app/app.zen_browser.zen//stable" ];
  };
}
