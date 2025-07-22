{ lib, pkgs, config, ... }:
with lib.hm.gvariant;
{
  imports = [
    ../../../../services/mpris-proxy.nix
  ];

  home = {
    sessionPath = [ ];
    sessionVariables = { };
    file = {
      "${config.xdg.configHome}/direnv/direnv.toml".text = builtins.readFile ./direnv.toml;
    };
    packages = with pkgs; [
      gotop
    ];
  };

  dconf.settings = {
    "org/gnome/desktop/background" = {
      picture-options = "zoom";
      picture-uri = "file:///home/tcarrio/Pictures/Wallpapers/mononoke-8k.png";
    };
  };
}
