{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    ente-photos-desktop
  ];

  boot.kernelModules = [ "fuse" ];
}