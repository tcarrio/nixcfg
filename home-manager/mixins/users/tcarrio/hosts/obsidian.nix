{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  homeDir = config.home.homeDirectory;
in
with lib.hm.gvariant;
{
  imports = [
    ../../../services/mpris-proxy.nix
  ];

  # Cross-platform speech-to-text assistant
  services.handy.enable = true;
  services.handy.package = inputs.handy.packages.${pkgs.stdenv.hostPlatform.system}.default;
  dconf.settings."org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/handy0" = {
    name = "handy transcription toggle";
    command = "handy --toggle-transcription";
    binding = "<Ctrl>space";
  };

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
      unstable.opencode
      unstable.opencode-desktop
    ];
  };

  dconf.settings = {
    "org/gnome/desktop/background" = {
      picture-options = "zoom";
      picture-uri = "file://${config.home.homeDirectory}/Pictures/Wallpapers/mononoke-8k.png";
    };
  };
}
