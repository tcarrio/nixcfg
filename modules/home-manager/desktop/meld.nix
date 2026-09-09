{
  lib,
  config,
  ...
}:
let
  cfg = config.oxc.desktop.meld;
in
with lib.hm.gvariant;
{
  options.oxc.desktop.meld = {
    enable = lib.mkEnableOption "Meld diff tool dconf settings";
  };

  config = lib.mkIf cfg.enable {
    dconf.settings."org/gnome/meld" = {
      indent-width = 4;
      insert-spaces-instead-of-tabs = true;
      highlight-current-line = true;
      show-line-numbers = true;
      prefer-dark-theme = true;
      highlight-syntax = true;
      style-scheme = "Yaru-dark";
    };
  };
}
