#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./install.sh [options]

Default install covers the generic machine setup only.

Options:
  --include-sauels       Enable all Sauels-specific setup below
  --with-work-repos      Clone/update work repositories
  --with-sauels-repos    Clone/update Sauels Frische Wurst repositories
  --with-vpn             Install Tunnelblick and the Sauels VPN profile
  --with-legacy-node     Run legacy Node 14 / laravel-echo-server setup
  --vault-password-1p    Read Ansible Vault password from 1Password
  --vault-1p-ref REF     1Password ref for the vault password
                         default: op://Private/dotfiles-vault/password
  -h, --help             Show this help

Environment equivalents:
  DOTFILES_INCLUDE_SAUELS=1
  DOTFILES_WITH_WORK_REPOS=1
  DOTFILES_WITH_SAUELS_REPOS=1
  DOTFILES_WITH_VPN=1
  DOTFILES_WITH_LEGACY_NODE=1
  DOTFILES_USE_1PASSWORD_VAULT_PASSWORD=1
  DOTFILES_VAULT_1PASSWORD_REF=op://Private/dotfiles-vault/password
EOF
}

include_sauels="${DOTFILES_INCLUDE_SAUELS:-0}"
with_sauels_repos="${DOTFILES_WITH_SAUELS_REPOS:-0}"
with_work_repos="${DOTFILES_WITH_WORK_REPOS:-0}"
with_vpn="${DOTFILES_WITH_VPN:-0}"
with_legacy_node="${DOTFILES_WITH_LEGACY_NODE:-0}"
use_1password_vault_password="${DOTFILES_USE_1PASSWORD_VAULT_PASSWORD:-0}"
vault_1password_ref="${DOTFILES_VAULT_1PASSWORD_REF:-op://Private/dotfiles-vault/password}"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --include-sauels)
      include_sauels=1
      ;;
    --with-sauels-repos)
      with_sauels_repos=1
      ;;
    --with-work-repos)
      with_work_repos=1
      ;;
    --with-vpn)
      with_vpn=1
      ;;
    --with-legacy-node)
      with_legacy_node=1
      ;;
    --vault-password-1p)
      use_1password_vault_password=1
      ;;
    --vault-1p-ref)
      shift
      if [ "$#" -eq 0 ]; then
        echo "Missing value for --vault-1p-ref" >&2
        exit 1
      fi
      vault_1password_ref="$1"
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

if [ "$include_sauels" = "1" ]; then
  with_work_repos=1
  with_sauels_repos=1
  with_vpn=1
  with_legacy_node=1
fi

# Set DOTFILES_DIR to the directory containing this script for robustness
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Install Homebrew if missing
if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add Homebrew to PATH for this script session
  if [ -d "/opt/homebrew/bin" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -d "/usr/local/bin" ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

# Ensure brew is in PATH for this session
if ! command -v brew >/dev/null 2>&1; then
  if [ -d "/opt/homebrew/bin" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -d "/usr/local/bin" ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

trust_homebrew_taps() {
  local tap
  local taps=(
    anomalyco/tap
    felixkratz/formulae
    libsql/sqld
    microsoft/git
    microsoft/mssql-release
    modem-dev/tap
    ngrok/ngrok
    nicoverbruggen/cask
    nikitabobko/tap
    shivammathur/extensions
    shivammathur/php
    tursodatabase/tap
  )

  echo "Trusting Homebrew taps used by the Brewfile..."
  for tap in "${taps[@]}"; do
    brew trust --tap "$tap"
  done
}

echo "Installing Homebrew packages..."
export HOMEBREW_ACCEPT_EULA="y"
trust_homebrew_taps
brew bundle --file="$DOTFILES_DIR/Brewfile"

if ! command -v stow >/dev/null 2>&1; then
  echo "Installing GNU Stow..."
  brew install stow
fi

if [ -f "$DOTFILES_DIR/stow.sh" ]; then
  echo "Symlinking dotfiles..."
  bash "$DOTFILES_DIR/stow.sh"
fi

ensure_1password_ready() {
  if [ "$use_1password_vault_password" != "1" ]; then
    return
  fi

  if ! command -v op >/dev/null 2>&1; then
    echo "1Password CLI was not installed by Homebrew; cannot read vault password." >&2
    exit 1
  fi

  if op read "$vault_1password_ref" >/dev/null 2>&1; then
    return
  fi

  echo "1Password is required to decrypt dotfiles secrets."
  echo "Sign in to 1Password and unlock it, then press Enter to continue."
  open -a "1Password" >/dev/null 2>&1 || true
  read -r _

  if ! op read "$vault_1password_ref" >/dev/null; then
    echo "Could not read vault password from 1Password ref: $vault_1password_ref" >&2
    exit 1
  fi
}

if [ -f "$DOTFILES_DIR/secrets.sh" ]; then
  echo "Fetching secrets..."
  ensure_1password_ready
  secrets_args=()
  if [ "$use_1password_vault_password" = "1" ]; then
    secrets_args+=(--use-1password-vault-password --1password-ref "$vault_1password_ref")
  fi
  bash "$DOTFILES_DIR/secrets.sh" "${secrets_args[@]}"
fi

if [ -f "$DOTFILES_DIR/macos.sh" ]; then
  echo "Configuring MacOS..."
  bash "$DOTFILES_DIR/macos.sh"
fi

export NVM_DIR="$HOME/.nvm"

if [ ! -s "$NVM_DIR/nvm.sh" ]; then
  echo "Installing nvm..."
  zsh -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash'
fi

if [ -s "$NVM_DIR/nvm.sh" ]; then
  . "$NVM_DIR/nvm.sh"
fi

if [ -f "$DOTFILES_DIR/npm-global.txt" ]; then
  if ! command -v npm >/dev/null 2>&1 && command -v nvm >/dev/null 2>&1; then
    echo "Installing latest LTS Node for global npm packages..."
    nvm install --lts
  fi

  if command -v npm >/dev/null 2>&1; then
    npm_packages=()
    while IFS= read -r package; do
      package="${package%%#*}"
      package="$(printf '%s' "$package" | xargs)"
      [ -n "$package" ] && npm_packages+=("$package")
    done <"$DOTFILES_DIR/npm-global.txt"

    if [ "${#npm_packages[@]}" -gt 0 ]; then
      echo "Installing global npm packages..."
      npm install -g --ignore-scripts "${npm_packages[@]}"
    fi
  else
    echo "npm not found. Skipping global npm packages." >&2
  fi
fi

if [ -f "$DOTFILES_DIR/skills.sh" ]; then
  echo "Installing agent skills..."
  bash "$DOTFILES_DIR/skills.sh"
fi

if [ -f "$DOTFILES_DIR/repos.sh" ]; then
  echo "Fetching default repos..."
  DOTFILES_WITH_WORK_REPOS="$with_work_repos" \
    DOTFILES_WITH_SAUELS_REPOS="$with_sauels_repos" \
    bash "$DOTFILES_DIR/repos.sh"
fi

cd "$DOTFILES_DIR"
git remote set-url origin git@github.com:henrik0804/dotfiles.git

if [ "$with_legacy_node" = "1" ]; then
  export TMPDIR=${TMPDIR:-/tmp}

  if [ -s "$NVM_DIR/nvm.sh" ]; then
    # Load nvm
    . "$NVM_DIR/nvm.sh"
  else
    echo "NVM not found after install. Skipping legacy Node setup."
  fi

  if command -v nvm >/dev/null 2>&1; then
    # Fix because node 14 needs to be built from source and that supports a
    # maximum of python 3.10. Kept for Sauels-specific legacy projects only.
    export PYTHON="$(command -v python3.9 || true)"

    # Node 14 builds are currently problematic/unavailable, so this remains
    # documented but disabled until needed again.
    # nvm install 14
    # nvm use 14
    # npm install -g npm
    # npm install -g laravel-echo-server

    ln -sfn /opt/homebrew/Cellar/openssl@1.1/1.1.1w /opt/homebrew/opt/openssl || true
  fi
else
  echo "Skipping legacy Node 14 setup. Use --with-legacy-node or --include-sauels to enable."
fi

if [ "$with_vpn" = "1" ] && [ -f "$DOTFILES_DIR/tunnelblick.sh" ]; then
  echo "Installing Tunnelblick and VPN profile..."
  bash "$DOTFILES_DIR/tunnelblick.sh"
else
  echo "Skipping Tunnelblick/VPN setup. Use --with-vpn or --include-sauels to enable."
fi
