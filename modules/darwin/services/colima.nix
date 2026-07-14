{
  config,
  lib,
  pkgs,
  username,
  ...
}:

with lib;

let
  cfg = config.oxc.services.colima;
  inherit (pkgs) colima;

in
{
  options.oxc = {
    services.colima = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to enable the Colima container service.";
      };
      arguments = mkOption {
        type = types.listOf types.str;
        default = [ ];
        example = [ "containerd" ];
        description = "Additional arguments to be passed to `colima start`.";
      };
      automaticBoot = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to start the Colima service at boot time.";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      colima
      docker_29
      docker-compose
    ];

    launchd.daemons.colima = lib.mkIf cfg.automaticBoot {
      path = [ colima ];
      serviceConfig = {
        Program = "${colima}/bin/colima";
        ProgramArguments = [ "start" ] ++ cfg.arguments;
        KeepAlive = false;
        RunAtLoad = true;
        UserName = username;
      };
    };
  };
}
