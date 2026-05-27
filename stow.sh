#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${STOW_TARGET:-$HOME}"

# Directories that are not stow packages. Everything else at repository root that
# is a directory can be added as a new dotfile package without editing this file.
EXCLUDED_DIRS=(.git secrets)

is_excluded() {
  local dir="$1"
  for excluded in "${EXCLUDED_DIRS[@]}"; do
    [[ "$dir" == "$excluded" ]] && return 0
  done
  return 1
}

cd "$DOTFILES_DIR"

for path in */; do
  dir="${path%/}"
  is_excluded "$dir" && continue

  # Only stow directories that actually contain files.
  if find "$dir" -type f ! -name '.DS_Store' -print -quit | grep -q .; then
    echo "Stowing $dir"
    stow -R -t "$TARGET_DIR" "$dir"
  fi
done
