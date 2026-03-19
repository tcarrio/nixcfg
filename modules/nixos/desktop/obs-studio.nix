{ lib, config, pkgs, ... }:
let
  inherit (lib) elem mkIf mkEnableOption mkOption optionals types;

  cfg = config.oxc.desktop.obs-studio;

  isAmdHardware = elem "amd" config.services.xserver.videoDrivers;
  isNvidiaHardware = elem "nvidia" config.services.xserver.videoDrivers;

  package =
    if isNvidiaHardware
    then
      (cfg.package.override {
        cudaSupport = true;
      })
    else cfg.package;

  basePlugins = with cfg.plugins; [
    obs-3d-effect
    obs-backgroundremoval
    obs-command-source
    obs-gradient-source
    obs-gstreamer
    obs-move-transition
    obs-mute-filter
    obs-pipewire-audio-capture
    obs-scale-to-sound
    obs-shaderfilter
    obs-source-clone
    obs-source-record
    obs-source-switcher
    obs-text-pthread
    obs-vintage-filter
    obs-vkcapture
    obs-websocket
    waveform
    wlrobs
  ];

  amdPlugins = [ pkgs.obs-studio-plugins.obs-vaapi ];

  plugins = basePlugins
    ++ (optionals isAmdHardware amdPlugins);
in
{
  options.oxc.desktop.obs-studio = {
    enable = mkEnableOption "Whether to enable the OBS Studio streaming software";
    package = mkOption {
      type = types.package;
      default = pkgs.unstable.obs-studio;
      description = "The package to use for OBS Studio";
    };
    plugins = mkOption {
      type = types.attrsOf types.package;
      default = pkgs.unstable.obs-studio-plugins;
      description = "The obs-studio-plugins group to source plugins";
    };
    virtualCamera = {
      enable = mkEnableOption "Whether to enable the OBS Studio virtual camera";
    };
    deviceCamera = {
      # TODO: Utilize
      droidCam = mkEnableOption "Whether to enable support for DroidCam";
      # TODO: Utilize
      dslr = mkEnableOption "Whether to enable support for DSLR cameras";
    };

    # TODO: Options to break up plugin installation into more modular sets
  };

  config = mkIf cfg.enable {
    # https://nixos.wiki/wiki/OBS_Studio
    boot =
      if cfg.virtualCamera.enable
      then {
        extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
        extraModprobeConfig = ''
          options v4l2loopback devices=1 video_nr=13 card_label="OBS Virtual Camera" exclusive_caps=1
        '';
      } else { };

    programs.obs-studio = {
      enable = true;
      inherit package plugins;
    };

    environment.systemPackages = [
      pkgs.bc
      pkgs.google-fonts
      pkgs.libnotify
    ];
  };
}
