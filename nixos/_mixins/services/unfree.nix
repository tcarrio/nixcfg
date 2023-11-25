{ lib ? { mkForce = x: x; }, ... }: {
  nixpkgs.config.allowUnfree = lib.mkForce true;
}
