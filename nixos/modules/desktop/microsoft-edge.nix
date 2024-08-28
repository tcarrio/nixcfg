{ lib, config, pkgs, ... }: {
  options.oxc.desktop.ms-edge = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the Edge web browser";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.microsoft-edge;
      description = "The package to install for the Edge web browser";
    };
  };

  config = lib.mkIf config.oxc.desktop.ms-edge.enable {
    environment.systemPackages = [ config.oxc.desktop.ms-edge.package ];
  };
}
