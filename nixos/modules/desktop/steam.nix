{ pkgs, lib, config, ... }:
let
  cfg = config.oxc.desktop.steam;
in {
  options.oxc.desktop.steam = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the Simple Scan application";
    };

    steamPlay = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to enable Steam Play";
      };

      firewall = {
        open = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether to open the firewall for Steam Play";
        };
      };
    };

    gamemode = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable Gamemode";
    };

    gamescope = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable GameScope compositor";
    };

    audioSupport = {
      jack = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to enable audio support for Jack";
      };

      pipewire = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to enable audio support for Pipewire";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Ensure unfree software support is enabled
    oxc.nix.unfree.enable = true;

    # https://nixos.wiki/wiki/Steam
    fonts.fontconfig.cache32Bit = true;
    hardware.steam-hardware.enable = true;

    programs.steam = {
      enable = true;

      package = pkgs.steam.override {
        extraPkgs = pkgs: [ pkgs.mpg123 ];
      };
      # Open ports in the firewall for Steam Remote Play
      remotePlay.openFirewall = cfg.steamPlay.firewall.open;
      # Open ports in the firewall for Source Dedicated Server
      dedicatedServer.openFirewall = cfg.steamPlay.firewall.open;
    };

    # Enable gamemode
    programs.gamemode.enable = cfg.gamemode;

    # Enable gamescope
    programs.gamescope = {
      enable = cfg.gamescope;
      capSysNice = false;
      package = pkgs.unstable.gamescope;
    };

    services.jack.alsa.support32Bit = cfg.audioSupport.jack;
    services.pipewire.alsa.support32Bit = cfg.audioSupport.pipewire;
    services.pulseaudio.support32Bit = true;
  };
}
