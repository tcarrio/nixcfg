{ config, lib, pkgs, ... }:

let
  cfg = config.oxc.services.noisetorch;
in
{
  options.oxc.services.noisetorch = with lib; {
    enable = mkEnableOption "noisetorch";
  };

  config = lib.mkIf cfg.enable {
    security.wrappers.noisetorch = {
      owner = "root";
      group = "root";
      # Upstream doc: sudo setcap 'CAP_SYS_RESOURCE=+ep' ~/.local/bin/noisetorch
      capabilities = "cap_sys_resource+ep";
      source = "${pkgs.noisetorch}/bin/noisetorch";
    };
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "noisetorch" ''
        #!/bin/bash
        exec ${config.security.wrapperDir}/noisetorch "$@"
      '')
    ];
    # systemd.user.services.noisetorch = {
    #   description = "noisetorch";
    #   startLimitBurst = 5;
    #   startLimitIntervalSec = 500;
    #   serviceConfig = {
    #     ExecStart = "${config.security.wrapperDir}/noisetorch";
    #     Restart = "on-failure";
    #     RestartSec = "5s";
    #   };
    # };
  };
}