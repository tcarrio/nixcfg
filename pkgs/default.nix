# Custom packages, that can be defined similarly to ones from nixpkgs
# Build them using 'nix build .#example' or (legacy) 'nix-build -A example'

{ pkgs ? (import ../nixpkgs.nix) { } }: {
  ente-photos-desktop = pkgs.callPackage ./ente.nix { };
  tte = pkgs.callPackage
    (pkgs.fetchFromGitHub {
      owner = "ChrisBuilds";
      repo = "terminaltexteffects";
      rev = "7fd566567cdf3bafe8bf8b8866ca84afc8704ebd";
      hash = "sha256-33Gp5dkAtbdmqyeLDKKiCF9735GM4YX/tY+S/p7+KMA=";
    })
    { };
}
