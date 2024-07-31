{ pkgs, lib, config, ... }: {
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

  config = lib.mkIf config.oxc.services.flatpak.enable {
    services.flatpak.enable = true;

    # unit file idempotently adds flathub to flatpak repositories
    systemd.services.configure-flathub-repo = lib.mkIf config.oxc.services.flatpak.flathub.enable {
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.flatpak ];
      script = ''
        ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
      '';
    };
  };
}
