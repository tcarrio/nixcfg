#!/usr/bin/env bash
set -e

NIXCFG_PATH="$HOME/0xc/nixcfg"

function bootstrapShell() {
  nix develop \
    --extra-experimental-features flakes \
    --extra-experimental-features nix-command \
    "$NIXCFG_PATH" \
    --command "$@"
}

# https://nixos.org/download/
if ! which nix; then
  if [ ! -d /nix ]; then
    echo "Installing nix..."
    sh <(curl -L https://nixos.org/nix/install)
  else
    echo "Nix is already installed, but not on your PATH. Please add it to your PATH and run this script again."
    exit 1
  fi
fi

if [ ! -d "$NIXCFG_PATH" ]; then
  mkdir -p "$NIXCFG_PATH"
  git clone git@gitub.com:tcarrio/nixcfg.git "$NIXCFG_PATH"
fi
pushd "$NIXCFG_PATH"

bootstrapShell nixos-rebuild switch --flake $NIXCFG_PATH
bootstrapShell home-manager init --switch --flake $NIXCFG_PATH
