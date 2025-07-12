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
        # TODO: link/copy remaining omarchy source files
        ".config/wofi/style.css".source = "${themeDir}/wofi.css";
        ".config/nvim/lua/plugins/theme.lua".source = "${themeDir}/neovim.lua";
        ".config/btop/themes/current.theme".source = "${themeDir}/btop.theme";
        ".config/mako/config".source = "${themeDir}/mako.ini";
      };

      # TODO: Add support for dark mode and missing packages
    }
  );
}
