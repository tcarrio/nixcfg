#!/usr/bin/env bash

# Early check for Determinate Nix install or its uninstaller, and invoke 
if which nix >/dev/null && [[ "$(nix --version)" =~ Determinate\ Nix ]] || test -f /nix/nix-installer; then
  if sudo /nix/nix-installer uninstall; then
    echo "Successfully uninstalled Determinate Nix"
    exit 0
  else
    echo "Failed to uninstall Determinate Nix"
    exit 1
  fi
fi

# See: https://nix.dev/manual/nix/2.18/installation/uninstall

# Return all original shell configs
sudo mv /etc/zshrc.backup-before-nix /etc/zshrc
sudo mv /etc/bashrc.backup-before-nix /etc/bashrc
sudo mv /etc/bash.bashrc.backup-before-nix /etc/bash.bashrc

# Unload services
sudo launchctl unload /Library/LaunchDaemons/org.nixos.nix-daemon.plist
sudo rm /Library/LaunchDaemons/org.nixos.nix-daemon.plist
sudo launchctl unload /Library/LaunchDaemons/org.nixos.darwin-store.plist
sudo rm /Library/LaunchDaemons/org.nixos.darwin-store.plist

# Remove nix machine users
sudo dscl . -delete /Groups/nixbld
for u in $(sudo dscl . -list /Users | grep _nixbld); do sudo dscl . -delete /Users/$u; done

# Remove nix generated files
sudo rm -rf /etc/nix /var/root/.nix-profile /var/root/.nix-defexpr /var/root/.nix-channels ~/.nix-profile ~/.nix-defexpr ~/.nix-channels

# Remove /nix mount configuration
sudo sed -i '/ \/nix apfs /d' /etc/fstab

# Remove /nix volume
sudo diskutil apfs deleteVolume /nix

# Detect /nix volume under APFS container
matching_line="$(diskutil list | grep /nix)"
if [ -n "$matching_line" ]; then
  re="(disk[0-9]+s[0-9]+)"
  disk_id=""
  if [[ $matching_line =~ $re ]]; then
    disk_id="${BASH_REMATCH[1]}"
  fi

  if [ -n "$disk_id" ]; then
    echo "Found $disk_id"
  else
    echo "Failed to detect disk id for /nix volume"
  fi
else
  echo "No more Nix Store volumes found"
fi
