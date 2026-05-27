# ~/.zsh/gitprune.zsh
# Clean up stale git branches and reclaim space

gitprune() {
  local before after freed

  before=$(du -sh .git | awk '{print $1}')
  echo "Before cleanup: $before"
  echo

  echo "Checking for stale branches (no commits in last week)..."
  stale_branches=$(git branch --sort=committerdate \
    | grep -v '^\*' \
    | while read branch; do
        if [ -z "$(git log -1 --since='1 week ago' --format=%H "$branch")" ]; then
          echo "$branch"
        fi
      done)

  if [ -n "$stale_branches" ]; then
    echo "$stale_branches" | while read branch; do
      echo "Deleting stale branch: $branch"
      git branch -D "$branch"
    done
  else
    echo "No stale branches found."
  fi

  echo
  echo "Running aggressive garbage collection..."
  git reflog expire --expire=now --all
  git gc --prune=now --aggressive

  echo
  after=$(du -sh .git | awk '{print $1}')
  echo "After cleanup:  $after"

  freed=$(echo "$before $after" | awk '
    function human_to_kb(s) {
      n = s
      sub(/K$/, "", s); sub(/M$/, "", s); sub(/G$/, "", s)
      n = s + 0
      if ($1 ~ /K$/) n *= 1
      else if ($1 ~ /M$/) n *= 1024
      else if ($1 ~ /G$/) n *= 1024*1024
      return n
    }
    {
      before_kb = human_to_kb($1)
      after_kb  = human_to_kb($2)
      diff_kb = before_kb - after_kb
      if (diff_kb <= 0) print "Freed: 0"
      else if (diff_kb < 1024) printf "Freed: %.1fK\n", diff_kb
      else if (diff_kb < 1024*1024) printf "Freed: %.1fM\n", diff_kb/1024
      else printf "Freed: %.1fG\n", diff_kb/1024/1024
    }
  ')
  echo "$freed"
}
