{ lib, config, pkgs, ... }: {
  options.oxc.desktop.evolution = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the Evolution mail client";
    };
  };

  config = lib.mkIf config.oxc.desktop.evolution.enable {
    environment = {
      systemPackages = with pkgs; [
        evolutionWithPlugins
      ];
    };
    programs.evolution.enable = true;

    # TODO: Conditional to GNOME?
    services.gnome.evolution-data-server.enable = true;
  };
}
