{ lib, config, pkgs, ... }: {
  options.oxc.desktop.tilix = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the Tilix terminal";
    };
  };

  config = lib.mkIf config.oxc.desktop.tilix.enable {
    environment.systemPackages = [ pkgs.tilix ];
  };
}
