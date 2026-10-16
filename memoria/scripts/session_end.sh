#!/usr/bin/env bash
# memoria SessionEnd hook — the safety net.
#
# If a session committed or changed files but nobody updated _memoria.md, append
# a dated stub listing what happened, so the next session can fold it in instead
# of the work going unrecorded. Claude cannot act at SessionEnd; this script can.
#
# Always exits 0.

set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$HERE/lib.sh"
exec 2>>"$MEMORIA_LOG"

payload="$(cat)"
session_id="$(json_field "$payload" session_id)"
reason="$(json_field "$payload" reason)"
state="$MEMORIA_STATE_DIR/$session_id.session"
[ -n "$session_id" ] && [ -f "$state" ] || exit 0

started="$(sed -n 's/^started=//p' "$state")"
root="$(sed -n 's/^root=//p' "$state")"
status_at_start="$(sed -n 's/^status=//p' "$state")"
rm -f "$state"

# Old state files from crashed sessions: drop anything older than a week.
find "$MEMORIA_STATE_DIR" -name '*.session' -mtime +7 -delete 2>/dev/null

file="$root/$MEMORIA_NAME"
[ -f "$file" ] || exit 0

# Updated during the session? Then Claude did its job. The SessionStart hook
# itself touches the file, so allow it a few seconds.
if [ "$(file_mtime "$file")" -gt $(( started + 5 )) ]; then
  exit 0
fi

commits="$(git -C "$root" log --since="@$started" --oneline --no-merges 2>/dev/null | head -n 20)"
dirty_changed=""
[ "$(status_hash "$root")" != "$status_at_start" ] && dirty_changed=1
[ -n "$commits" ] || [ -n "$dirty_changed" ] || exit 0

mins=$(( ($(date +%s) - started) / 60 ))
{
  grep -q '^## Unlogged sessions' "$file" || printf '\n## Unlogged sessions\n\n_Appended by the memoria SessionEnd hook. Fold into Done / Next, then delete this section._\n'
  printf '\n- %s — session `%s` ended (%s, %s min) without updating this file.\n' \
    "$(date '+%F %H:%M')" "$session_id" "${reason:-exit}" "$mins"
  if [ -n "$commits" ]; then
    printf '  Commits:\n'
    printf '%s\n' "$commits" | sed 's/^/  - /'
  fi
  if [ -n "$dirty_changed" ]; then
    printf '  Uncommitted changes now: %s file(s) (`git status` to see).\n' \
      "$(git -C "$root" status --porcelain | wc -l | tr -d ' ')"
  fi
} >> "$file"
exit 0
