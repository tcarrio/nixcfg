{ nixvim, pkgs }:
nixvim.legacyPackages.${pkgs.system}.makeNixvimWithModule {
  inherit pkgs;
  module = { ... }: (import ./config.nix { inherit pkgs; }) // {
    extraPackages = with pkgs; [
      bat  # Rust-based syntax highlighter/pager for git
    ];
  };
}