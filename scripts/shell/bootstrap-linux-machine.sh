#!/usr/bin/env bash
set -e

NIXCFG_PATH="$HOME/0xc/nixcfg"

# Positional overrides: bootstrap-linux-machine.sh [hostname] [username]
# Falls back to the HOSTNAME/USERNAME env vars, then to the live values.
HOSTNAME="${1:-${HOSTNAME:-$(hostname)}}"
USERNAME="${2:-${USERNAME:-$(whoami)}}"

HM_TARGET="$USERNAME@$HOSTNAME"

DETERMINATE_NIX="${DETERMINATE_NIX:-false}"

function cli::usage() {
  echo """
bootstrap-linux-machine.sh [hostname] [username]

example: bootstrap-linux-machine.sh greybox thomascarrio

Both arguments are optional; hostname and username are inferred from the
current session when omitted.
"""
}

if [ "${1:-}" == "-h" ] || [ "${1:-}" == "--help" ]; then
  cli::usage
  exit 0
fi

echo "Bootstrapping home-manager target: $HM_TARGET"

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
      echo "Installing Determinate Nix (multi-user)..."
      curl -fsSL https://install.determinate.systems/nix | sh -s -- install daemon
    else
      echo "Installing nix (multi-user)..."
      sh <(curl -L https://nixos.org/nix/install) --daemon
    fi
    # The installer updates /etc/profile.d and the systemd nix-daemon, but
    # not this shell — pick up the daemon socket env and profile binaries
    # so the bootstrap can proceed without a re-login
    . /etc/profile.d/nix.sh
    export PATH="/nix/var/nix/profiles/default/bin:$PATH"
    sudo systemctl start nix-daemon 2>/dev/null || true
  else
    . /etc/profile.d/nix.sh 2>/dev/null || true
    export PATH="/nix/var/nix/profiles/default/bin:$PATH"
    if ! which nix >/dev/null; then
      echo "Nix is installed, but still not on your PATH. Add it and re-run."
      exit 1
    fi
  fi
fi

# The flake requires these experimental features in the daemon-side nix.conf
# (home-manager invokes nix without per-command flags). Merge them into
# /etc/nix/nix.conf idempotently and non-destructively: any existing
# experimental-features entry (and every other line) is preserved, with the
# feature set unioned in place.
ensure_nix_experimental_features() {
  local required="nix-command flakes pipe-operators"
  local conf="/etc/nix/nix.conf"
  local use_sudo=1

  # Prefer the daemon-side config; fall back to the user config only when
  # the system path is unwritable even via sudo (or sudo is unavailable).
  if ! sudo mkdir -p /etc/nix 2>/dev/null || ! sudo touch "$conf" 2>/dev/null; then
    conf="$HOME/.config/nix/nix.conf"
    use_sudo=0
    mkdir -p "$(dirname "$conf")"
    touch "$conf"
  fi

  local tmp
  tmp="$(mktemp)"

  # Union of existing features (across any experimental-features lines) and
  # the required set, order-preserving for pre-existing entries.
  local existing
  existing="$(grep -E '^[[:space:]]*experimental-features[[:space:]]*=' "$conf" 2>/dev/null \
    | sed -E 's/^[[:space:]]*experimental-features[[:space:]]*=[[:space:]]*//' | tr ' ,' '\n' \
    | sed '/^[[:space:]]*$/d' | awk '!seen[$0]++' || true)"

  local merged
  merged="$( (
    printf '%s\n' "$existing" | sed '/^[[:space:]]*$/d'
    for f in $required; do
      printf '%s\n' "$existing" | grep -qx "$f" || printf '%s\n' "$f"
    done
  ) | awk '!seen[$0]++' | tr '\n' ' ' | sed 's/ $//')"

  # Rewrite: drop old experimental-features lines, append the merged one.
  # All other configuration is byte-for-byte untouched.
  grep -vE '^[[:space:]]*experimental-features[[:space:]]*=' "$conf" > "$tmp" || true
  printf 'experimental-features = %s\n' "$merged" >> "$tmp"

  if [ "$use_sudo" -eq 1 ]; then
    sudo cp "$tmp" "$conf"
  else
    cp "$tmp" "$conf"
  fi
  rm -f "$tmp"
  echo "nix.conf experimental-features: $(grep 'experimental-features' "$conf")"
}

ensure_nix_experimental_features

if [ ! -d "$NIXCFG_PATH" ]; then
  mkdir -p "$NIXCFG_PATH"
  # https for a brand-new machine with no SSH keys yet; switch the remote
  # to SSH once keys are set up
  git clone https://github.com/tcarrio/nixcfg.git "$NIXCFG_PATH"
fi
pushd "$NIXCFG_PATH"

echo 'Initializing home-manager derivation...'
bootstrapShell home-manager init --flake "$NIXCFG_PATH#$HM_TARGET"
echo 'Setting up home-manager derivation...'
bootstrapShell home-manager switch -b backup --flake "$NIXCFG_PATH#$HM_TARGET"

FISH="$HOME/.nix-profile/bin/fish"
if [ -x "$FISH" ]; then
  echo 'Configuring default shell...'
  # Literal profile path (not the resolved store path) survives version bumps
  grep -qx "$FISH" /etc/shells || echo "$FISH" | sudo tee -a /etc/shells >/dev/null
  sudo chsh -s "$FISH" "$USERNAME"
else
  echo "fish not found at $FISH — skipping shell change (re-run after switching)"
fi

popd
