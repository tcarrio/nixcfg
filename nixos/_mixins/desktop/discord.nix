{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    discord-krisp
  ];
}
