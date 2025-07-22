# To re-enable, include the following in flake.nix
#
# nix-doom-emacs.url = "github:nix-community/nix-doom-emacs";
# nix-doom-emacs.inputs.nixpkgs.follows = "nixpkgs";

{ inputs, ... }: {
  imports = [
    inputs.nix-doom-emacs.hmModule
  ];

  programs.doom-emacs = {
    enable = true;
    doomPrivateDir = ./doom.d; # Directory containing your config.el, init.el
    # and packages.el files
  };
}
