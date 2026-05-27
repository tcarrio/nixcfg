#!/usr/bin/env bash
set -euo pipefail

# Script to provision a new host with SSH keys and update the Nix configuration
# Usage: ./provision-ssh-host.sh <hostname> <target-user@target-host>
#        ./provision-ssh-host.sh <hostname> <username>  (if hostname is resolvable)
# Example: ./provision-ssh-host.sh newserver root@192.168.1.100
# Example: ./provision-ssh-host.sh newserver root

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")
SSH_DIR="/etc/ssh"
SYSTEMS_NIX="$REPO_ROOT/lib/ssh/systems.nix"
SECRETS_DIR="$REPO_ROOT/secrets"
UPDATE_SCRIPT="$SCRIPT_DIR/update-ssh-systems.sh"

# Check if hostname and target are provided
if [ $# -lt 2 ]; then
    echo "Usage: $0 <hostname> <target-user@target-host>" >&2
    echo "       $0 <hostname> <username>" >&2
    echo "" >&2
    echo "Examples:" >&2
    echo "  $0 newserver root@192.168.1.100" >&2
    echo "  $0 newserver root" >&2
    exit 1
fi

HOSTNAME="$1"
TARGET="$2"

# If TARGET doesn't contain @, assume it's just a username and hostname is resolvable
if [[ ! "$TARGET" =~ @ ]]; then
    TARGET="$TARGET@$HOSTNAME"
fi
TEMP_DIR=$(mktemp -d)

cleanup() {
    echo "Cleaning up temporary files..."
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

echo "Provisioning SSH keys for host: $HOSTNAME"
echo "Target: $TARGET"
echo ""

# Step 1: Generate RSA 4096 key pair
echo "[1/4] Generating RSA 4096 key pair..."
PRIVATE_KEY="$TEMP_DIR/ssh_host_rsa_key"
PUBLIC_KEY="$TEMP_DIR/ssh_host_rsa_key.pub"

ssh-keygen -t rsa -b 4096 -f "$PRIVATE_KEY" -N "" -C "root@$HOSTNAME" -q
chmod 600 "$PRIVATE_KEY"
echo "  [OK] Key pair generated"
echo ""

# Step 2: Push keys to target host
echo "[2/4] Pushing keys to $TARGET..."

# Push private key
if ! scp "$PRIVATE_KEY" "$TARGET:$SSH_DIR/ssh_host_rsa_key"; then
    echo "  [FAIL] Failed to push private key" >&2
    exit 1
fi

# Push public key
if ! scp "$PUBLIC_KEY" "$TARGET:$SSH_DIR/ssh_host_rsa_key.pub"; then
    echo "  [FAIL] Failed to push public key" >&2
    exit 1
fi

# Set correct permissions on the target
echo "  Setting permissions on target host..."
if ! ssh "$TARGET" "chmod 600 $SSH_DIR/ssh_host_rsa_key && chmod 644 $SSH_DIR/ssh_host_rsa_key.pub && chown root:root $SSH_DIR/ssh_host_rsa_key $SSH_DIR/ssh_host_rsa_key.pub"; then
    echo "  [FAIL] Failed to set permissions" >&2
    exit 1
fi

echo "  [OK] Keys pushed and permissions set"
echo ""

# Step 3: Update lib/ssh/systems.nix using the helper script
echo "[3/4] Updating $SYSTEMS_NIX..."

# Read the public key content
PUB_KEY_CONTENT=$(cat "$PUBLIC_KEY")

# Use the helper script to update systems.nix
if ! "$UPDATE_SCRIPT" "$HOSTNAME" "$PUB_KEY_CONTENT"; then
    echo "  [FAIL] Failed to update $SYSTEMS_NIX" >&2
    exit 1
fi

echo ""

# Step 4: Rotate secrets with agenix
echo "[4/4] Rotating secrets with agenix..."
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
echo "Successfully provisioned SSH keys for $HOSTNAME"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Commit the changes to $SYSTEMS_NIX"
echo "2. Push the changes to your repository"
echo "3. On the target host, you may need to restart sshd:"
echo "   sudo systemctl restart sshd"
echo ""
echo "Note: The backup of the original systems.nix is at $SYSTEMS_NIX.bak"
