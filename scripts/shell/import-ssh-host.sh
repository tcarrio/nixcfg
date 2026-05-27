#!/usr/bin/env bash
set -euo pipefail

# Script to import an existing host's RSA public key into the Nix configuration
# Usage: ./import-ssh-host.sh <hostname> <target-user@target-host>
#        ./import-ssh-host.sh <hostname> <username>  (if hostname is resolvable)
# Example: ./import-ssh-host.sh existing-server root@192.168.1.100
# Example: ./import-ssh-host.sh existing-server root

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")
SYSTEMS_NIX="$REPO_ROOT/lib/ssh/systems.nix"
SECRETS_DIR="$REPO_ROOT/secrets"
UPDATE_SCRIPT="$SCRIPT_DIR/update-ssh-systems.sh"

# Check if hostname and target are provided
if [ $# -lt 2 ]; then
    echo "Usage: $0 <hostname> <target-user@target-host>" >&2
    echo "       $0 <hostname> <username>" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  $0 existing-server root@192.168.1.100" >&2
    echo "  $0 existing-server root" >&2
    exit 1
fi

HOSTNAME="$1"
TARGET="$2"

# If TARGET doesn't contain @, assume it's just a username and hostname is resolvable
if [[ ! "$TARGET" =~ @ ]]; then
    TARGET="$TARGET@$HOSTNAME"
fi
SSH_DIR="/etc/ssh"

# Possible RSA public key file names
RSA_PUB_KEY_FILES=(
    "$SSH_DIR/ssh_host_rsa_key.pub"
    "$SSH_DIR/ssh_host_ecdsa_key.pub"
    "$SSH_DIR/ssh_host_ed25519_key.pub"
)

echo "Importing SSH public key for host: $HOSTNAME"
echo "Target: $TARGET"
echo ""

# Try to find and read the RSA public key from the target host
PUBLIC_KEY=""
for key_file in "${RSA_PUB_KEY_FILES[@]}"; do
    echo "Checking for $key_file on $TARGET..."
    if ssh "$TARGET" "test -f $key_file" 2>/dev/null; then
        KEY_CONTENT=$(ssh "$TARGET" "cat $key_file" 2>/dev/null | tr -d '\r')
        # Check if it's an RSA key (starts with ssh-rsa)
        if echo "$KEY_CONTENT" | grep -q "^ssh-rsa "; then
            PUBLIC_KEY="$KEY_CONTENT"
            echo "  [OK] Found RSA public key in $key_file"
            break
        else
            KEY_TYPE=$(echo "$KEY_CONTENT" | head -c 10)
            echo "  [SKIP] $key_file exists but is not RSA (type: $KEY_TYPE)"
        fi
    fi
done

if [ -z "$PUBLIC_KEY" ]; then
    echo "  [FAIL] No RSA public key found on $TARGET" >&2
    echo "  Checked files:" >&2
    for key_file in "${RSA_PUB_KEY_FILES[@]}"; do
        echo "    - $key_file" >&2
    done
    exit 1
fi

echo ""
echo "Imported public key:"
echo "$PUBLIC_KEY"
echo ""

# Update lib/ssh/systems.nix using the helper script
echo "Updating $SYSTEMS_NIX..."
if ! "$UPDATE_SCRIPT" "$HOSTNAME" "$PUBLIC_KEY"; then
    echo "  [FAIL] Failed to update $SYSTEMS_NIX" >&2
    exit 1
fi

echo ""

# Rotate secrets with agenix
echo "Rotating secrets with agenix..."
cd "$SECRETS_DIR"

if ! command -v agenix &>/dev/null; then
    echo "  [FAIL] agenix not found in PATH" >&2
    echo "  Please run manually: cd $SECRETS_DIR && agenix -r" >&2
    exit 1
fi

if ! agenix -r; then
    echo "  [FAIL] Failed to rotate secrets with agenix" >&2
    exit 1
fi

echo "  [OK] Secrets rotated"
echo ""

echo "=========================================="
echo "Successfully imported SSH public key for $HOSTNAME"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Commit the changes to $SYSTEMS_NIX"
echo "2. Push the changes to your repository"
echo ""
echo "Note: The backup of the original systems.nix is at $SYSTEMS_NIX.bak"
