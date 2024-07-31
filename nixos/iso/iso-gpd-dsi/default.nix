{ lib, ... }:
{
  # Pocket, Pocket 3, MicroPC, Win 3, TopJoy Falcon
  imports = [
    ../mixins/services/bluetooth.nix
    ../mixins/services/pipewire.nix
    ../mixins/hardware/gpd-dsi.nix
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
