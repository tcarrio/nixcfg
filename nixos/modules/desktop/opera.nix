{ lib, config, pkgs, ... }: {
  options.oxc.desktop.opera = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the Opera web browser";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.unstable.opera;
      description = "The package to install for the Opera web browser";
    };
  };

  config = lib.mkIf config.oxc.desktop.opera.enable {
    environment.systemPackages = [ config.oxc.desktop.opera.package ];
  };
}
