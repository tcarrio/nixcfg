{ lib, config, inputs, ... }:
{
  options.oxc.desktop.zen-browser = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the Zen browser";
    };
  };

  config = lib.mkIf config.oxc.desktop.zen-browser.enable {
    environment.systemPackages = [
      inputs.zen-browser.packages."x86_64-linux".default
    ];
  };
}
