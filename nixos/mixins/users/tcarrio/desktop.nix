{ desktop, pkgs, lib, ... }: {
  imports = lib.optional (builtins.pathExists (../.. + "/desktop/${desktop}.nix")) ../../desktop/${desktop}.nix
    ++ lib.optional (builtins.pathExists (../.. + "/desktop/${desktop}-apps.nix")) ../../desktop/${desktop}-apps.nix;

  oxc.desktop = {
    beeper.enable = true;
    chromium.enable = true;
    discord.enable = true;
    firefox.enable = true;
    google-chrome.enable = true;
    lutris.enable = true;
    spotify.enable = true;
    vscode.enable = true;
  };

  environment.systemPackages = with pkgs; [
    audio-recorder
    dconf-editor
    gimp-with-plugins
    inkscape
    libreoffice
    meld
    pick-colour-picker
    slack
  ];
}
