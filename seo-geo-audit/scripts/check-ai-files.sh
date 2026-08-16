#!/usr/bin/env bash
# seo-geo-audit: probe for AI-discovery files in the repo
#
# Checks for the standardized files that signal AI-readiness to crawlers
# and assistants. Audits source only — does not fetch the live site.
#
# Usage: scripts/check-ai-files.sh [repo-root]
#
# Output: one line per file checked. Exit 0 always — this is a probe, not a gate.

set -uo pipefail

ROOT="${1:-.}"

# (label, severity-if-missing, candidate paths separated by |)
PROBES=(
  "llms.txt|high|llms.txt|public/llms.txt|static/llms.txt|src/static/llms.txt"
  "llms-full.txt|medium|llms-full.txt|public/llms-full.txt|static/llms-full.txt|src/static/llms-full.txt"
  "ai-plugin.json|low|.well-known/ai-plugin.json|public/.well-known/ai-plugin.json|static/.well-known/ai-plugin.json"
  "ai.txt|low|ai.txt|public/ai.txt|static/ai.txt"
  "indexnow-key|low|.well-known/indexnow-key.txt|public/.well-known/indexnow-key.txt|static/.well-known/indexnow-key.txt"
)

# Hint suffixes shown when a file is missing.
declare -A HINTS
HINTS[llms.txt]="recommend running the llms-txt skill"
HINTS[llms-full.txt]="optional full-content variant"
HINTS[ai-plugin.json]="OpenAI plugin manifest; optional unless you ship a plugin"
HINTS[ai.txt]="emerging AI policy file; optional"
HINTS[indexnow-key]="enables near-instant indexing on Bing/Copilot"

for probe in "${PROBES[@]}"; do
  IFS='|' read -ra parts <<<"$probe"
  label="${parts[0]}"
  severity="${parts[1]}"
  found=""
  for ((i=2; i<${#parts[@]}; i++)); do
    candidate="${parts[$i]}"
    if [[ -f "$ROOT/$candidate" ]]; then
      found="$candidate"
      break
    fi
  done

  if [[ -n "$found" ]]; then
    echo "$label: PRESENT at $found"
  else
    hint="${HINTS[$label]:-}"
    if [[ -n "$hint" ]]; then
      echo "$label: MISSING ($severity) — $hint"
    else
      echo "$label: MISSING ($severity)"
    fi
  fi
done
