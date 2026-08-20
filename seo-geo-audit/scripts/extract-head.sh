#!/usr/bin/env bash
# seo-geo-audit: extract <head>-relevant content from a file
#
# Usage: scripts/extract-head.sh <file>
#
# Works for HTML, JSX, TSX, MDX, Astro, Vue. Output is line-prefixed
# so the consuming skill can cite file:line in findings.

set -uo pipefail

FILE="${1:?usage: extract-head.sh <file>}"
[[ -f "$FILE" ]] || { echo "extract-head: file not found: $FILE" >&2; exit 2; }

MAX_BLOCK_LINES="${MAX_BLOCK_LINES:-80}"

echo "# $FILE"
echo

# 1. Direct <head> tag (HTML, Astro, Vue templates)
echo "## <head> region"
awk '/<head[^>]*>/,/<\/head>/ { print NR": "$0 }' "$FILE" 2>/dev/null
echo

# 2. <title>
echo "## <title>"
grep -nE '<title[^>]*>|<Title[^>]*>' "$FILE" 2>/dev/null
echo

# 3. <meta> tags anywhere (JSX/TSX often put them in components)
echo "## <meta> tags"
grep -nE '<meta[[:space:]]|<Meta[[:space:]]' "$FILE" 2>/dev/null
echo

# 4. <link rel> tags
echo "## <link rel>"
grep -nE '<link[[:space:]][^>]*rel=' "$FILE" 2>/dev/null
echo

# 5. Next.js metadata exports — print the FULL object/function body, not just
#    the declaration line. Brace-depth walk; capped at MAX_BLOCK_LINES so a
#    malformed file cannot dump itself entirely.
echo "## Next.js metadata exports"
awk -v maxlines="$MAX_BLOCK_LINES" '
  !inblk && (/export[[:space:]]+(const|let|var)[[:space:]]+metadata[[:space:]]*[:=]/ ||
             /export[[:space:]]+(async[[:space:]]+)?function[[:space:]]+generateMetadata/) {
    inblk = 1; depth = 0; emitted = 0
  }
  inblk {
    print NR": "$0
    emitted++
    line = $0
    opens  = gsub(/[{[(]/, "", line)
    line2  = $0
    closes = gsub(/[}\])]/, "", line2)
    depth += opens - closes
    if (depth <= 0 || emitted >= maxlines) {
      if (emitted >= maxlines) print "    ... [truncated at "maxlines" lines]"
      inblk = 0
    }
  }
' "$FILE" 2>/dev/null
echo

# 6. Nuxt useHead / useSeoMeta — also print the call body
echo "## Nuxt useHead / useSeoMeta"
awk -v maxlines="$MAX_BLOCK_LINES" '
  !inblk && /useHead\(|useSeoMeta\(|definePageMeta\(/ { inblk = 1; depth = 0; emitted = 0 }
  inblk {
    print NR": "$0
    emitted++
    line = $0;  opens  = gsub(/[{[(]/, "", line)
    line2 = $0; closes = gsub(/[}\])]/, "", line2)
    depth += opens - closes
    if (depth <= 0 || emitted >= maxlines) {
      if (emitted >= maxlines) print "    ... [truncated at "maxlines" lines]"
      inblk = 0
    }
  }
' "$FILE" 2>/dev/null
echo

# 7. react-helmet / next/head — print the JSX block so titles/descriptions land
echo "## react-helmet / next/head"
grep -nE 'from\s+["'\'']next/head|from\s+["'\'']react-helmet' "$FILE" 2>/dev/null
awk -v maxlines="$MAX_BLOCK_LINES" '
  !inblk && /<Helmet[ >]|<Helmet$|<Head>|<Head[ ]/ { inblk = 1; emitted = 0 }
  inblk {
    print NR": "$0
    emitted++
    if ($0 ~ /<\/Helmet>|<\/Head>/ || emitted >= maxlines) {
      if (emitted >= maxlines) print "    ... [truncated at "maxlines" lines]"
      inblk = 0
    }
  }
' "$FILE" 2>/dev/null
echo

# 8. Astro / MDX frontmatter (between --- markers at top)
if head -1 "$FILE" 2>/dev/null | grep -q '^---'; then
  echo "## Frontmatter (Astro / Markdown / MDX)"
  awk '/^---[[:space:]]*$/{c++; next} c==1 {print NR": "$0} c>1{exit}' "$FILE"
  echo
fi

exit 0
