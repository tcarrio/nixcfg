{ lib, config, ... }: {
  oxc.services.tailscale.enable = true;
  oxc.services.tailscale.autoconnect = false;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
