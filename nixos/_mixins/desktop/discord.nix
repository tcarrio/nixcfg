{ pkgs, ... }:
{
  environment.systemPackages = with pkgs.unstable; [ discord ];
}
