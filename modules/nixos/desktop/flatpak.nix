{ lib, config, ... }:
let
  cfg = config.oxc.desktop.flatpak;
in
{
  options.oxc.desktop.flatpak.enable = lib.mkEnableOption "Enable Flatpak support";

  config = lib.mkIf cfg.enable {
    services.flatpak = {
      enable = true;

      # The remaining configurations are possible due to declarative-flatpak
      # @see https://github.com/in-a-dil-emma/declarative-flatpak
      remotes = {
        "flathub" = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        "flathub-beta" = "https://dl.flathub.org/beta-repo/flathub-beta.flatpakrepo";
      };
      overrides = {
        # NOTE: "global" is a flatpak thing, you can specify configurations for explicit packages by their identifier too
        "global".Context = {
          filesystems = [
            "home"
          ];
          sockets = [
            "!x11"
            "!fallback-x11"
          ];
        };
      };
    };

    environment.profileRelativeSessionVariables.XDG_DATA_DIR = [
      "/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share"
    ];
  };
}