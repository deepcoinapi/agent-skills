#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="$ROOT_DIR/skills"
DIST_DIR="$ROOT_DIR/dist"
CHECK_ONLY=0

if [ "${1:-}" = "--check" ]; then
  CHECK_ONLY=1
fi

TMP_DIST="$(mktemp -d)"
trap 'rm -rf "$TMP_DIST"' EXIT

if [ "$CHECK_ONLY" -eq 0 ]; then
  rm -rf "$DIST_DIR"
  mkdir -p "$DIST_DIR"
fi

if ! command -v zip >/dev/null 2>&1; then
  echo "zip is required to package skills" >&2
  exit 1
fi

if [ "$CHECK_ONLY" -eq 1 ] && ! command -v cmp >/dev/null 2>&1; then
  echo "cmp is required to check packaged skills" >&2
  exit 1
fi

for skill_dir in "$SKILLS_DIR"/deepcoin-*; do
  [ -d "$skill_dir" ] || continue
  skill_name="$(basename "$skill_dir")"
  output="$DIST_DIR/$skill_name.zip"
  tmp_output="$TMP_DIST/$skill_name.zip"

  (
    package_root="$TMP_DIST/$skill_name"
    mkdir -p "$package_root"
    cp "$skill_dir/SKILL.md" "$package_root/SKILL.md"
    if [ -d "$skill_dir/references" ]; then
      cp -R "$skill_dir/references" "$package_root/references"
    fi
    cd "$package_root"
    # Normalize timestamps so committed zip files are reproducible.
    touch -t 202001010000 SKILL.md
    if [ -d references ]; then
      find references -exec touch -t 202001010000 {} +
      zip -X -q -r "$tmp_output" SKILL.md references
    else
      zip -X -q "$tmp_output" SKILL.md
    fi
  )

  if [ "$CHECK_ONLY" -eq 1 ]; then
    if [ ! -f "$output" ]; then
      echo "missing $output" >&2
      exit 1
    fi
    if ! cmp -s "$tmp_output" "$output"; then
      echo "$output is stale; run scripts/package-skills.sh" >&2
      exit 1
    fi
    echo "verified dist/$skill_name.zip"
  else
    cp "$tmp_output" "$output"
    echo "created dist/$skill_name.zip"
  fi
done
