#!/usr/bin/env bash

set -euo pipefail

function deleteDirIfExists() {
  if [ -d "$1" ]; then
    sudo rm -rf "$1"
  else
    echo "Directory $1 not found, skipping deletion"
  fi
}

function deleteFileIfExists() {
  if [ -f "$1" ]; then
    sudo rm -f "$1"
  else
    echo "File $1 not found, skipping deletion"
  fi
}

# Temporary XCode build data
echo "Cleaning up temporary XCode build data..."
deleteDirIfExists "$HOME/Library/Developer/Xcode/DerivedData/"

# XCode caches
echo "Cleaning up XCode cache directories..."
deleteDirIfExists "$HOME/Library/Caches/com.apple.dt.Xcode"
deleteDirIfExists "$HOME/Library/Application Support/Xcode"

# XCode preferences
echo "Cleaning up XCode preferences..."
deleteFileIfExists "$HOME/Library/Preferences/com.apple.dt.Xcode.plist"

# Validate XCode starts successfully
# APP_LOCATION="/Applications/Xcode.app/Contents/MacOS/Xcode"
# if [ -f "$APP_LOCATION" ] && "$APP_LOCATION"; then
#   echo "Started XCode successfully, exiting..."
#   exit 0
# fi

echo "Deleting XCode to reinstall!"

# Delete XCode entirely and reinstall
echo "Deleting XCode app..."
deleteDirIfExists "/Applications/Xcode.app"
echo "Deleting XCode developer library..."
deleteDirIfExists "$HOME/Library/Developer/Xcode"
echo "Deleting XCode app cache..."
deleteDirIfExists "$HOME/Library/Caches/com.apple.dt.Xcode"

# Use `mas` to install XCode if available, or request user to manually install
if which mas >/dev/null; then
    echo "Installing XCode with mas CLI..."
    mas install --force 497799835
else
    echo "You must now reinstall XCode from the App Store."
    read -p "Press Enter to continue..." _input
fi

echo "Configuring XCode..."
xcode-select --install || sudo xcode-select --reset
