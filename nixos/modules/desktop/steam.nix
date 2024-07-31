{ lib, config, ... }: {
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

  config = lib.mkIf config.oxc.desktop.steam.enable {
    # Ensure unfree software support is enabled
    oxc.nix.unfree.enable = true;

    # https://nixos.wiki/wiki/Steam
    fonts.fontconfig.cache32Bit = true;
    hardware.steam-hardware.enable = true;
    hardware.opengl.driSupport32Bit = true;

    programs.steam = {
      enable = true;
      # Open ports in the firewall for Steam Remote Play
      remotePlay.openFirewall = config.oxc.desktop.steam.steamPlay.firewall.open;
      # Open ports in the firewall for Source Dedicated Server
      dedicatedServer.openFirewall = config.oxc.desktop.steam.steamPlay.firewall.open;
    };

    services.jack.alsa.support32Bit = config.oxc.desktop.steam.audioSupport.jack;
    services.pipewire.alsa.support32Bit = config.oxc.desktop.steam.audioSupport.pipewire;
  };
}
