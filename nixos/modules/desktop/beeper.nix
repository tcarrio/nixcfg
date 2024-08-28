{ lib, config, pkgs, ... }: {
  options.oxc.desktop.beeper = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the Beeper messager";
    };
  };

  config = lib.mkIf config.oxc.desktop.beeper.enable {
    environment.systemPackages = with pkgs; [
      beeper
    ];
  };
}
