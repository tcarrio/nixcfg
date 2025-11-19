{ lib, config, pkgs, ... }: {
  options.oxc.desktop.vivaldi = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the Vivaldi web browser";
    };
  };

  config = lib.mkIf config.oxc.desktop.vivaldi.enable {
    environment.systemPackages = with pkgs; [
      vivaldi
      vivaldi-ffmpeg-codecs
    ];
  };
}
