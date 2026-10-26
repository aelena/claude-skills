#!/usr/bin/env bash
# poet-commit: best-effort token usage report for the current Claude Code session.
#
# Usage: token_report.sh [session-id]
#
# Strategy:
#   1. With a session id (SKILL.md passes ${CLAUDE_SESSION_ID}), read exactly
#      ~/.claude/projects/*/<session-id>.jsonl. This is the reliable path.
#   2. Without one, slugify $PWD into the format Claude Code uses for
#      ~/.claude/projects/<slug>/ and take the most recently modified .jsonl
#      there, which may belong to another session open in the same directory.
#   3. Extract the last `usage` block and pull token counts out of it.
#
# Degrades gracefully: prints "(token usage unavailable)" on any failure.

set -uo pipefail

fail() {
  echo "(token usage unavailable: ${1:-unknown})"
  exit 0
}

PROJECTS_DIR="${HOME}/.claude/projects"
[[ -d "$PROJECTS_DIR" ]] || fail "no projects dir"

# Slugify $PWD the way Claude Code does: every character that is not a letter
# or digit becomes '-', so the drive colon, separators and spaces all do.
#   C:/Users/anton/OneDrive/My Digital Projects/claude-skills
#     -> C--Users-anton-OneDrive-My-Digital-Projects-claude-skills
# Git Bash reports $PWD as /c/Users/..., so turn that back into C:/Users/... first.
slugify() {
  local p="$1"
  if [[ "$p" =~ ^/([a-zA-Z])/(.*)$ ]]; then
    p="${BASH_REMATCH[1]^^}:/${BASH_REMATCH[2]}"
  fi
  echo "${p//[^a-zA-Z0-9]/-}"
}

JSONL=""
SESSION_ID="${1:-}"
if [[ -n "$SESSION_ID" ]]; then
  JSONL="$(find "$PROJECTS_DIR" -mindepth 2 -maxdepth 2 -name "${SESSION_ID}.jsonl" 2>/dev/null | head -n1)"
fi

if [[ -z "$JSONL" ]]; then
  SESSION_DIR="${PROJECTS_DIR}/$(slugify "$PWD")"
  [[ -d "$SESSION_DIR" ]] || fail "no session dir for $PWD"
  JSONL="$(ls -t "$SESSION_DIR"/*.jsonl 2>/dev/null | head -n1)"
fi
[[ -n "$JSONL" && -f "$JSONL" ]] || fail "no session jsonl"

# Take the last full JSONL line that contains "output_tokens" — that's the
# completed usage record for the most recent assistant turn. Extracting from a
# whole line (rather than a brace-delimited substring) avoids nested-object
# truncation bugs when fields like "cache_creation":{...} appear before output.
USAGE_LINE="$(grep '"output_tokens"' "$JSONL" | tail -n1)"
[[ -n "$USAGE_LINE" ]] || fail "no usage line with output_tokens"

extract() {
  # Take the LAST occurrence on the line (avoids picking up nested counters
  # like ephemeral_5m_input_tokens that share substring with input_tokens).
  echo "$USAGE_LINE" | grep -o "\"$1\":[0-9]*" | tail -n1 | cut -d: -f2
}

IN="$(extract input_tokens)"
OUT="$(extract output_tokens)"
CC="$(extract cache_creation_input_tokens)"
CR="$(extract cache_read_input_tokens)"

IN="${IN:-0}"; OUT="${OUT:-0}"; CC="${CC:-0}"; CR="${CR:-0}"
TOTAL=$((IN + OUT + CC + CR))

printf "tokens: in=%s out=%s cache_create=%s cache_read=%s total=%s\n" \
  "$IN" "$OUT" "$CC" "$CR" "$TOTAL"
