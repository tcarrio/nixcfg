{ nixvim, pkgs }:
let
  nixvimConfig = (import ./config.nix { inherit pkgs; allowUnfree = true; });
  basePackage = nixvim.legacyPackages.${pkgs.system}.makeNixvimWithModule {
    inherit pkgs;
    module = { ... }: nixvimConfig // {
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
      nixvim.legacyPackages.${pkgs.system}.makeNixvimWithModule {
        inherit pkgs;
        module = { ... }: nixvimConfig // extraConfig // config // {
          extraPackages = with pkgs; [
            bat  # Rust-based syntax highlighter/pager for git
          ];
        };
      };
  };
})