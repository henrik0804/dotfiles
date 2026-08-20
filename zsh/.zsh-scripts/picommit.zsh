# ~/.zsh-scripts/picommit.zsh
# Conventional commits via pi (opencode/gpt-5.6-luna)
# Usage: picommit [extra instruction...]

picommit() {
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    print -u2 "picommit: not a git repository"
    return 1
  fi

  if [[ -z "$(git status --porcelain)" ]]; then
    print "picommit: nothing to commit"
    return 0
  fi

  local skill="${HOME}/.pi/agent/skills/conventional-commits/SKILL.md"
  local extra="${*:-}"
  local outfile errfile pid rc
  local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
  local i=0

  outfile="$(mktemp -t picommit.XXXXXX)"
  errfile="$(mktemp -t picommit.XXXXXX)"

  # Silence [n] pid / done messages from the background job
  setopt local_options no_monitor

  # Stage everything so the agent sees full worktree intent;
  # the skill may still unstage/restage to split atomic commits.
  git add -A

  pi -p --no-session \
    --model 'opencode/gpt-5.6-luna' \
    --skill "$skill" \
    --tools 'bash,read' \
    --exclude-tools 'edit,write' \
    "Create conventional commits for ALL current uncommitted work in this repo.

Rules (follow strictly):
- Never modify file contents. Do not edit, rewrite, format, or fix code.
- Never create or delete files.
- Never run tests, lint, type checks, builds, or validation.
- Only inspect git state, group changes, adjust the index, and commit.
- Prefer multiple small atomic commits over one mixed commit.
- Message format: type(scope): description
- Types: feat|fix|docs|style|refactor|test|chore
- Description: concise, imperative, ideally ≤50 chars.

Workflow:
1. git status --short
2. git diff --cached (and git diff if needed)
3. Split into logical groups via staging only
4. Commit each group
5. End with a short summary of commits created (one line each). Reply with ONLY that summary.

${extra:+User note: ${extra}}" \
    >"$outfile" 2>"$errfile" &
  pid=$!

  trap 'kill '"$pid"' 2>/dev/null; print -n -u2 $'\''\r\e[K\e[?25h'\''; rm -f "'"$outfile"'" "'"$errfile"'"; trap - INT TERM; return 130' INT TERM

  # Spinner on stderr while pi runs
  print -n -u2 $'\e[?25l'
  while kill -0 "$pid" 2>/dev/null; do
    print -n -u2 $'\r'"${frames[i+1]}  Creating conventional commits…"
    i=$(( (i + 1) % ${#frames[@]} ))
    sleep 0.08
  done
  wait "$pid"
  rc=$?

  trap - INT TERM
  print -n -u2 $'\r\e[K\e[?25h'

  if (( rc != 0 )); then
    print -u2 "picommit: pi failed (exit $rc)"
    [[ -s "$errfile" ]] && cat "$errfile" >&2
    [[ -s "$outfile" ]] && cat "$outfile" >&2
    rm -f "$outfile" "$errfile"
    return "$rc"
  fi

  if [[ -s "$outfile" ]]; then
    cat "$outfile"
    print
  else
    print "picommit: done (no text output from pi)"
  fi

  print -u2 "── recent commits ──"
  git --no-pager log -5 --oneline >&2

  rm -f "$outfile" "$errfile"
  return 0
}
