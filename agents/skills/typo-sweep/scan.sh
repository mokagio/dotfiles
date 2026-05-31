#!/usr/bin/env bash

set -euo pipefail

# Scan a directory for typos using the curated `typos.txt` dictionary.
# Usage: scan.sh <directory> [output_file]

DIR="${1:?usage: scan.sh <directory> [output_file]}"
OUT="${2:-/tmp/typo-sweep-findings.txt}"
SKILL_DIR="$(cd "$(dirname "$0")" && pwd)"
TYPOS="${TYPOS_FILE:-$SKILL_DIR/typos.txt}"

# Build alternation pattern, longest-first so leftmost matching picks the longer typo.
PATTERN=$(awk '{print $1}' "$TYPOS" \
  | sort -u \
  | awk '{print length, $0}' \
  | sort -rn \
  | awk '{print $2}' \
  | tr '\n' '|' \
  | sed 's/|$//')
PATTERN="\b(${PATTERN})\b"

rg --no-heading --line-number --column \
  --case-sensitive \
  --glob '*.md' --glob '*.markdown' --glob '*.txt' --glob '*.rst' \
  --glob '*.swift' --glob '*.kt' --glob '*.kts' --glob '*.java' \
  --glob '*.m' --glob '*.mm' --glob '*.h' \
  --glob '*.js' --glob '*.jsx' --glob '*.cjs' --glob '*.mjs' \
  --glob '*.ts' --glob '*.tsx' --glob '*.cts' --glob '*.mts' \
  --glob '*.go' --glob '*.rs' --glob '*.py' --glob '*.rb' \
  --glob '*.sh' --glob '*.bash' \
  --glob '*.yaml' --glob '*.yml' --glob '*.toml' \
  --glob '*.gradle' --glob '*.gradle.kts' \
  --glob '!**/Pods/**' \
  --glob '!**/node_modules/**' \
  --glob '!**/vendor/**' \
  --glob '!**/Carthage/**' \
  --glob '!**/.build/**' \
  --glob '!**/build/**' \
  --glob '!**/DerivedData/**' \
  --glob '!**/third_party/**' \
  --glob '!**/third-party/**' \
  --glob '!**/ThirdParty/**' \
  --glob '!**/Third Party/**' \
  --glob '!**/Third-Party/**' \
  --glob '!**/External/**' \
  --glob '!**/dist/**' \
  --glob '!**/out/**' \
  --glob '!**/bin/**' \
  --glob '!**/obj/**' \
  --glob '!**/.git/**' \
  --glob '!**/.gradle/**' \
  --glob '!**/CHANGELOG*' \
  --glob '!**/*.lock' \
  --glob '!**/Cartfile.resolved' \
  --glob '!**/Podfile.lock' \
  --glob '!**/fastlane/*_metadata/**' \
  --glob '!**/fastlane/metadata/**' \
  --glob '!**/metadata/android/**' \
  --glob '!**/RELEASE-NOTES.txt' \
  --glob '!**/*+Generated.swift' \
  --glob '!**/*Generated.swift' \
  --glob '!**/*.pbxproj' \
  -e "$PATTERN" \
  "$DIR" \
  > "$OUT" || true

echo "Findings written to $OUT"
echo "Total: $(wc -l < "$OUT") matches"
