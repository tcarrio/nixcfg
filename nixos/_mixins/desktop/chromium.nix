{ lib, config, pkgs, ... }: {
  options.oxc.desktop.chromium = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the Chromium web browser";
    };
    # TODO: Support for browser integrations?
  };

  config = lib.mkIf config.oxc.desktop.chromium.enable {
    environment.systemPackages = with pkgs; [
      chromium
    ];
  };
}
