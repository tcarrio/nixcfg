{ lib, config, pkgs, ... }: {
  options.oxc.desktop.ente = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the Ente photo management application";
    };
  };

  config = lib.mkIf config.oxc.desktop.ente.enable {
    boot.kernelModules = [ "fuse" ];

    environment.systemPackages = with pkgs; [
      ente-photos-desktop
    ];
  };
}
