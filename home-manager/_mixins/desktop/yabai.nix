{ pkgs, ... }:
let
  templateValues = {
    bin = {
      yabai = "${pkgs.yabai}";
    };
  };

  yabaiConfig = pkgs.templateFile "yabairc" ./yabai/yabai.conf.tpl templateValues;
in
{
  home.file.".config/yabai/yabairc".source = "${yabaiConfig}";
}
