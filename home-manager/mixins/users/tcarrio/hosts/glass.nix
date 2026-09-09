{ lib, config, ... }:
with lib.hm.gvariant;
{
  oxc.services.mpris-proxy.enable = true;

  dconf.settings = {
    "org/gnome/desktop/background" = {
      picture-options = "zoom";
      picture-uri = "file://${config.home.homeDirectory}/Pictures/Wallpapers/mononoke-8k.png";
    };
  };
}
