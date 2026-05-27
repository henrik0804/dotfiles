#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SECRETS_DIR="$SCRIPT_DIR/secrets"
USE_1PASSWORD_VAULT_PASSWORD="${DOTFILES_USE_1PASSWORD_VAULT_PASSWORD:-0}"
VAULT_1PASSWORD_REF="${DOTFILES_VAULT_1PASSWORD_REF:-op://Private/dotfiles-vault/password}"

usage() {
  cat <<'EOF'
Usage: ./secrets.sh [options]

Options:
  --use-1password-vault-password  Read the Ansible Vault password from 1Password
  --1password-ref REF             1Password item field ref to read when using 1Password
  -h, --help                      Show this help
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --use-1password-vault-password)
      USE_1PASSWORD_VAULT_PASSWORD=1
      ;;
    --1password-ref)
      shift
      if [ "$#" -eq 0 ]; then
        echo "Missing value for --1password-ref" >&2
        exit 1
      fi
      VAULT_1PASSWORD_REF="$1"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

if ! command -v ansible-vault >/dev/null 2>&1; then
  echo "ansible-vault is required for secrets. Install it with: brew install ansible" >&2
  exit 1
fi

if [ ! -d "$SECRETS_DIR" ]; then
  echo "No secrets directory found; skipping."
  exit 0
fi

vault_args=()
tmp_password_file=""
cleanup() {
  if [ -n "$tmp_password_file" ] && [ -f "$tmp_password_file" ]; then
    rm -f "$tmp_password_file"
  fi
}
trap cleanup EXIT

if [ -n "${DOTFILES_VAULT_PASSWORD_FILE:-}" ]; then
  vault_args+=(--vault-password-file "$DOTFILES_VAULT_PASSWORD_FILE")
elif [ -f "$SCRIPT_DIR/.ansible-vault-password" ]; then
  vault_args+=(--vault-password-file "$SCRIPT_DIR/.ansible-vault-password")
elif [ -n "${DOTFILES_VAULT_PASSWORD_COMMAND:-}" ]; then
  tmp_password_file="$(mktemp)"
  chmod 600 "$tmp_password_file"
  eval "$DOTFILES_VAULT_PASSWORD_COMMAND" >"$tmp_password_file"
  vault_args+=(--vault-password-file "$tmp_password_file")
elif [ "$USE_1PASSWORD_VAULT_PASSWORD" = "1" ]; then
  if ! command -v op >/dev/null 2>&1; then
    echo "1Password CLI is required for --use-1password-vault-password" >&2
    exit 1
  fi
  tmp_password_file="$(mktemp)"
  chmod 600 "$tmp_password_file"
  op read "$VAULT_1PASSWORD_REF" >"$tmp_password_file"
  vault_args+=(--vault-password-file "$tmp_password_file")
fi

vault_files=()
while IFS= read -r -d '' source; do
  vault_files+=("$source")
done < <(find "$SECRETS_DIR" -type f -name '*.vault' -print0)

if [ "${#vault_files[@]}" -eq 0 ]; then
  echo "No Ansible Vault secrets found in $SECRETS_DIR."
  echo "Add encrypted files that mirror your home directory, for example:"
  echo "  ansible-vault encrypt --output secrets/.ssh/config.vault ~/.ssh/config"
  exit 0
fi

for source in "${vault_files[@]}"; do
  relative="${source#"$SECRETS_DIR/"}"
  relative="${relative%.vault}"
  destination="$HOME/$relative"

  echo "Decrypting secret: ~/$relative"
  mkdir -p "$(dirname "$destination")"

  # If a secret overlays a stowed file, remove the symlink first so we do not
  # accidentally decrypt secret material into the git worktree.
  if [ -L "$destination" ]; then
    rm "$destination"
  fi

  ansible-vault view "${vault_args[@]}" "$source" >"$destination"

  case "$relative" in
    *.pub)
      chmod 644 "$destination"
      ;;
    .ssh/id_*|.ssh/config)
      chmod 600 "$destination"
      ;;
  esac
done

if [ -f "$HOME/.ssh/id_rsa" ] || [ -f "$HOME/.ssh/id_ed25519" ]; then
  eval "$(ssh-agent -s)" >/dev/null
  for key in "$HOME"/.ssh/id_rsa "$HOME"/.ssh/id_ed25519; do
    [ -f "$key" ] && ssh-add "$key" || true
  done
fi
