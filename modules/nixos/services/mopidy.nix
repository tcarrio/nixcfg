{ config, pkgs, lib, ... }:
let
  cfg = config.oxc.services.mopidy;
in {
  options.oxc.services.mopidy.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf cfg.enable {
    # Securely mount Age secret for mopidy-spotify config
    age.secrets.mopidy-spotify-conf = {
      file = ../../../secrets/services/spotify/client.age;
      owner = "root";
      group = "root";
      mode = "400";
    };
  
    services.mopidy = {
      enable = true;
      extensionPackages = with pkgs; [mopidy-spotify];
      extraConfigFiles = [config.age.secrets.mopidy-spotify-conf.path];
    };
  };
}
