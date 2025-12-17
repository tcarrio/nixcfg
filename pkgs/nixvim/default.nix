{ nixvim, pkgs }:
let
  inherit (pkgs) system;
  nixvimConfig = import ./config.nix {
    inherit pkgs;
    allowUnfree = true;
  };
in
nixvim.legacyPackages.${system}.makeNixvimWithModule {
  inherit pkgs;
  module = _: nixvimConfig // {
    extraPackages = with pkgs; [
      bat # Rust-based syntax highlighter/pager for git
    ];
  };
}
