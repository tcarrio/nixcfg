{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.oxc.console.zeit;
in
{
  options.oxc.console.zeit = {
    enable = lib.mkEnableOption "zeit time tracking with XDG db location";

    # Default is the custom package from the additions overlay; external
    # consumers supply their own.
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.zeit;
      defaultText = lib.literalExpression "pkgs.zeit (additions overlay)";
      description = "The zeit package to install";
    };
  };

  config = lib.mkIf cfg.enable {
    home.sessionVariables.ZEIT_DB = "${config.xdg.configHome}/zeit/zeit.db";
    home.packages = [ cfg.package ];
  };
}
