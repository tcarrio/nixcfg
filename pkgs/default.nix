# Custom packages, that can be defined similarly to ones from nixpkgs
# Build them using 'nix build .#example' or (legacy) 'nix-build -A example'

{ pkgs ? (import ../nixpkgs.nix) { } }: {
  ente-photos-desktop = pkgs.callPackage ./ente.nix { };
  zeit = pkgs.callPackage ./zeit.nix { };
}
