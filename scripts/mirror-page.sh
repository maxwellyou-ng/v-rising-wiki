#!/usr/bin/env bash
# Mirror a live wiki page's wikitext into wiki-content/pages/.
# Runs locally (read-only against the live wiki). Usage:
#   ./scripts/mirror-page.sh "V Blood Carriers"
# Writes wiki-content/pages/V_Blood_Carriers.wikitext
set -euo pipefail
cd "$(dirname "$0")/.."

[[ $# -eq 1 ]] || { echo "usage: $0 \"Page title\"" >&2; exit 1; }
title="$1"
file="wiki-content/pages/${title// /_}.wikitext"

encoded=$(python3 -c 'import sys,urllib.parse; print(urllib.parse.quote(sys.argv[1]))' "$title")
curl -fsS "https://wiki.v-ris.ing/index.php?title=${encoded}&action=raw" > "$file"
echo "Mirrored '$title' -> $file ($(wc -c < "$file" | tr -d ' ') bytes)"
