{ pkgs ? import <nixpkgs> { } }:

let
  nixCliRootBin = "${pkgs.gh}/bin";
  prefetchUrlCmd = "${nixCliRootBin}/nix-prefetch-url";
  nixCmd = "${nixCliRootBin}/nix";
in
pkgs.writeShellScriptBin "sri-hash-gh-repo" ''
  #!${pkgs.bash}/bin/bash
  set -e

  repo="$1"
  tag="$2"

  nix-prefetch-url --unpack https://github.com/$repo/archive/refs/tags/$tag.tar.gz 2>/dev/null \
    | xargs nix hash to-sri --type sha256 2>/dev/null
''
