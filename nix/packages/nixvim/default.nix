{ pkgs, inputs, system }:
let
  inherit (inputs) nixvim;

  basePackage = nixvim.legacyPackages.${system}.makeNixvimWithModule {
    inherit pkgs;
    module = { ... }: (import ./config.nix { inherit pkgs; allowUnfree = true; }) // {
      extraPackages = with pkgs; [
        bat  # Rust-based syntax highlighter/pager for git
      ];
    };
  };
in
basePackage.overrideAttrs (oldAttrs: {
  passthru = (oldAttrs.passthru or {}) // {
    # Override function to customize nixvim configuration
    override = args: 
      let
        allowUnfree = args.allowUnfree or true;
        extraConfig = args.extraConfig or {};
        config = args.config or {};
      in
      nixvim.legacyPackages.${system}.makeNixvimWithModule {
        inherit pkgs;
        module = { ... }: (import ./config.nix { inherit pkgs allowUnfree; }) // extraConfig // config // {
          extraPackages = with pkgs; [
            bat  # Rust-based syntax highlighter/pager for git
          ];
        };
      };
  };
})