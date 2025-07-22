{ pkgs, lib, ... }:
{
  environment.systemPackages = [ pkgs.spotify ];

  nixpkgs.config.allowUnfree = lib.mkForce true;
}
