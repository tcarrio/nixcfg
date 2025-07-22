{ lib, ... }:
{
  console.keyMap = lib.mkForce "us";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Some devices have RAID controllers that I want to utilize
  boot.swraid.enable = true;
}
