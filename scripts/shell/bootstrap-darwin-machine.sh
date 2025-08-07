#!/usr/bin/env bash
set -e

NIXCFG_PATH="$HOME/0xc/nixcfg"

HOSTNAME="${HOSTNAME:-$(hostname)}"
USERNAME=${USERNAME:-$(whoami)}

SYS_TARGET=$HOSTNAME
HM_TARGET="$USERNAME@$HOSTNAME"

function bootstrapShell() {
  nix develop \
    --extra-experimental-features flakes \
    --extra-experimental-features nix-command \
    "$NIXCFG_PATH" \
    --command "$@"
}

# https://nixos.org/download/
if ! which nix >/dev/null; then
  if [ ! -d /nix ]; then
    echo "Installing nix..."
    sh <(curl -L https://nixos.org/nix/install)
  else
    echo "Nix is already installed, but not on your PATH. Please add it to your PATH and run this script again."
    exit 1
  fi
fi

if ! which brew >/dev/null; then
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [ ! -d "$NIXCFG_PATH" ]; then
  mkdir -p "$NIXCFG_PATH"
  git clone git@gitub.com:tcarrio/nixcfg.git "$NIXCFG_PATH"
fi
pushd "$NIXCFG_PATH"

echo 'Building nix-darwin derivation...'
bootstrapShell sudo darwin-rebuild switch --flake $NIXCFG_PATH#${SYS_TARGET}
echo 'Initializing home-manager derivation...'
bootstrapShell home-manager init --flake $NIXCFG_PATH#${HM_TARGET}
echo 'Setting up home-manager derivation...'
bootstrapShell home-manager switch -b backup --flake $NIXCFG_PATH#${HM_TARGET}
echo 'Configuring default macOS shell... '
chsh -s "$HOME/.nix-profile/bin/fish" "$USERNAME"

