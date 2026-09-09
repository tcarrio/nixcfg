{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  homeDir = config.home.homeDirectory;
  handyPkg = inputs.handy.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
with lib.hm.gvariant;
{
  imports = [ ];

  oxc.services.mpris-proxy.enable = true;

  # Le Code: Mistral Le Chat code-session web app launcher
  oxc.desktop.web-app = {
    enable = true;
    name = "le-code";
    comment = "Launch Le Chat directly to Code Sessions";
    url = "https://chat.mistral.ai/code_session";
    icon = ./lechat.png;
  };

  # Cross-platform speech-to-text assistant
  services.handy.enable = true;
  services.handy.package = handyPkg;
  dconf.settings."org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/handy0" = {
    name = "handy transcription toggle";
    command = "${handyPkg}/bin/handy --toggle-transcription";
    binding = "<Ctrl>space";
  };
  dconf.settings."org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/handy1" = {
    name = "handy transcription cancel";
    command = "${handyPkg}/bin/handy --cancel";
    binding = "<Ctrl>escape";
  };
  dconf.settings."org/gnome/settings-daemon/plugins/media-keys" = {
    custom-keybindings = [
      "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/handy0/"
      "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/handy1/"
    ];
  };

  # direnv whitelist via the console module (single owner of direnv.toml)
  oxc.console.direnv.whitelistPrefixes = [ "${homeDir}/Code" ];

  home = {
    sessionPath = [ ];
    sessionVariables = { };
    packages = with pkgs.unstable; [
      gotop
      opencode
      opencode-desktop
    ];
  };

  dconf.settings = {
    "org/gnome/desktop/background" = {
      picture-options = "zoom";
      picture-uri = "file://${config.home.homeDirectory}/Pictures/Wallpapers/mononoke-8k.png";
    };
  };
}
