{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.oxc.endcord;

  endcordPkg =
    if cfg.enableMedia then
      cfg.package.override { withMedia = true; }
    else
      cfg.package;
in
{
  options.oxc.endcord = {
    enable = lib.mkEnableOption "endcord Discord TUI client";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.endcord;
      description = "The endcord package to use";
    };

    enableMedia = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable terminal ASCII media rendering support";
    };

    configuration = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Configuration written to $XDG_CONFIG_DIR/endcord/config.ini";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ endcordPkg ];

    xdg.configFile."endcord/config.ini" = lib.mkIf (cfg.configuration != { }) {
      text = lib.generators.toINI { } cfg.configuration;
    };
  };
}
