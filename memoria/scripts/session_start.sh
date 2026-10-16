#!/usr/bin/env bash
# memoria SessionStart hook.
#
# 1. Finds _memoria.md at the project root (git toplevel, else cwd).
# 2. Keeps it out of git via .git/info/exclude — local, never committed.
# 3. Rewrites the managed Resume block with this session's id, so the resume
#    command is always the right one without anyone copying it by hand.
# 4. Prints the file to stdout; the harness adds it to Claude's context.
#
# Runs on startup, resume, /clear and after compaction. Always exits 0.

set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$HERE/lib.sh"
exec 2>>"$MEMORIA_LOG"

MAX_LINES="${MEMORIA_MAX_LINES:-400}"
HISTORY="${MEMORIA_HISTORY:-5}"

payload="$(cat)"
session_id="$(json_field "$payload" session_id)"
source_kind="$(json_field "$payload" source)"
cwd="$(json_field "$payload" cwd)"
[ -n "$cwd" ] || cwd="$PWD"

root="$(project_root "$cwd")"
file="$root/$MEMORIA_NAME"
now="$(date +%s)"
today="$(date +%F)"

# Remember when this session started, for the SessionEnd safety net. Compaction
# keeps the session, so it keeps the original start.
if [ -n "$session_id" ] && [ "$source_kind" != "compact" ]; then
  printf 'started=%s\nroot=%s\nstatus=%s\n' "$now" "$root" "$(status_hash "$root")" \
    > "$MEMORIA_STATE_DIR/$session_id.session"
fi

if [ ! -f "$file" ]; then
  # Only worth a line inside a repo; a random folder is not a project.
  if git -C "$root" rev-parse --git-dir >/dev/null 2>&1; then
    echo "[memoria] No $MEMORIA_NAME in this repo. Session id: $session_id. If this session does substantive work, offer once (not every turn) to start one with the memoria skill."
  fi
  exit 0
fi

# --- keep it untracked -------------------------------------------------------
git_note=""
if git -C "$root" rev-parse --git-dir >/dev/null 2>&1; then
  if git -C "$root" ls-files --error-unmatch -- "$MEMORIA_NAME" >/dev/null 2>&1; then
    git_note="WARNING: $MEMORIA_NAME is tracked by git. Tell the user; it is meant to stay local (git rm --cached $MEMORIA_NAME)."
  elif ! git -C "$root" check-ignore -q -- "$MEMORIA_NAME"; then
    exclude="$(git -C "$root" rev-parse --git-path info/exclude)"
    case "$exclude" in /*|?:*) ;; *) exclude="$root/$exclude" ;; esac
    mkdir -p "$(dirname "$exclude")"
    # Anchored, so a same-named file deeper in the tree stays visible to git.
    printf '/%s\n' "$MEMORIA_NAME" >> "$exclude"
    git_note="Added $MEMORIA_NAME to .git/info/exclude."
  fi
fi

# --- managed Resume block ----------------------------------------------------
START='<!-- memoria:resume:start'
END='<!-- memoria:resume:end -->'
block_note=""
if grep -q "$START" "$file"; then
  if [ -n "$session_id" ] && [ "$source_kind" != "compact" ]; then
    # Earlier ids from the existing block, minus the current one, newest first.
    earlier="$(sed -n "/$START/,/memoria:resume:end/p" "$file" \
      | grep -oE '`[0-9a-f]{8}-[0-9a-f-]{27}` \([0-9-]+\)' \
      | grep -v "$session_id" | head -n "$HISTORY" | paste -sd',' - | sed 's/,/, /g')"
    # The previous "last session" moves into the history.
    prev="$(sed -n "/$START/,/memoria:resume:end/p" "$file" \
      | sed -n 's/.*\*\*Last session:\*\* `\([^`]*\)` (\([0-9-]*\).*/`\1` (\2)/p' | head -1)"
    if [ -n "$prev" ] && ! printf '%s' "$prev" | grep -q "$session_id"; then
      earlier="$(printf '%s%s' "$prev" "${earlier:+, $earlier}" | tr ',' '\n' | sed 's/^ *//' \
        | awk '!seen[$0]++' | head -n "$HISTORY" | paste -sd',' - | sed 's/,/, /g')"
    fi

    tmp="$file.memoria.tmp"
    awk -v start="$START" -v end="$END" -v id="$session_id" -v day="$today" \
        -v kind="${source_kind:-startup}" -v earlier="$earlier" '
      index($0, start) == 1 {
        print
        print "## Resume"
        print ""
        print "- **Last session:** `" id "` (" day ", " kind ")"
        print "- Resume with: `claude --resume " id "` (run from this folder)"
        if (earlier != "") print "- Earlier sessions: " earlier
        skip = 1; next
      }
      index($0, end) == 1 { skip = 0 }
      !skip { print }
    ' "$file" > "$tmp" && mv "$tmp" "$file"
  fi
else
  block_note="This file has no managed Resume block. Migrate it now: replace any hand-written Resume section with the two marker lines from the memoria template (see the memoria skill); the hook fills them next session."
fi

# --- inject ------------------------------------------------------------------
lines="$(wc -l < "$file" | tr -d ' ')"
echo "[memoria] Project memory from $file (session $session_id, source ${source_kind:-startup})."
echo "Read it before answering. In your first reply give the user a one-line 'where we left off' (last Done item, top Next item, any open question). If an 'Unlogged sessions' section exists, fold it into Done and delete it. Keep this file current per the memoria skill; never write secret values into it."
[ -n "$git_note" ] && echo "$git_note"
[ -n "$block_note" ] && echo "$block_note"
echo "----- $MEMORIA_NAME -----"
head -n "$MAX_LINES" "$file"
if [ "$lines" -gt "$MAX_LINES" ]; then
  echo "----- truncated at $MAX_LINES of $lines lines; Read the file for the rest, and prune it (memoria skill, 'Keep it lean') -----"
else
  echo "----- end $MEMORIA_NAME -----"
fi
exit 0
