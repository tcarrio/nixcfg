{
  lib,
  config,
  ...
}:
let
  cfg = config.oxc.desktop.discord;
in
{
  options.oxc.desktop.discord = {
    enable = lib.mkEnableOption "Discord desktop settings (skip host update)";
  };

  config = lib.mkIf cfg.enable {
    home.file."${config.xdg.configHome}/discord/settings.json".text = builtins.toJSON {
      SKIP_HOST_UPDATE = true;
    };
  };
}
