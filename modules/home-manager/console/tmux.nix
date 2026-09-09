{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.oxc.console.tmux;

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
  themeFile = pkgs.mustacheTemplate "onedark-theme.tmux" ./tmux/theme.tmux.tpl theme;
  tmuxConfig = pkgs.mustacheTemplate "tmux.conf" ./tmux/tmux.conf.tpl {
    theme.path = "${themeFile}";
  };
in
{
  options.oxc.console.tmux = {
    enable = lib.mkEnableOption "tmux with the oxc onedark theme configuration";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.tmux ];
    home.file.".tmux.conf".source = "${tmuxConfig}";
  };
}
