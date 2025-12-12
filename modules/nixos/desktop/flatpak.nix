# NOTE: The following were installed out-of-the-box with Flatpak enabled
# Declarative management will remove some of the when not defined!
# ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Freedesktop Platform                             org.freedesktop.Platform                                   freedesktop-sdk-24.08.28              24.08                    system
# Freedesktop Platform                             org.freedesktop.Platform                                   freedesktop-sdk-25.08.5               25.08                    system
# Mesa                                             org.freedesktop.Platform.GL.default                        25.2.6                                24.08                    system
# Mesa (Extra)                                     org.freedesktop.Platform.GL.default                        25.2.6                                24.08extra               system
# Mesa                                             org.freedesktop.Platform.GL.default                        25.2.6                                25.08                    system
# Mesa (Extra)                                     org.freedesktop.Platform.GL.default                        25.2.6                                25.08-extra              system
# nvidia-580-105-08                                org.freedesktop.Platform.GL.nvidia-580-105-08                                                    1.4                      system
# Nvidia VAAPI driver                              org.freedesktop.Platform.VAAPI.nvidia                                                            25.08                    system
# Codecs Extra Extension                           org.freedesktop.Platform.codecs-extra                                                            25.08-extra              system
# FFmpeg extension with extra codecs               org.freedesktop.Platform.ffmpeg-full                                                             24.08                    system
# openh264                                         org.freedesktop.Platform.openh264                          2.5.1                                 2.5.1                    system
# Freedesktop SDK                                  org.freedesktop.Sdk                                        freedesktop-sdk-25.08.5               25.08                    system

# TODO: Refactor Flatpak installs to home-manager
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
      "/usr/share"
      "/var/lib/flatpak/exports/share"
      "$HOME/.local/share/flatpak/exports/share"
    ];

    xdg.portal.enable = true;
  };
}