{ lib, config, pkgs, ... }: {
  options.oxc.desktop.emacs = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the Emacs operating system";
    };
  };

  config = lib.mkIf config.oxc.desktop.emacs.enable {
    environment.systemPackages = [ pkgs.emacs ];
  };
}
