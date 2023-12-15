{ pkgs, ... }:
let
  templateValues = {
    bin = {
      yabai = "${pkgs.yabai}";
    };
  };

  skhdConfig = pkgs.templateFile "skhdrc" ./skhd/skhd.conf.mustache templateValues;
in
{
  home.file.".config/skhd/skhdrc".source = "${skhdConfig}";
}
