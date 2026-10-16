#!/usr/bin/env bash
# Create _memoria.md at the project root from the template.
#
#   bash init.sh [session-id] [project-dir]
#
# Refuses to overwrite an existing file. Adds the file to .git/info/exclude.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$HERE/lib.sh"

session_id="${1:-}"
root="$(project_root "${2:-$PWD}")"
file="$root/$MEMORIA_NAME"

if [ -e "$file" ]; then
  echo "exists $file — not overwriting" >&2
  exit 1
fi

name="$(basename "$root")"
remote="$(git -C "$root" remote get-url origin 2>/dev/null || echo 'none')"
branch="$(git -C "$root" branch --show-current 2>/dev/null || echo '?')"

sed -e "s#{{NAME}}#$name#g" -e "s#{{REMOTE}}#$remote#g" -e "s#{{BRANCH}}#$branch#g" \
    -e "s#{{DATE}}#$(date +%F)#g" "$HERE/../template.md" > "$file"

if [ -n "$session_id" ]; then
  # Fill the managed block the way the SessionStart hook would.
  printf '{"session_id":"%s","source":"startup","cwd":"%s"}' "$session_id" "$root" \
    | bash "$HERE/session_start.sh" >/dev/null
elif git -C "$root" rev-parse --git-dir >/dev/null 2>&1 \
     && ! git -C "$root" check-ignore -q -- "$MEMORIA_NAME"; then
  exclude="$(git -C "$root" rev-parse --git-path info/exclude)"
  case "$exclude" in /*|?:*) ;; *) exclude="$root/$exclude" ;; esac
  mkdir -p "$(dirname "$exclude")"
  printf '/%s\n' "$MEMORIA_NAME" >> "$exclude"
fi

echo "created $file"
