{ lib, config, pkgs, ... }: {
  options.oxc.desktop.element = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the Element Matrix chat application";
    };
  };

  config = lib.mkIf config.oxc.desktop.element.enable {
    environment.systemPackages = with pkgs.unstable; [
      element-desktop
    ];
  };
}
