{ lib, config, pkgs, ... }: {
  options.oxc.desktop.simple-scan = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the Simple Scan application";
    };
  };

  config = lib.mkIf config.oxc.desktop.simple-scan.enable {
    environment.systemPackages = [ pkgs.gnome.simple-scan ];
  };
}
