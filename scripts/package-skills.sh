#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="$ROOT_DIR/skills"
DIST_DIR="$ROOT_DIR/dist"

rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

if ! command -v zip >/dev/null 2>&1; then
  echo "zip is required to package skills" >&2
  exit 1
fi

for skill_dir in "$SKILLS_DIR"/deepcoin-*; do
  [ -d "$skill_dir" ] || continue
  skill_name="$(basename "$skill_dir")"
  output="$DIST_DIR/$skill_name.zip"

  (
    cd "$skill_dir"
    if [ -d references ]; then
      zip -qr "$output" SKILL.md references
    else
      zip -qr "$output" SKILL.md
    fi
  )

  echo "created dist/$skill_name.zip"
done
