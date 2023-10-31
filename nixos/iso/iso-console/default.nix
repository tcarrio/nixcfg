{ lib, ... }:
{
  console.keyMap = lib.mkForce "us";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
