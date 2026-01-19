#!/usr/bin/env bash
set -e

NIXCFG_PATH="$HOME/0xc/nixcfg"

HOSTNAME="${HOSTNAME:-$(hostname)}"
USERNAME=${USERNAME:-$(whoami)}

SYS_TARGET=$HOSTNAME
HM_TARGET="$USERNAME@$HOSTNAME"

DETERMINATE_NIX="${DETERMINATE_NIX:-true}"

function bootstrapShell() {
  nix develop \
    --extra-experimental-features flakes \
    --extra-experimental-features nix-command \
    --extra-experimental-features pipe-operators \
    "$NIXCFG_PATH" \
    --command "$@"
}

# https://nixos.org/download/
if ! which nix >/dev/null; then
  if [ ! -d /nix/store ]; then
    if [ "$DETERMINATE_NIX" == "true" ]; then
      pushd $(mktemp -d) >/dev/null
      wget -O Determinate.pkg https://install.determinate.systems/determinate-pkg/stable/Universal
      open -W ./Determinate.pkg
      popd >/dev/null

      if ! test -f /usr/local/bin/determinate-nixd; then
        echo 'Determinate Nix installed successfully'
      else
        echo 'Determinate Nix install was not successful'
        exit 1
      fi
    else
      echo "Installing nix..."
      sh <(curl -L https://nixos.org/nix/install)
    fi
  elif [ -d "/nix/var/nix/profiles/default/bin" ]; then
      export PATH="/nix/var/nix/profiles/default/bin:$PATH"
      echo "Added system Nix to PATH"
  else
    echo "Nix is already installed, but not on your PATH. Please add it to your PATH and run this script again."
    exit 1
  fi
else
  # Nix installed and in PATH, but if Determinate is preferred, verify it is installed
  if [ "$DETERMINATE_NIX" == "true" ] && ! [[ "$(nix --version)" =~ Determinate\ Nix ]]; then
    echo "Nix is installed, but the expected Determinate Nix install was not found!"
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
bootstrapShell sudo darwin-rebuild switch --flake "$NIXCFG_PATH"#"${SYS_TARGET}"
echo 'Initializing home-manager derivation...'
bootstrapShell home-manager init --flake "$NIXCFG_PATH"#"${HM_TARGET}"
echo 'Setting up home-manager derivation...'
bootstrapShell home-manager switch -b backup --flake "$NIXCFG_PATH"#"${HM_TARGET}"
echo 'Configuring default macOS shell... '
chsh -s "$HOME/.nix-profile/bin/fish" "$USERNAME"
