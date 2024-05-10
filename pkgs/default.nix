# Custom packages, that can be defined similarly to ones from nixpkgs
# Build them using 'nix build .#example' or (legacy) 'nix-build -A example'

{ pkgs ? (import ../nixpkgs.nix) { } }: {
  auth0 = pkgs.callPackage ./auth0.nix { };
  encore-bin = pkgs.callPackage ./encore-bin.nix { };
  ente-photos-desktop = pkgs.callPackage ./ente.nix { };
  charm-freeze = pkgs.callPackage ./charm-freeze.nix { };
}
