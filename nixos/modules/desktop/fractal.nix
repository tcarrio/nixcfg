{ lib, config, pkgs, ... }: {
  options.oxc.desktop.fractal = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the Fractal Matrix chat application";
    };
  };

  config = lib.mkIf config.oxc.desktop.fractal.enable {
    environment.systemPackages = with pkgs; [
      fractal
    ];
  };
}
