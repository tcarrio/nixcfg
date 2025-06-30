{ pkgs, lib, config, ... }:
let
  cfg = config.oxc.services.flatpak;
in
{
  options.oxc.services.flatpak = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable support for Flatpak";
    };

    flathub = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable the Flathub repository for Flatpak";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.flatpak.enable = true;

    # unit file idempotently adds flathub to flatpak repositories
    systemd.services.configure-flathub-repo = lib.mkIf cfg.flathub.enable {
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      path = [ pkgs.flatpak ];
      script = ''
        ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
      '';
    };
  };
}
