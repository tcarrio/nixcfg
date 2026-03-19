{ config, lib, pkgs, ... }:

let
  cfg = config.oxc.services.noisetorch;
in
{
  options.oxc.services.noisetorch = with lib; {
    enable = mkEnableOption "Enable the NoiseTorch program to provide noise suppression in audio devices";
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
      (pkgs.makeDesktopItem {
        name = "noisetorch-desktop";
        desktopName = "NoiseTorch";
        exec = ''
          ${config.security.wrapperDir}/noisetorch %F
        '';
        icon = "${pkgs.noisetorch}/share/icons/hicolor/256x256/apps/noisetorch.png";
      })
    ];
  };
}
