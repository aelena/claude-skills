#!/usr/bin/env bash
# seo-geo-audit: find structured-data (JSON-LD) blocks
#
# Usage: scripts/find-jsonld.sh <file-or-directory>
#
# Emits three kinds of hit, each prefixed with file:line so the consuming
# skill can cite it:
#
#   ## f:N                            literal JSON-LD, parseable as JSON
#   ## f:N  [JS-EMBEDDED ...]         script tag filled at runtime (React
#                                     dangerouslySetInnerHTML, Astro set:html,
#                                     Vue v-html). Structured data IS present —
#                                     do not report it missing — but its
#                                     validity cannot be checked statically.
#   ## f:N  [SCHEMA OBJECT LITERAL]   an @context object in a JS/TS module,
#                                     with no ld+json tag in the same file.
#
# Distinguishing these matters: treating an injected block as "no JSON-LD"
# produces a false high-severity GEO-005 finding on a correctly built site.

set -uo pipefail

TARGET="${1:?usage: find-jsonld.sh <file-or-directory>}"
[[ -e "$TARGET" ]] || { echo "find-jsonld: not found: $TARGET" >&2; exit 2; }

EXCLUDES=(
  -not -path "*/node_modules/*"
  -not -path "*/.git/*"
  -not -path "*/dist/*"
  -not -path "*/build/*"
  -not -path "*/.next/*"
  -not -path "*/.nuxt/*"
  -not -path "*/out/*"
)

Q="[\"']"
LDJSON_TAG="<script[^>]*type=${Q}application/ld\+json${Q}"
INJECT='dangerouslySetInnerHTML|set:html|v-html|innerHTML|JSON\.stringify|\{\{'
CONTEXT_OBJ="${Q}?@context${Q}?[[:space:]]*:"

scan_file() {
  local f="$1"
  local -a L
  mapfile -t L < "$f" 2>/dev/null || return 0
  local n=${#L[@]} i j
  local saw_tag=0

  for ((i = 0; i < n; i++)); do
    [[ "${L[$i]}" =~ $LDJSON_TAG ]] || continue
    saw_tag=1
    local start=$((i + 1))

    # Look ahead a few lines to classify literal vs runtime-injected.
    local window=""
    for ((j = i; j < n && j < i + 6; j++)); do window+="${L[$j]}"$'\n'; done

    if [[ "$window" =~ $INJECT ]]; then
      echo "## $f:$start  [JS-EMBEDDED — structured data present, injected at runtime; not statically parseable]"
      printf '%s' "$window" | head -6
      echo
      continue
    fi

    # Literal block: accumulate until the closing tag.
    local block="${L[$i]#*>}"
    if [[ "${L[$i]}" == *"</script>"* ]]; then
      block="${block%%</script>*}"
      echo "## $f:$start"; echo "$block"; echo
      continue
    fi
    for ((j = i + 1; j < n; j++)); do
      if [[ "${L[$j]}" == *"</script>"* ]]; then
        block+=$'\n'"${L[$j]%%</script>*}"
        break
      fi
      block+=$'\n'"${L[$j]}"
    done
    echo "## $f:$start"; echo "$block"; echo
    i=$j
  done

  # Schema objects defined in a module with no ld+json tag in the same file —
  # common when the object is built in one file and rendered in another.
  if [[ $saw_tag -eq 0 && "$f" =~ \.(ts|tsx|js|jsx|mjs|cjs|vue|astro|svelte)$ ]]; then
    for ((i = 0; i < n; i++)); do
      if [[ "${L[$i]}" =~ $CONTEXT_OBJ ]]; then
        echo "## $f:$((i + 1))  [SCHEMA OBJECT LITERAL — verify it is rendered into the DOM]"
        echo "${L[$i]}"
        echo
      fi
    done
  fi
}

if [[ -f "$TARGET" ]]; then
  scan_file "$TARGET"
else
  while IFS= read -r f; do
    scan_file "$f"
  done < <(find "$TARGET" -type f \( -name "*.html" -o -name "*.htm" -o -name "*.jsx" \
           -o -name "*.tsx" -o -name "*.js" -o -name "*.ts" -o -name "*.vue" \
           -o -name "*.astro" -o -name "*.svelte" -o -name "*.mdx" \) \
           "${EXCLUDES[@]}" 2>/dev/null)
fi

exit 0
