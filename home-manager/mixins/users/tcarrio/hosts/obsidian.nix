{ lib, pkgs, config, ... }:
let
  homeDir = config.home.homeDirectory;
in with lib.hm.gvariant;
{
  imports = [
    ../../../../services/mpris-proxy.nix
  ];

  home = {
    sessionPath = [ ];
    sessionVariables = { };
    file = {
      "${config.xdg.configHome}/direnv/direnv.toml".text = lib.mkDefault ''
        [global]
        load_dotenv = true
        strict_env = true

        [whitelist]
        prefix = [ "${homeDir}/Code" ]
      '';
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
