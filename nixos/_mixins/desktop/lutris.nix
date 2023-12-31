{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    lutris
    wineWowPackages.stable
    winetricks
  ];
}
