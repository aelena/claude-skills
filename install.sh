#!/usr/bin/env bash
# Symlink every skill in this repo into ~/.claude/skills/.
#
# Symlinks rather than copies so `git pull` updates the installed skills.
# Pass skill names to install a subset:  ./install.sh llms-txt repo-badges
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

# A skill is any directory holding a SKILL.md.
# Deliberately not `find | xargs basename`: that splits on whitespace and
# breaks the moment the checkout lives under a path with a space in it.
all_skills() {
  for dir in "$REPO_DIR"/*/; do
    [ -f "${dir}SKILL.md" ] && basename "$dir"
  done | sort
}

skills=()
if [ "$#" -gt 0 ]; then
  skills=("$@")
else
  # while-read rather than mapfile: macOS still ships bash 3.2.
  while IFS= read -r line; do
    skills+=("$line")
  done < <(all_skills)
fi

if [ "${#skills[@]}" -eq 0 ]; then
  echo "No skills found in $REPO_DIR" >&2
  exit 1
fi

mkdir -p "$TARGET_DIR"

for skill in "${skills[@]}"; do
  src="$REPO_DIR/$skill"
  dest="$TARGET_DIR/$skill"

  if [ ! -f "$src/SKILL.md" ]; then
    echo "skip   $skill (no SKILL.md at $src)" >&2
    continue
  fi

  if [ -L "$dest" ]; then
    rm "$dest"
  elif [ -e "$dest" ]; then
    echo "skip   $skill (a real directory already exists at $dest — remove it first)" >&2
    continue
  fi

  ln -s "$src" "$dest"
  echo "link   $skill"
done

echo
echo "Installed into $TARGET_DIR. Restart Claude Code to pick them up."
