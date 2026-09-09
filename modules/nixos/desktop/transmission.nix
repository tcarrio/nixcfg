{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.oxc.desktop.transmission;
in
{
  options.oxc.desktop.transmission = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the Transmission BitTorrent client";
    };

    flavor = lib.mkOption {
      type = lib.types.enum [
        "gtk"
        "qt"
      ];
      default = "qt";
      description = "Widget toolkit flavor of the transmission package";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = if cfg.flavor == "gtk" then pkgs.transmission_4-gtk else pkgs.transmission_4-qt;
      defaultText = lib.literalExpression "transmission_4-qt (per flavor)";
      description = "The package to use for transmission";
    };

    firewall = {
      open = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to open the firewall for incoming peer connections";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 51413;
        description = "The port to use for incoming peer connections";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
    ];

    networking.firewall.allowedTCPPorts = lib.optional cfg.firewall.open cfg.firewall.port;
  };
}
