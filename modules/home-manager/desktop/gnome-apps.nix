{
  lib,
  config,
  ...
}:
let
  cfg = config.oxc.desktop.gnome-apps;

  mkAppToggle = name: lib.mkEnableOption name // { default = cfg.enable; };
in
with lib.hm.gvariant;
{
  options.oxc.desktop.gnome-apps = {
    enable = lib.mkEnableOption "the oxc GNOME app settings bundle";

    celluloid = mkAppToggle "Celluloid media player dconf settings";
    dconf-editor = mkAppToggle "dconf-editor settings";
    gnome-sound-recorder = mkAppToggle "GNOME Sound Recorder settings + Audio redirect";
    # amethyst is macOS-only; default off even when the bundle is on
    amethyst = lib.mkEnableOption "Amethyst window manager (macOS) with oxc defaults";
  };

  config = {
    dconf.settings =
      { }
      // (lib.mkIf cfg.celluloid {
        "io/github/celluloid-player/celluloid" = {
          csd-enable = false;
          dark-theme-enable = true;
        };
      })
      // (lib.mkIf cfg.dconf-editor {
        "ca/desrt/dconf-editor" = {
          show-warning = false;
        };
      })
      // (lib.mkIf cfg.gnome-sound-recorder {
        "org/gnome/SoundRecorder" = {
          audio-channel = "mono";
          audio-profile = "flac";
        };
      });

    systemd.user.tmpfiles.rules = lib.mkIf cfg.gnome-sound-recorder [
      "L+ ${config.home.homeDirectory}/.local/share/org.gnome.SoundRecorder/ - - - - ${config.home.homeDirectory}/Audio/"
    ];

    oxc.amethyst = lib.mkIf cfg.amethyst {
      enable = true;
      defaults = true;
    };
  };
}
