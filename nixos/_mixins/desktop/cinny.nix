{ lib, config, pkgs, ... }: {
  options.oxc.desktop.cinny = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the Cinny messager";
    };
  };

  config = lib.mkIf config.oxc.desktop.cinny.enable {
    environment.systemPackages = with pkgs; [
      cinny-desktop
    ];
  };
}
