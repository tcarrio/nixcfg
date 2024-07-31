{ lib, ... }:
{
  imports = [
    ../mixins/services/bluetooth.nix
    ../mixins/services/pipewire.nix
    ../mixins/hardware/gpd-win-max.nix
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
