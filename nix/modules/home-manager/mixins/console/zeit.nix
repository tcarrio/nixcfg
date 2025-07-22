{ pkgs, config, ... }: {
  home.sessionVariables.ZEIT_DB = "${config.xdg.configHome}/zeit/zeit.db";

  home.packages = with pkgs; [ zeit ];
}
