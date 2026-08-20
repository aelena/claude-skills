#!/usr/bin/env bash
# seo-geo-audit: discover frontend source files for auditing
#
# Usage: scripts/discover.sh [framework] [repo-root]
#   framework: next | astro | nuxt | sveltekit | remix | gatsby | vite | vue | html | auto
#   repo-root: defaults to current directory
#
# Outputs grouped lists. Skill consumes them and decides what to audit.

set -uo pipefail

FRAMEWORK="${1:-auto}"
ROOT="${2:-.}"
[[ -d "$ROOT" ]] || { echo "discover: not a directory: $ROOT" >&2; exit 2; }

EXCLUDES=(
  -not -path "*/node_modules/*"
  -not -path "*/.git/*"
  -not -path "*/dist/*"
  -not -path "*/build/*"
  -not -path "*/.next/*"
  -not -path "*/.nuxt/*"
  -not -path "*/out/*"
  -not -path "*/.svelte-kit/*"
  -not -path "*/coverage/*"
)

# scan_dirs <name-filter-args...> -- <dir> [<dir>...]
# Searches every candidate dir that exists. Frameworks that support a `src/`
# prefix (Next since v9, Nuxt, Gatsby) must list both spellings.
scan_dirs() {
  local -a filters=() dirs=()
  local seen_sep=0
  for a in "$@"; do
    if [[ "$a" == "--" ]]; then seen_sep=1; continue; fi
    if [[ $seen_sep -eq 0 ]]; then filters+=("$a"); else dirs+=("$a"); fi
  done
  local found=0
  for d in "${dirs[@]}"; do
    [[ -d "$ROOT/$d" ]] || continue
    found=1
    find "$ROOT/$d" -type f \( "${filters[@]}" \) "${EXCLUDES[@]}" 2>/dev/null | sed "s|^$ROOT/||"
  done
  [[ $found -eq 0 ]] && echo "(no route directory found; looked in: ${dirs[*]})"
  return 0
}

# Auto-detect framework if not specified
if [[ "$FRAMEWORK" == "auto" ]]; then
  if [[ -f "$ROOT/package.json" ]]; then
    if grep -q '"next"' "$ROOT/package.json" 2>/dev/null; then
      FRAMEWORK=next
    elif grep -q '"astro"' "$ROOT/package.json" 2>/dev/null; then
      FRAMEWORK=astro
    elif grep -q '"nuxt"' "$ROOT/package.json" 2>/dev/null; then
      FRAMEWORK=nuxt
    elif grep -q '"@sveltejs/kit"' "$ROOT/package.json" 2>/dev/null; then
      FRAMEWORK=sveltekit
    elif grep -q '"@remix-run' "$ROOT/package.json" 2>/dev/null; then
      FRAMEWORK=remix
    elif grep -q '"gatsby"' "$ROOT/package.json" 2>/dev/null; then
      FRAMEWORK=gatsby
    elif grep -q '"vue"' "$ROOT/package.json" 2>/dev/null; then
      FRAMEWORK=vue
    else
      FRAMEWORK=vite
    fi
  else
    FRAMEWORK=html
  fi
fi
echo "## Framework: $FRAMEWORK"
echo

echo "## package.json / config"
for f in package.json next.config.js next.config.mjs next.config.ts \
         astro.config.mjs astro.config.ts nuxt.config.ts nuxt.config.js \
         svelte.config.js vite.config.ts vite.config.js \
         gatsby-config.js gatsby-config.ts remix.config.js vercel.json netlify.toml; do
  [[ -f "$ROOT/$f" ]] && echo "$f"
done
echo

echo "## Pages / routes"
case "$FRAMEWORK" in
  next)
    # App Router and Pages Router, each with and without the src/ prefix.
    scan_dirs -name "page.*" -o -name "layout.*" -o -name "head.*" -o -name "route.*" \
              -- app src/app
    scan_dirs -name "*.tsx" -o -name "*.jsx" -o -name "*.ts" -o -name "*.js" -o -name "*.mdx" \
              -- pages src/pages
    ;;
  astro)
    scan_dirs -name "*.astro" -o -name "*.md" -o -name "*.mdx" -- src/pages pages
    ;;
  nuxt)
    scan_dirs -name "*.vue" -o -name "*.md" -- pages src/pages app/pages
    ;;
  sveltekit)
    scan_dirs -name "+page.*" -o -name "+layout.*" -o -name "+server.*" -- src/routes routes
    ;;
  remix)
    scan_dirs -name "*.tsx" -o -name "*.jsx" -o -name "*.mdx" -- app/routes src/app/routes
    ;;
  gatsby)
    scan_dirs -name "*.tsx" -o -name "*.jsx" -o -name "*.md" -o -name "*.mdx" -- src/pages pages
    ;;
  vue)
    scan_dirs -name "*.vue" -- src app
    ;;
  html)
    find "$ROOT" -type f -name "*.html" "${EXCLUDES[@]}" 2>/dev/null | sed "s|^$ROOT/||"
    ;;
  *)
    scan_dirs -name "*.tsx" -o -name "*.jsx" -o -name "*.vue" -o -name "*.html" -- src app .
    ;;
esac
echo

echo "## Layouts / shells (head injection happens here)"
find "$ROOT" -type f \( -name "_app.*" -o -name "_document.*" -o -name "layout.*" \
     -o -name "Layout.*" -o -name "+layout.*" -o -name "RootLayout.*" \
     -o -name "index.html" \) "${EXCLUDES[@]}" 2>/dev/null | sed "s|^$ROOT/||"
echo

echo "## Content (markdown / mdx)"
for d in content src/content posts src/posts blog; do
  [[ -d "$ROOT/$d" ]] && find "$ROOT/$d" -type f \( -name "*.md" -o -name "*.mdx" \) \
    "${EXCLUDES[@]}" 2>/dev/null | sed "s|^$ROOT/||"
done
echo

echo "## Public assets"
for f in public/robots.txt public/sitemap.xml public/sitemap-index.xml public/llms.txt public/llms-full.txt \
         static/robots.txt static/sitemap.xml static/llms.txt \
         robots.txt sitemap.xml llms.txt llms-full.txt \
         app/robots.ts app/sitemap.ts src/app/robots.ts src/app/sitemap.ts; do
  [[ -f "$ROOT/$f" ]] && echo "$f"
done

exit 0
