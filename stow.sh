#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${STOW_TARGET:-$HOME}"
BACKUP_CONFLICTS=0
BACKUP_DIR=""

PACKAGES=(
  atuin
  cloudflared
  fastfetch
  gh
  ghostty
  git
  hammerspoon
  jetbrains
  linearmouse
  nvim
  opencode
  pi
  tmux
  twm
  zsh
)

usage() {
  cat <<'EOF'
Usage: ./stow.sh [--backup-conflicts]

Options:
  --backup-conflicts  Move divergent target files to a timestamped backup
                      under ~/.dotfiles-backups before stowing
  -h, --help          Show this help
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --backup-conflicts)
      BACKUP_CONFLICTS=1
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

prepare_package() {
  local package="$1"
  local source relative destination backup_destination

  while IFS= read -r -d '' source; do
    relative="${source#"$package/"}"
    destination="$TARGET_DIR/$relative"

    [ -e "$destination" ] || continue
    [ -L "$destination" ] && continue

    # A parent directory may already be a Stow symlink, in which case source
    # and destination are the same file and must not be removed.
    [ "$source" -ef "$destination" ] && continue

    if cmp -s "$source" "$destination"; then
      echo "Replacing identical target with Stow link: $destination"
      rm "$destination"
      continue
    fi

    if [ "$BACKUP_CONFLICTS" != "1" ]; then
      echo "Refusing to overwrite divergent target: $destination" >&2
      echo "Re-run with --backup-conflicts to preserve it in ~/.dotfiles-backups." >&2
      return 1
    fi

    if [ -z "$BACKUP_DIR" ]; then
      BACKUP_DIR="$HOME/.dotfiles-backups/$(date +%Y%m%d-%H%M%S)"
    fi
    backup_destination="$BACKUP_DIR/$relative"
    mkdir -p "$(dirname "$backup_destination")"
    mv "$destination" "$backup_destination"
    echo "Backed up divergent target: $destination -> $backup_destination"
  done < <(find "$package" -type f ! -name '.DS_Store' -print0)
}

cd "$DOTFILES_DIR"

for package in "${PACKAGES[@]}"; do
  if [ ! -d "$package" ]; then
    echo "Skipping missing package: $package" >&2
    continue
  fi

  if find "$package" -type f ! -name '.DS_Store' -print -quit | grep -q .; then
    prepare_package "$package"
    echo "Stowing $package"
    stow -R --ignore='(^|/)\.DS_Store$' -t "$TARGET_DIR" "$package"
  fi
done

if [ -n "$BACKUP_DIR" ]; then
  echo "Divergent targets were preserved in: $BACKUP_DIR"
fi
