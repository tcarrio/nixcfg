#!/usr/bin/env bash

#set -euo pipefail

TARGET_HOST="${1:-}"
TARGET_USER="${2:-tcarrio}"
TARGET_TYPE="${3:-}"
TARGET_NIXOS_CONFIG_NAME="${4:-$TARGET_HOST}"

function usage() {
  echo """
install.sh <host> <user> <system-type> [nixos-config-name]

example: install.sh t510 tcarrio workstation t510-headless
"""
}

if [ "$(id -u)" -eq 0 ]; then
  echo "ERROR! $(basename "$0") should be run as a regular user"
  exit 1
fi

if [ ! -d "$HOME/0xc/nixcfg/.git" ]; then
  git clone https://github.com/tcarrio/nixcfg.git "$HOME/0xc/nixcfg"
fi

pushd "$HOME/0xc/nixcfg" || exit

if [[ -z "$TARGET_HOST" ]]; then
  echo "ERROR! $(basename "$0") requires a hostname as the first argument"
  echo "       The following hosts are available"
  ls -1 nixos/*/default.nix | cut -d'/' -f2 | grep -v iso
  echo ""
  usage
  exit 1
fi

if [[ -z "$TARGET_USER" ]]; then
  echo "ERROR! $(basename "$0") requires a username as the second argument"
  echo "       The following users are available"
  ls -1 nixos/mixins/users/ | grep -v -E "nixos|root"
  echo ""
  usage
  exit 1
fi

if [[ -z "$TARGET_TYPE" ]]; then
  echo "ERROR! $(basename "$0") requires a type as the third argument"
  echo "       The following types are available"
  ls -1 nixos/ | grep -v -E "nixos|root|mixins"
  echo ""
  usage
  exit 1
fi

TARGET_HOST_ROOT="nixos/$TARGET_TYPE/$TARGET_HOST"

if [ ! -e "$TARGET_HOST_ROOT/disks.nix" ]; then
  echo "ERROR! $(basename "$0") could not find the required $TARGET_HOST_ROOT/disks.nix"
  exit 1
fi

# Check if the machine we're provisioning expects a keyfile to unlock a disk.
# If it does, generate a new key, and write to a known location.
if grep -q "data.keyfile" "$TARGET_HOST_ROOT/disks.nix"; then
  echo -n "$(head -c32 /dev/random | base64)" > /tmp/data.keyfile
fi


# Applying Disko configuration
DISKO_STEP_CHOICE=$(gum filter "Apply" "Mount" "Skip" "Cancel")

case "$DISKO_STEP_CHOICE" in
  Overwrite)
    echo "WARNING! The disks in $TARGET_HOST are about to get wiped"
    echo "         NixOS will be re-installed"
    echo "         This is a destructive operation"
    echo

    gum confirm "Are you sure?"
    echo

    sudo true # just confirming sudo access before execution

    sudo nix run github:nix-community/disko \
      --extra-experimental-features "nix-command flakes" \
      --no-write-lock-file \
      -- \
      --mode destroy,format,mount \
      "$TARGET_HOST_ROOT/disks.nix"
    ;;
  Mount)
    echo "Mounting disks based on Disko config..."
    sudo nix run github:nix-community/disko \
      --extra-experimental-features "nix-command flakes" \
      --no-write-lock-file \
      -- \
      --mode mount \
      "$TARGET_HOST_ROOT/disks.nix"
    ;;
  Cancel)
    echo "Installation cancelled!"
    exit 1
    ;;
  Skip)
    echo "Continuing install without applying Disko config to disks..."
    ;;
esac

if [ -z "$MAX_CONCURRENCY" ]; then
  MAX_CONCURRENCY=$(($(nproc) - 1))
fi

sudo nixos-install -j "$MAX_CONCURRENCY" --cores "$MAX_CONCURRENCY" --no-root-password --flake ".#$TARGET_NIXOS_CONFIG_NAME"

if [[ "$TARGET_USER" == "root" ]]; then
  TARGET_USER_HOME="/mnt/root"
else
  TARGET_USER_HOME="/mnt/home/$TARGET_USER"
fi

# Rsync nixcfg to the target install and set the remote origin to SSH.
sudo mkdir -p "$TARGET_USER_HOME"
sudo chown $(whoami):root -R "$TARGET_USER_HOME"
rsync -a --delete "$HOME/0xc/" "$TARGET_USER_HOME/0xc/"
pushd "$TARGET_USER_HOME/0xc/nixcfg" || exit
git remote set-url origin git@github.com:tcarrio/nixcfg.git
popd || exit

# If there is a keyfile for a data disk, put copy it to the root partition and
# ensure the permissions are set appropriately.
if [[ -f "/tmp/data.keyfile" ]]; then
  sudo cp /tmp/data.keyfile /mnt/etc/data.keyfile
  sudo chmod 0400 /mnt/etc/data.keyfile
fi
