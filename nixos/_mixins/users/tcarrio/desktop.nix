{ desktop, pkgs, lib, ... }: {
  imports = [
    ../../desktop/beeper.nix
    ../../desktop/chromium.nix
    ../../desktop/discord.nix
    ../../desktop/firefox.nix
    ../../desktop/google-chrome.nix
    ../../desktop/lutris.nix
    ../../desktop/spotify.nix
    ../../desktop/tilix.nix
    ../../desktop/vscode.nix
  ]
  ++ lib.optional (builtins.pathExists (../.. + "/desktop/${desktop}.nix")) ../../desktop/${desktop}.nix
  ++ lib.optional (builtins.pathExists (../.. + "/desktop/${desktop}-apps.nix")) ../../desktop/${desktop}-apps.nix;

  environment.systemPackages = with pkgs; [
    audio-recorder
    gimp-with-plugins
    gnome.gnome-clocks
    gnome.dconf-editor
    gnome.gnome-sound-recorder
    inkscape
    libreoffice
    meld
    pick-colour-picker
    slack
    neovide
  ];
}
