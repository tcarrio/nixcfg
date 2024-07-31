{ lib, config, pkgs, ... }:
{
  options.oxc.desktop.spotify = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the Spotify music streaming application";
    };
  };

  config = lib.mkIf config.oxc.desktop.spotify.enable {
    environment.systemPackages = [ pkgs.spotify ];
  };
}
