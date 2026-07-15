#!/usr/bin/env bash
# Scrape all raw markdown pages from the neverlose CS:GO GitBook docs.
# Usage: ./scrape.sh <output_dir>
set -euo pipefail

OUT="${1:-raw}"
BASE="https://docs-csgo.neverlose.cc"
mkdir -p "$OUT"

# Full page list from the docs llms.txt index.
PAGES=(
  "readme"
  "useful-information/quick-start"
  "useful-information/common-knowledge"
  "useful-information/script-examples"
  "useful-information/script-examples/materials"
  "useful-information/script-examples/color"
  "useful-information/script-examples/vector"
  "useful-information/script-examples/esp"
  "useful-information/script-examples/convars"
  "useful-information/script-examples/ui"
  "documentation/events"
  "documentation/variables"
  "documentation/variables/_g"
  "documentation/variables/bit"
  "documentation/variables/color"
  "documentation/variables/common"
  "documentation/variables/cvar"
  "documentation/variables/db"
  "documentation/variables/entity"
  "documentation/variables/esp"
  "documentation/variables/events"
  "documentation/variables/files"
  "documentation/variables/globals"
  "documentation/variables/json"
  "documentation/variables/materials"
  "documentation/variables/math"
  "documentation/variables/ui"
  "documentation/variables/network"
  "documentation/variables/panorama"
  "documentation/variables/rage"
  "documentation/variables/render"
  "documentation/variables/utils"
  "documentation/variables/vector"
)

for p in "${PAGES[@]}"; do
  dest="$OUT/$(echo "$p" | tr '/' '__').md"
  echo "GET $BASE/$p.md -> $dest"
  curl -fsSL "$BASE/$p.md" -o "$dest" || echo "  !! failed: $p"
done
echo "Done. $(ls -1 "$OUT" | wc -l) files."
