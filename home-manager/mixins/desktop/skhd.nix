{ pkgs, ... }:
let
  templateValues = {
    bin = {
      yabai = "${pkgs.yabai}";
    };
  };

  skhdConfig = pkgs.mustacheTemplate "skhdrc" ./skhd/skhd.conf.tpl templateValues;
in
{
  home.file.".config/skhd/skhdrc".source = "${skhdConfig}";
}
