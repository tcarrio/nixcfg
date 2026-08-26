#!/usr/bin/env bash
# Rolling update script for the bluebox package.
#
# The download endpoint always serves the latest build, so version and all
# four per-platform hashes must roll over together. This script:
#   1. downloads a reference binary and reads the embedded version
#   2. prefetches each platform combination to obtain its SRI hash
#   3. rewrites default.nix with the new version and hashes
#
# Usage: ./update.sh [path-to-default.nix]  (default: alongside this script)
set -euo pipefail

DEFAULT_NIX="${1:-$(cd "$(dirname "$0")" && pwd)/default.nix}"
BASE_URL="https://app.bluebox.ai/download/bluebox"

# Matches, in order: the version line and the four per-system hash lines.
SYSTEMS=("x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin")

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

# --- 1. Resolve the current version from the darwin-arm64 reference binary ---
ref="$tmpdir/bluebox"
curl -fsSL "$BASE_URL?os=darwin&arch=arm64" -o "$ref"
chmod +x "$ref"
version="$("$ref" version 2>/dev/null | grep -oE '[0-9]+(\.[0-9]+)+' | head -n1)"
if [ -z "$version" ]; then
  echo "error: could not extract version from downloaded binary" >&2
  exit 1
fi
echo "latest version: $version"

# --- 2. Prefetch each platform combination for its SRI hash ---
declare -A hashes
for sys in "${SYSTEMS[@]}"; do
  case "$sys" in
    *-linux)  os_name="linux"  ;;
    *-darwin) os_name="darwin" ;;
    *) echo "error: unknown system $sys" >&2; exit 1 ;;
  esac
  arch="${sys%%-*}"
  case "$arch" in
    x86_64)   arch_name="amd64" ;;
    aarch64)  arch_name="arm64" ;;
    *) echo "error: unknown arch $arch" >&2; exit 1 ;;
  esac

  url="$BASE_URL?os=$os_name&arch=$arch_name"
  hash_line="$(nix store prefetch-file "$url" 2>&1 | grep -oE 'sha256-[A-Za-z0-9+/=]+')"
  if [ -z "$hash_line" ]; then
    echo "error: prefetch failed for $url" >&2
    exit 1
  fi
  hashes[$sys]="$hash_line"
  echo "  $sys -> $hash_line"
done

# --- 3. Rewrite default.nix ---
if ! command -v python3 >/dev/null 2>&1; then
  echo "error: python3 is required to rewrite default.nix" >&2
  exit 1
fi

python3 - "$DEFAULT_NIX" "$version" \
  "x86_64-linux=${hashes[x86_64-linux]}" \
  "aarch64-linux=${hashes[aarch64-linux]}" \
  "x86_64-darwin=${hashes[x86_64-darwin]}" \
  "aarch64-darwin=${hashes[aarch64-darwin]}" <<'PY'
import re, sys

path, version = sys.argv[1], sys.argv[2]
entries = dict(a.split("=", 1) for a in sys.argv[3:])

with open(path) as f:
    content = f.read()

content = re.sub(r'(?m)^(\s*version = ")[^"]+(";)', rf'\g<1>{version}\g<2>', content, count=1)
for sys, h in entries.items():
    pattern = rf'(?m)^(\s*{re.escape(sys)} = ")[^"]+(";)'
    content, n = re.subn(pattern, rf'\g<1>{h}\g<2>', content, count=1)
    if n != 1:
        sys.exit(f"error: hash line for {sys} not found in {path}")

with open(path, "w") as f:
    f.write(content)
PY

echo "updated $DEFAULT_NIX"
