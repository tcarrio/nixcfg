{ lib, config, pkgs, ... }: {
  options.oxc.desktop.brave = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the Brave web browser";
    };
  };

  config = lib.mkIf config.oxc.desktop.brave.enable {
    environment.systemPackages = with pkgs; [
      brave
    ];
  };
}
