{ pkgs, ... }:
{
  # Deckmaster and the utilities I bind to the Stream Deck
  home.packages = with pkgs; [
    deckmaster
    hueadm
    obs-cli
    playerctl
  ];
}
