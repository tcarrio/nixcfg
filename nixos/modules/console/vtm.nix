{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.xserver.windowManager.vtm;
  vtm = pkgs.vtm-latest;
in
{
  options = {
    services.xserver.windowManager.vtm = {
      enable = mkEnableOption "vtm";
      # TODO: Add option for overriding package
    };
  };

  config = mkIf cfg.enable {
    services.xserver.windowManager.session = singleton {
      name = "vtm";
      start = ''
        ${vtm}/bin/vtm
      '';
    };
    environment.systemPackages = [ vtm ];
  };
}