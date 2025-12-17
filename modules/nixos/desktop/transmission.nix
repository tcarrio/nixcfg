{ lib, config, pkgs, desktop, ... }:
let
  qtPackage = pkgs.transmission_4-qt;
  gtkPackage = pkgs.transmission_4-gtk;
  defaultPackage = {
    "cinnamon" = gtkPackage;
    "cosmic" = gtkPackage;
    "gnome" = gtkPackage;
    "hyprland" = qtPackage;
    "i3" = qtPackage;
    "kde" = qtPackage;
    "kde6" = qtPackage;
    "pantheon" = gtkPackage;
  }.${desktop} or qtPackage;

  cfg = config.oxc.desktop.transmission;
in
{
  options.oxc.desktop.transmission = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the Bitwarden password manager";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = defaultPackage;
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
