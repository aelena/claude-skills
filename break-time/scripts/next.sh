#!/usr/bin/env bash
# break-time: print the next scheduled nudge.
# Used by /break-next (or "show next break-time") to answer just the
# "when's my next break?" question without dumping full state.

set -uo pipefail

STATE="${BREAK_TIME_STATE:-$HOME/.claude/break-time.state}"
CONF="${BREAK_TIME_CONF:-$HOME/.claude/break-time.conf}"

THRESHOLDS="45 90 120"
[[ -f "$CONF" ]] && source "$CONF"

if [[ ! -f "$STATE" ]]; then
  # No state yet — the first nudge fires at the lowest threshold from a fresh session.
  first="${THRESHOLDS%% *}"
  echo "break-time: no active session yet — next nudge would fire at ${first} min once you start."
  exit 0
fi

# shellcheck disable=SC1090
source "$STATE"
NOW=$(date +%s)

session_start="${session_start:-$NOW}"
fired="${fired:-}"
snooze_until="${snooze_until:-0}"
active_minutes=$(( (NOW - session_start) / 60 ))

# Find the next threshold that hasn't fired and is still ahead.
next=""
for t in $THRESHOLDS; do
  if (( active_minutes < t )) && [[ ",$fired," != *",$t,"* ]]; then
    next="$t"
    break
  fi
done

if [[ -z "$next" ]]; then
  echo "break-time: no further nudges scheduled this session (active: ${active_minutes} min)."
  exit 0
fi

remaining=$(( next - active_minutes ))
eta=$(( NOW + remaining * 60 ))

# Human-readable ETA (GNU date vs BSD date)
if date -d "@$eta" '+%H:%M' >/dev/null 2>&1; then
  HUMAN="$(date -d "@$eta" '+%H:%M')"
else
  HUMAN="$(date -r "$eta" '+%H:%M' 2>/dev/null || echo "+${remaining}m")"
fi

if (( snooze_until > NOW )); then
  snooze_remaining=$(( (snooze_until - NOW) / 60 ))
  echo "break-time: next nudge at ${next} min (in ${remaining} min, around ${HUMAN}) — but snoozed for ${snooze_remaining} more min, so it will be skipped if it fires during snooze."
else
  echo "break-time: next nudge at ${next} min (in ${remaining} min, around ${HUMAN})."
fi
