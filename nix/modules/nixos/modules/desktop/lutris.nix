{ lib, config, pkgs, ... }: {
  options.oxc.desktop.lutris = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the Lutris game management application";
    };

    wine = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to enable Wine";
      };
    };
  };

  config = lib.mkIf config.oxc.desktop.lutris.enable {
    environment.systemPackages = with pkgs; [
      lutris
    ] ++ lib.optionals config.oxc.desktop.lutris.wine.enable [
      wineWowPackages.stable
      winetricks
    ];
  };
}
