# see install/themes.sh
{ config, pkgs, lib, inputs, username, ... }:
let
  cfg = config.ominix;
in
{

  options.ominix = {
    theme = lib.mkOption {
      type = lib.types.enum [
        "catppuccin"
        "everforest"
        "gruvbox"
        "kanagawa"
        "nord"
        "tokyo-night"
      ];
      default = "tokyo-night";
      description = "The theme to use for Ominix";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.sessionVariables."OMINIX_THEME_DIRECTORY" = "${inputs.omarchy}/themes/${cfg.theme}";
  };
}
