# see install/xtras.sh
{ config, pkgs, lib, ... }: {
  config = lib.mkIf config.ominix.enable {
    environment.systemPackages = with pkgs; [
      gnome-calculator
      signal-desktop
      spotify
      dropbox-cli
      # TODO: Re-enable Zoom, broken hash
      # zoom-us # for zoom
      obsidian # for obsidian-bin
      typora
      libreoffice
      obs-studio
      kdePackages.kdenlive # for kdenlive
      _1password-gui-beta # for 1password-beta
      _1password-cli # for 1password-cli
      gnome-keyring
      pinta
      xournalpp
      localsend # for localsend-bin
    ];
  };
}
