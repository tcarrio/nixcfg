{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.oxc.desktop.emote;
in
{
  options.oxc.desktop.emote = {
    enable = lib.mkEnableOption "the Emote emoji picker (Linux, user service)";
  };

  config = lib.mkIf (cfg.enable && pkgs.stdenv.hostPlatform.isLinux) {
    # https://github.com/tom-james-watson/emote
    home.packages = [ pkgs.emote ];

    systemd.user.services.emote = {
      Unit.Description = "Emote";
      Service = {
        ExecStart = "${pkgs.emote}/bin/emote";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "default.target" ];
    };
  };
}
