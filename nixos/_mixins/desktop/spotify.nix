{ pkgs, ... }:
{
  imports = [
    ../services/unfree.nix
  ];

  environment.systemPackages = with pkgs; [ spotify ];
}
