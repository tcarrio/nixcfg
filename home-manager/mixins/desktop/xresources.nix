{ config, pkgs, lib, ... }:
let
  inherit (config.oxc.palette) colors;
  inherit (pkgs.stdenv.hostPlatform) system;
in
lib.mkIf (system == "linux") {
  xresources.properties = {
    "XTerm*background" = colors.color0;
    "XTerm*foreground" = colors.color7;
    "XTerm*cursorBlink" = true;
    "XTerm*cursorColor" = colors.color11;
    "XTerm*boldColors" = false;

    #Black + DarkGrey
    "*color0" = colors.color0;
    "*color8" = colors.color8;
    #DarkRed + Red
    "*color1" = colors.color1;
    "*color9" = colors.color9;
    #DarkGreen + Green
    "*color2" = colors.color2;
    "*color10" = colors.color10;
    #DarkYellow + Yellow
    "*color3" = colors.color3;
    "*color11" = colors.color11;
    #DarkBlue + Blue
    "*color4" = colors.color4;
    "*color12" = colors.color12;
    #DarkMagenta + Magenta
    "*color5" = colors.color5;
    "*color13" = colors.color13;
    #DarkCyan + Cyan
    "*color6" = colors.color6;
    "*color14" = colors.color14;
    #LightGrey + White
    "*color7" = colors.color7;
    "*color15" = colors.color15;
    "XTerm*faceName" = "FiraCode Nerd Font:size=11:style=Medium:antialias=true";
    "XTerm*boldFont" = "FiraCode Nerd Font:size=11:style=Bold:antialias=true";
    "XTerm*geometry" = "132x50";
    "XTerm.termName" = "xterm-256color";
    "XTerm*locale" = false;
    "XTerm*utf8" = true;
  };
}
