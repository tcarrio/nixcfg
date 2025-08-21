{ pkgs, config, lib, ... }:
let
  cfg = config.oxc.services.caffeinated;
  inherit (lib) mkIf mkOption strings types;
  caffeinateArgs = strings.concatStringsSep " " cfg.arguments;
in {
  options.oxc.services.caffeinated = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable the caffeinated service.";
    };
    arguments = mkOption {
      type = types.listOf types.str;
      default = [ "-dius" ];
      example = [ "-d" ];
      description = "Additional arguments to be passed to `caffeinate`.";
    };
  };

  config = mkIf cfg.enable {
    # This defines the caffeinated service to run at login
    launchd.user.agents.caffeinated = {
      script = "${pkgs.bash}/bin/bash -c 'caffeinate ${caffeinateArgs}";
      serviceConfig = {
        # Start at login
        RunAtLoad = true;
        # Keep the service running
        KeepAlive = true;
      };
    };
  };
}