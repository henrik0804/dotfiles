#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PASSWORD_FILE="${DOTFILES_VAULT_PASSWORD_FILE:-$SCRIPT_DIR/.ansible-vault-password}"

if ! command -v ansible-vault >/dev/null 2>&1; then
  echo "ansible-vault is required. Install it with: brew install ansible" >&2
  exit 1
fi

if [ ! -f "$PASSWORD_FILE" ]; then
  umask 077
  openssl rand -base64 32 >"$PASSWORD_FILE"
  chmod 600 "$PASSWORD_FILE"
  echo "Generated vault password file: $PASSWORD_FILE"
  echo "Store this value in 1Password or another password manager before relying on a fresh-machine restore."
fi

encrypt_if_present() {
  local source="$1"
  local destination="$2"

  if [ ! -e "$source" ]; then
    echo "Skipping missing source: $source"
    return 0
  fi

  if [ -e "$destination" ]; then
    echo "Skipping existing vault file: $destination"
    return 0
  fi

  mkdir -p "$(dirname "$destination")"
  ansible-vault encrypt --vault-password-file "$PASSWORD_FILE" --output "$destination" "$source"
  echo "Encrypted $source -> $destination"
}

cd "$SCRIPT_DIR"

encrypt_if_present "$HOME/.ssh/id_rsa" "secrets/.ssh/id_rsa.vault"
encrypt_if_present "$HOME/.ssh/id_rsa.pub" "secrets/.ssh/id_rsa.pub.vault"
encrypt_if_present "$HOME/.ssh/id_ed25519" "secrets/.ssh/id_ed25519.vault"
encrypt_if_present "$HOME/.ssh/id_ed25519.pub" "secrets/.ssh/id_ed25519.pub.vault"
encrypt_if_present "$HOME/.ssh/config" "secrets/.ssh/config.vault"
encrypt_if_present "$HOME/.config/rclone/rclone.conf" "secrets/.config/rclone/rclone.conf.vault"
encrypt_if_present "$HOME/.cloudflared/cert.pem" "secrets/.cloudflared/cert.pem.vault"
encrypt_if_present "$HOME/.pi/agent/auth.json" "secrets/.pi/agent/auth.json.vault"

for credentials in "$HOME"/.cloudflared/*.json; do
  [ -e "$credentials" ] || continue
  encrypt_if_present "$credentials" "secrets/.cloudflared/$(basename "$credentials").vault"
done

vpn_profile=""
for candidate in \
  "$HOME/Library/Application Support/Tunnelblick/Configurations/SauelsVPN.tblk/Contents/Resources/config.ovpn" \
  "$HOME/Library/Application Support/Tunnelblick/Configurations"/*.tblk/Contents/Resources/config.ovpn \
  "$HOME/Downloads"/*.ovpn \
  "$HOME/Downloads"/**/*.ovpn; do
  [ -e "$candidate" ] || continue
  case "$candidate" in
    *Sauels*|*sauels*)
      vpn_profile="$candidate"
      break
      ;;
  esac
done

if [ -n "$vpn_profile" ]; then
  encrypt_if_present \
    "$vpn_profile" \
    "secrets/Library/Application Support/Tunnelblick/Configurations/SauelsVPN.tblk/Contents/Resources/config.ovpn.vault"
else
  echo "Skipping missing Sauels OpenVPN profile"
fi

# Only encrypt GitHub CLI auth state when it actually contains a token.
if [ -f "$HOME/.config/gh/hosts.yml" ] && grep -q "oauth_token" "$HOME/.config/gh/hosts.yml"; then
  encrypt_if_present "$HOME/.config/gh/hosts.yml" "secrets/.config/gh/hosts.yml.vault"
fi

echo ""
echo "Done. Commit only secrets/**/*.vault, never $PASSWORD_FILE."
