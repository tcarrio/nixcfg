#!/usr/bin/env bash
set -euo pipefail

# Script to update lib/ssh/systems.nix using nix-converter
# This properly handles Nix serialization/deserialization
# Usage: ./update-ssh-systems.sh <hostname> <public-key-content>

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")
SYSTEMS_NIX="$REPO_ROOT/lib/ssh/systems.nix"

if [ $# -lt 2 ]; then
    echo "Usage: $0 <hostname> <public-key-content>" >&2
    exit 1
fi

HOSTNAME="$1"
PUBLIC_KEY="$2"
TEMP_DIR=$(mktemp -d)

cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

# Check if nix-converter is available
if ! command -v nix-converter &>/dev/null; then
    echo "Error: nix-converter is not available. Please install it:" >&2
    echo "  nix profile install nixpkgs#nix-converter" >&2
    exit 1
fi

# Read the header comment (everything before the first {)
HEADER=$(awk '/^{/ {exit} {print}' "$SYSTEMS_NIX")

# Extract just the Nix expression (everything from { onwards)
NIX_EXPR=$(awk '/^{/ {found=1} found {print}' "$SYSTEMS_NIX")

# Convert the Nix expression to JSON using nix-converter
JSON_FILE="$TEMP_DIR/systems.json"
if ! echo "$NIX_EXPR" | nix-converter --from nix --to json > "$JSON_FILE" 2>/dev/null; then
    echo "Error: Failed to convert Nix to JSON" >&2
    exit 1
fi

# Check if hostname already exists
if jq -e ".\"$HOSTNAME\"" "$JSON_FILE" >/dev/null 2>&1; then
    echo "Error: Hostname '$HOSTNAME' already exists in $SYSTEMS_NIX" >&2
    exit 1
fi

# Add the new host entry using jq
# We need to add: { hostname: { host: "public-key" } }
NEW_JSON=$(jq --arg host "$HOSTNAME" --arg key "$PUBLIC_KEY" \
    '. + {($host): {"host": $key}}' "$JSON_FILE")

# Convert back to Nix
NEW_NIX=$(echo "$NEW_JSON" | nix-converter --from json --to nix 2>/dev/null)

# Combine header with new Nix expression
echo "$HEADER" > "$TEMP_DIR/systems.nix.new"
echo "$NEW_NIX" >> "$TEMP_DIR/systems.nix.new"

# Verify the new file is valid Nix syntax
if ! nix-instantiate --parse "$TEMP_DIR/systems.nix.new" 2>/dev/null; then
    echo "Error: Generated file has invalid Nix syntax" >&2
    echo "Content preview:" >&2
    head -20 "$TEMP_DIR/systems.nix.new" >&2
    exit 1
fi

# Create backup and move new file into place
cp "$SYSTEMS_NIX" "$SYSTEMS_NIX.bak"
mv "$TEMP_DIR/systems.nix.new" "$SYSTEMS_NIX"

echo "Successfully updated $SYSTEMS_NIX with hostname '$HOSTNAME'"
echo "Backup created at $SYSTEMS_NIX.bak"
