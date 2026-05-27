#!/usr/bin/env bash
set -euo pipefail

# === CONFIG ===

COMPANY_DIR="$HOME/code/web"
PERSONAL_DIR="$HOME/code/personal"
INCLUDE_SAUELS_REPOS="${DOTFILES_WITH_SAUELS_REPOS:-0}"

mkdir -p "$COMPANY_DIR"
mkdir -p "$PERSONAL_DIR"

COMPANY_REPOS=(
  "cre8-it/pss-laravel"
  "cre8-it/mica-cert"
  "cre8-it/yopin"
  "cre8-it/yopin-app"
  "cre8-it/rankauf"
  "cre8-it/ba-office"
  "cre8-it/internal-tools"
  "cre8-it/nhz-server"
  "cre8-it/nhz-client"
)

SAUELS_REPOS=(
  "SauelsFrischeWurst/platform"
  "SauelsFrischeWurst/sas"
  "SauelsFrischeWurst/webshop2020"
  "SauelsFrischeWurst/webshop-api-server"
)

PERSONAL_REPOS=(
  "henrik0804/dotfiles"
  "henrik0804/hooker"
  "henrik0804/requests"
  "henrik0804/portlane"
  "henrik0804/portlane-server"
  "henrik0804/fisch-fit"
  "henrik0804/hoopla"
)

green() { printf "\033[0;32m%s\033[0m\n" "$*"; }
yellow() { printf "\033[0;33m%s\033[0m\n" "$*"; }
blue() { printf "\033[0;34m%s\033[0m\n" "$*"; }

clone_or_update() {
  local repo="$1"
  local base_dir="$2"

  local name
  name=$(basename "$repo")
  local dest="$base_dir/$name"

  echo ""
  blue "Processing $repo"

  mkdir -p "$base_dir"

  if [[ -d "$dest/.git" ]]; then
    yellow "Already exists, pulling"
    git -C "$dest" pull --ff-only || {
      echo "Pull failed for $repo. Probably local changes"
    }
  else
    green "Cloning into $dest"
    git clone "git@github.com:$repo.git" "$dest"
  fi
}

echo "Installing/Updating GitHub repos..."

for repo in "${COMPANY_REPOS[@]}"; do
  clone_or_update "$repo" "$COMPANY_DIR"
done

if [ "$INCLUDE_SAUELS_REPOS" = "1" ]; then
  for repo in "${SAUELS_REPOS[@]}"; do
    clone_or_update "$repo" "$COMPANY_DIR"
  done
else
  yellow "Skipping Sauels Frische Wurst repos. Set DOTFILES_WITH_SAUELS_REPOS=1 or run install.sh --with-sauels-repos to enable."
fi

for repo in "${PERSONAL_REPOS[@]}"; do
  clone_or_update "$repo" "$PERSONAL_DIR"
done

echo ""
green "All selected repositories are installed or updated"
