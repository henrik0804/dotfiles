#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TBLK_PATH="$HOME/Library/Application Support/Tunnelblick/Configurations/SauelsVPN.tblk"
CONFIG_PATH="$TBLK_PATH/Contents/Resources/config.ovpn"
VAULT_PATH="$SCRIPT_DIR/secrets/Library/Application Support/Tunnelblick/Configurations/SauelsVPN.tblk/Contents/Resources/config.ovpn.vault"

if [ -d "/Applications/Tunnelblick.app" ]; then
  echo "Tunnelblick already installed."
else
  echo "Downloading Tunnelblick..."
  URL="https://tunnelblick.net/iprelease/Tunnelblick_8.1beta03_build_6340.dmg"
  TMP_DIR=$(mktemp -d)
  DMG="$TMP_DIR/tunnelblick.dmg"

  cleanup() {
    rm -rf "$TMP_DIR"
  }
  trap cleanup EXIT

  curl -L "$URL" -o "$DMG"

  MOUNT_POINT=$(hdiutil attach "$DMG" -nobrowse | grep "/Volumes/Tunnelblick" | awk '{print $3}')

  echo "Installing Application..."
  cp -R "$MOUNT_POINT/Tunnelblick.app" /Applications/

  hdiutil detach "$MOUNT_POINT"
fi

if [ -f "$CONFIG_PATH" ]; then
  echo "Tunnelblick VPN profile already exists."
elif [ -f "$VAULT_PATH" ]; then
  echo "Installing OpenVPN profile from Ansible Vault secret..."
  bash "$SCRIPT_DIR/secrets.sh"
else
  echo "No Sauels VPN profile found. Expected encrypted profile at:" >&2
  echo "  $VAULT_PATH" >&2
  echo "Create it with:" >&2
  echo "  ansible-vault encrypt --output '$VAULT_PATH' '<path-to-config.ovpn>'" >&2
  exit 1
fi
