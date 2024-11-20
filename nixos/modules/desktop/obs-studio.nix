{ lib, config, pkgs, ... }:
let
  cfg = config.oxc.desktop.obs-studio;
in
{
  options.oxc.desktop.obs-studio = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the OBS Studio streaming software";
    };

    virtualCamera = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to enable the OBS Studio virtual camera";
      };
    };

    # TODO: Breakdown additional components into separate options
    bellsAndWhistles = {
      all = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to enable all the OBS Studio bells and whistles";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # https://nixos.wiki/wiki/OBS_Studio
    boot =
      if cfg.virtualCamera.enable
      then {
        extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
        extraModprobeConfig = ''
          options v4l2loopback devices=1 video_nr=13 card_label="OBS Virtual Camera" exclusive_caps=1
        '';
      } else { };

    environment.systemPackages = [
      pkgs.bc
      pkgs.google-fonts
      pkgs.libnotify
      (pkgs.wrapOBS {
        plugins = with pkgs.obs-studio-plugins; if cfg.bellsAndWhistles.all then [
          obs-3d-effect
          obs-command-source
          obs-gradient-source
          obs-gstreamer
          obs-nvfbc
          obs-move-transition
          obs-mute-filter
          obs-pipewire-audio-capture
          obs-rgb-levels-filter
          obs-text-pthread
          obs-scale-to-sound
          advanced-scene-switcher
          obs-shaderfilter
          obs-source-clone
          obs-source-record
          obs-source-switcher
          # obs-transition-table
          obs-vaapi
          obs-vintage-filter
          obs-websocket
          waveform
        ] else [ ];
      })
    ];
  };
}
