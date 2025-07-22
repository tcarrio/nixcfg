{ lib, config, pkgs, desktop, ... }: {
  options.oxc.desktop.ente = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the Ente photo management application";
    };
  };

  config = lib.mkIf config.oxc.desktop.ente.enable {
    environment.systemPackages = with pkgs; [
      ente-cli
      ente-desktop
    ];
  };
}
