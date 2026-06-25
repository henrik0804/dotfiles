#!/usr/bin/env bash
set -euo pipefail

# Install agent skills for fresh-machine setup.
#
# Public/vendor-maintained skills are installed from their upstream repos. The
# private repo is only used for personal skills that do not have an upstream
# public source.

PRIVATE_SKILLS_PACKAGE="${DOTFILES_AGENT_SKILLS_PACKAGE:-henrik0804/agent-skills}"
PRIVATE_SKILLS_REPO_URL="${DOTFILES_AGENT_SKILLS_REPO_URL:-git@github.com:henrik0804/agent-skills.git}"
PRIVATE_SKILLS_REPO_DIR="${DOTFILES_AGENT_SKILLS_REPO_DIR:-$HOME/code/agent-skills}"
SKILLS_SCOPE_ARGS=()

if [ "${DOTFILES_AGENT_SKILLS_GLOBAL:-1}" = "1" ]; then
  SKILLS_SCOPE_ARGS+=(--global)
fi

# opencode, pi, codex, and other modern harnesses read the canonical skills dir
# directly. Keep the install simple and do not fan out symlinks into every agent-
# specific config directory.
AGENTS="${DOTFILES_AGENT_SKILLS_AGENTS:-}"
PRIVATE_SKILLS="${DOTFILES_AGENT_SKILLS:-*}"

CLOUDFLARE_SKILLS=(
  agents-sdk
  cloudflare
  cloudflare-email-service
  durable-objects
  sandbox-sdk
  web-perf
  workers-best-practices
  wrangler
)

PLANNOTATOR_SKILLS=(
  plannotator-compound
  plannotator-setup-goal
  plannotator-visual-explainer
)

if ! command -v npx >/dev/null 2>&1; then
  echo "npx not found. Skipping agent skills install." >&2
  exit 0
fi

install_plannotator() {
  if ! command -v curl >/dev/null 2>&1; then
    echo "curl not found. Skipping Plannotator CLI install." >&2
  else
    echo "Installing Plannotator CLI..."
    curl -fsSL https://plannotator.ai/install.sh | bash
  fi

  if command -v pi >/dev/null 2>&1; then
    echo "Installing Plannotator Pi extension..."
    pi install npm:@plannotator/pi-extension
  else
    echo "pi not found. Skipping Plannotator Pi extension install." >&2
  fi

  # OpenCode's Plannotator plugin is configured declaratively in
  # opencode/.config/opencode/opencode.json.
}

add_agent_args() {
  if [ -n "$AGENTS" ]; then
    args+=(--agent)
    if [ "$AGENTS" = "*" ]; then
      args+=("*")
    else
      # shellcheck disable=SC2206
      agent_args=($AGENTS)
      args+=("${agent_args[@]}")
    fi
  fi
}

install_skills() {
  local package="$1"
  shift

  args=(skills add "$package" "${SKILLS_SCOPE_ARGS[@]}" --yes)
  add_agent_args

  if [ "$#" -gt 0 ]; then
    args+=(--skill "$@")
  fi

  npx "${args[@]}"
}

ensure_local_repo() {
  if [ -d "$PRIVATE_SKILLS_REPO_DIR/.git" ]; then
    git -C "$PRIVATE_SKILLS_REPO_DIR" pull --ff-only
    return
  fi

  mkdir -p "$(dirname "$PRIVATE_SKILLS_REPO_DIR")"
  git clone "$PRIVATE_SKILLS_REPO_URL" "$PRIVATE_SKILLS_REPO_DIR"
}

install_private_skills() {
  args=(skills add "$PRIVATE_SKILLS_PACKAGE" "${SKILLS_SCOPE_ARGS[@]}" --yes)
  add_agent_args

  if [ -n "$PRIVATE_SKILLS" ]; then
    args+=(--skill)
    if [ "$PRIVATE_SKILLS" = "*" ]; then
      args+=("*")
    else
      # shellcheck disable=SC2206
      skill_args=($PRIVATE_SKILLS)
      args+=("${skill_args[@]}")
    fi
  fi

  npx "${args[@]}"
}

remove_archives() {
  find "$HOME/.agents/skills" -maxdepth 1 -type f -name '*.zip' -delete 2>/dev/null || true
}

install_plannotator

echo "Installing Cloudflare skills from cloudflare/skills..."
install_skills cloudflare/skills "${CLOUDFLARE_SKILLS[@]}"

echo "Installing Plannotator skills from backnotprop/plannotator..."
install_skills backnotprop/plannotator "${PLANNOTATOR_SKILLS[@]}"

echo "Installing personal skills from $PRIVATE_SKILLS_PACKAGE..."
ensure_local_repo
install_private_skills
remove_archives
