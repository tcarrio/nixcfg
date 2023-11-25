{ pkgs, ... }:
let
  theme = {
    colors = {
      black = "#282c34";
      blue = "#61afef";
      yellow = "#e5c07b";
      red = "#06c75";
      white = "#aab2bf";
      green = "#98c379";
      visual_grey = "#3e4452";
      comment_grey = "#5c6370";
    };
  };
  themeFile = pkgs.templateFile "onedark-theme.tmux" ./tmux/theme.tmux.mustache theme;
  tmuxConfig = pkgs.templateFile "tmux.conf" ./tmux/tmux.conf.mustache { theme.path = "${themeFile}"; };
in
{
  home.file.".tmux.conf".source = "${tmuxConfig}";
}
