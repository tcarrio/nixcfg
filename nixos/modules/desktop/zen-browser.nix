{ lib, config, platform, inputs, ... }:
let
  debugValue = builtins.trace "Value of system (trace)" config.system;
  debugSystem = lib.debug.traceVal "Value of system (traceVal)" config.system;
in
{
  options.oxc.desktop.zen-browser = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to enable the Zen browser";
    };

    type = lib.mkOption {
      type = lib.types.enum [ "generic" "specific" ];
      default = "generic";
      description = "The build type to use for Zen browser";
    };
  };

  config = lib.mkIf config.oxc.desktop.zen-browser.enable {
    environment.systemPackages = [
      inputs.zen-browser.packages."x86_64-linux"."${config.oxc.desktop.zen-browser.type}"
    ];
  };
}
