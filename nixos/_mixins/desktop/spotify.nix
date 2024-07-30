{ pkgs, ... }:
{
  imports = [../services/unfree.nix];

  options.oxc.desktop.spotify = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Spotify";
    };
  };

  config = lib.mkIf config.oxc.desktop.spotify.enabled {
    environment.systemPackages = with pkgs; [ spotify ];
  };
}
