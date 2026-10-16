#!/usr/bin/env bash
# Shared helpers for the memoria hooks. Sourced, never run.
#
# No jq: Git Bash on Windows does not ship it, and the hook payload only needs
# three flat string fields.

MEMORIA_NAME="${MEMORIA_FILE:-_memoria.md}"
MEMORIA_STATE_DIR="${MEMORIA_STATE_DIR:-$HOME/.claude/memoria}"
MEMORIA_LOG="$MEMORIA_STATE_DIR/memoria.log"

mkdir -p "$MEMORIA_STATE_DIR" 2>/dev/null

# json_field <json> <key> — first string value for key, unescaped enough for
# ids and Windows paths (\\ → /).
json_field() {
  printf '%s' "$1" | tr -d '\r\n' \
    | sed -n "s/.*\"$2\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" \
    | sed 's#\\\\#/#g'
}

# project_root <cwd> — git toplevel if inside a repo, else the cwd itself.
project_root() {
  local root
  root="$(git -C "$1" rev-parse --show-toplevel 2>/dev/null)" && { printf '%s' "$root"; return; }
  printf '%s' "$1"
}

file_mtime() {
  stat -c %Y "$1" 2>/dev/null || stat -f %m "$1" 2>/dev/null || echo 0
}

status_hash() {
  git -C "$1" status --porcelain 2>/dev/null | cksum | cut -d' ' -f1
}
