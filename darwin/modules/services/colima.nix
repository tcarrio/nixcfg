{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.oxc.services.colima;
  colima = pkgs.colima;

in {
  options.oxc = {
    services.colima = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description =
          "Whether to enable the Colima container service.";
      };
      arguments = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [ "containerd" ];
        description = "Additional arguments to be passed to `colima start`.";
      };
    };
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [ colima ];

    launchd.daemons.colima = {
      path = [ colima ];
      serviceConfig.Program = "${colima}/bin/colima";
      serviceConfig.ProgramArguments =
        [ "start" ] ++ cfg.arguments;
      serviceConfig.KeepAlive = false;
      serviceConfig.RunAtLoad = true;
    };

  };
}
