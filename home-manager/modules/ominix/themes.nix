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

  config = lib.mkIf cfg.enable (
    let
      themeDir = "${inputs.omarchy}/themes/${cfg.theme}";
    in {
      home.file = {
        ".config/wofi/style.css" = "${themeDir}/theme/wofi.css";
        ".config/nvim/lua/plugins/theme.lua" = "${themeDir}/theme/neovim.lua";
        ".config/btop/themes/current.theme" = "${themeDir}/theme/btop.theme";
        ".config/mako/config" = "${themeDir}/theme/mako.ini";
      };
    }
  );
}
