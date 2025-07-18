{ nixvim, pkgs }:
nixvim.legacyPackages.${pkgs.system}.makeNixvimWithModule {
  inherit pkgs;
  module = import ./config.nix;
}