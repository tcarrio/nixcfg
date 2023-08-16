{ lib, ... }:
{
  nixpkgs.hostPlatform = lib.mkDefault "arm7l-linux";
  nixpkgs.crossSystem.system = "armv7l-linux";
}
