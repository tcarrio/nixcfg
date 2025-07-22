{ lib, ... }:
with lib.hm.gvariant;
{
  imports = [
    ../../../services/mpris-proxy.nix
  ];
  dconf.settings = {
    "org/gnome/desktop/background" = {
      picture-options = "zoom";
      picture-uri = "file:///home/tcarrio/Pictures/Wallpapers/mononoke-8k.png";
    };
  };
}
