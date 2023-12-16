# Custom packages, that can be defined similarly to ones from nixpkgs
# Build them using 'nix build .#example' or (legacy) 'nix-build -A example'

{ pkgs ? (import ../nixpkgs.nix) { } }:
let
  install = path: pkgs.callPackage path { };
in
{
  auth0 = install ./auth0.nix;
  nordvpn = install ./nordvpn.nix;
}
