#!/usr/bin/env bash

set -euo pipefail
SCRIPT_NAME="$(basename "$0")"

# Global CLI handlers
function cli::error_handler() {
  local exit_code="$?"
  echo "ERROR in $SCRIPT_NAME :: An error occurred during execution!" >&3
  exit "$exit_code"
}
function cli::interrupt_handler() {
  echo "ERROR in $SCRIPT_NAME :: The end user has cancelled the script!" >&3
  exit 0
}
trap 'cli::error_handler' ERR
trap 'cli::interrupt_handler' INT

# CONTEXTUAL
if [[ -z "${MAX_CONCURRENCY+set}" ]]; then
  MAX_CONCURRENCY=$(($(nproc) - 1))
fi

# CONSTANTS
UPSTREAM_REPO="https://github.com/tcarrio/nixcfg.git"
CONFIG_DIR="$HOME/0xc/nixcfg"


# PARAMETERS
TARGET_HOST="${1:-}"
TARGET_USER="${2:-}"
TARGET_TYPE="${3:-}"

TARGET_HOST_ROOT="nixos/$TARGET_TYPE/$TARGET_HOST"

TARGET_USER_HOME="/mnt/home/$TARGET_USER"
if [[ "$TARGET_USER" == "root" ]]; then
  TARGET_USER_HOME="/mnt/root"
fi

function disko::run() {
  local disko_config
  disko_config="$1"

  local disko_mode
  disko_mode="${2:-destroy,format,mount}"

  if ! command -v disko >/dev/null 2>/dev/null; then
    sudo nix run github:nix-community/disko \
        --extra-experimental-features "nix-command flakes" \
        --no-write-lock-file \
        -- \
        --mode "$disko_mode" "$@" "$disko_config"
  else
    sudo disko --mode "$disko_mode" "$@" "$disko_config"
  fi
}

function disko::run_with_prompt() {
  local disko_config="$1"

  # If the requested config doesn't exist, skip it.
  if [ ! -e "$disko_config" ]; then
      return
  fi

  # Use globally set strategy from env var or prompt user
  disko_step_choice="${DISKO_STRATEGY:-$(gum filter --height=7 "Apply" "Mount" "Skip" "Cancel")}"

  case "$disko_step_choice" in
    Apply)
      echo "WARNING! The disks in $TARGET_HOST are about to get wiped"
      echo "         NixOS will be re-installed"
      echo "         This is a destructive operation"
      echo

      gum confirm "Are you sure?" || exit 0
      echo

      sudo true # confirming sudo access before execution
      disko::run "$disko_config" "destroy,format,mount"
      ;;
    Mount)
      echo "Mounting disks based on Disko config..."
      disko::run "$disko_config" "mount"
      ;;
    Cancel)
      echo "Installation cancelled!"
      exit 1
      ;;
    Skip)
      echo "Continuing install without applying Disko config to disks..."
      ;;
  esac
}

function cli::usage() {
  echo """
install.sh <host> <user> <system-type>

example: install.sh t510 tcarrio workstation
"""
}

function cli::ensure_git_cloned() {
  if [ ! -d "$CONFIG_DIR/.git" ]; then
    git clone "$UPSTREAM_REPO" "$CONFIG_DIR"
  fi
}

function cli::enter_config_working_dir() {
  pushd "$CONFIG_DIR" || exit
}

function cli::rsync_data() {
  # Rsync nixcfg to the target install and set the remote origin to SSH.
  sudo mkdir -p "$TARGET_USER_HOME"
  sudo chown "$(whoami)":root -R "$TARGET_USER_HOME"
  rsync -a --delete "$HOME/0xc/" "$TARGET_USER_HOME/0xc/"
  pushd "$TARGET_USER_HOME/0xc/nixcfg" || exit
  git remote set-url origin "$UPSTREAM_REPO"
  popd || exit
}

function cli::copy_disk_encryption_key() {
  # If there is a keyfile for a data disk, put copy it to the root partition and
  # ensure the permissions are set appropriately.
  if [[ -f "/tmp/data.keyfile" ]]; then
    sudo cp /tmp/data.keyfile /mnt/etc/data.keyfile
    sudo chmod 0400 /mnt/etc/data.keyfile
  fi
}

function cli::validate_user() {
  if [ "$(id -u)" -eq 0 ]; then
    echo "ERROR! $(basename "$0") should be run as a regular user"
    exit 1
  fi
}

function cli::validate_params() {
  if [[ -z "$TARGET_TYPE" ]]; then
    echo "ERROR! $(basename "$0") requires a type as the third argument"
    echo "       The following types are available"
    # shellcheck disable=SC2010
    ls -1 nixos/ | grep -v -E "nixos|root|mixins"
    echo ""
    cli::usage
    exit 1
  fi

  if [[ -z "$TARGET_HOST" ]]; then
    echo "ERROR! $(basename "$0") requires a hostname as the first argument"
    echo "       The following hosts are available"
    # shellcheck disable=SC2012
    ls -1 nixos/*/*/default.nix | cut -d'/' -f2 | grep -v iso
    echo ""
    cli::usage
    exit 1
  fi

  if [[ -z "$TARGET_USER" ]]; then
    echo "ERROR! $(basename "$0") requires a username as the second argument"
    echo "       The following users are available"
    # shellcheck disable=SC2010
    ls -1 nixos/mixins/users/ | grep -v -E "nixos|root"
    echo ""
    cli::usage
    exit 1
  fi
}

function cli::prepare_disk_encryption_key() {
  # Check if the machine we're provisioning expects a keyfile to unlock a disk.
  # If it does, generate a new key, and write to a known location.
  if grep -q "data.keyfile" "$TARGET_HOST_ROOT/disks.nix"; then
    echo -n "$(head -c32 /dev/random | base64)" > /tmp/data.keyfile
  fi
}

function cli::disko_install() {
  # Apply root disks.nix config
  local host_disko_config
  host_disko_config="$TARGET_HOST_ROOT/disks.nix"
  if [ ! -e "$host_disko_config" ]; then
    echo "ERROR! $SCRIPT_NAME could not find the required $host_disko_config"
    exit 1
  fi
  disko::run_with_prompt "$host_disko_config"

  # Apply secondary disks-*.nix configs
  for disko_config in $(find "nixos/$TARGET_HOST_ROOT" -name "disks-*.nix" | sort); do
    disko::run_with_prompt "$disko_config"
  done
}

function cli::nixos_install() {
  sudo nixos-install \
    -j "$MAX_CONCURRENCY" \
    --cores "$MAX_CONCURRENCY" \
    --no-root-password \
    --flake ".#$TARGET_NIXOS_CONFIG_NAME"
}

cli::validate_user
cli::ensure_git_cloned
cli::enter_config_working_dir
cli::validate_params
cli::prepare_disk_encryption_key
cli::disko_install
cli::nixos_install
cli::rsync_data
cli::copy_disk_encryption_key

echo "$SCRIPT_NAME has successfully completed"
