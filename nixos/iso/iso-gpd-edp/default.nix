{ lib, ... }:
{
  # Pocket 2, Win 2, Win Max
  imports = [
    ../mixins/services/bluetooth.nix
    ../mixins/services/pipewire.nix
    ../mixins/hardware/gpd-edp.nix
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
