#!/usr/bin/env bash
# One-command Fandom content migration: enumerate -> export XML -> fetch images.
# Run from the repo root on any machine with Python 3 and internet access
# (your Mac or the VPS — NOT inside the mediawiki container).
#
#   ./scripts/run-migration.sh
#
# Outputs:
#   pages.txt        — all page titles (NS: main, project, file, template, category, module)
#   exports/         — batched XML dumps with full edit history
#   images-import/   — all image binaries + images-manifest.json
#
# Safe to re-run: export batches and downloaded images are skipped if present.

set -euo pipefail
cd "$(dirname "$0")/.."

echo "==> 1/3 Enumerating pages"
python3 scripts/list-pages.py > pages.txt
echo "    $(wc -l < pages.txt) titles -> pages.txt"

echo "==> 2/3 Exporting XML (full history)"
python3 scripts/export-fandom.py --pages pages.txt --out exports/

echo "==> 3/3 Fetching images (~2,600 files; this is the slow part)"
python3 scripts/fetch-images.py --out images-import/ --manifest images-manifest.json

echo
echo "Done. Next (on the VPS, see GO-LIVE.md):"
echo "  scp/rsync exports/ and images-import/ to the server, then:"
echo "  for f in exports/*.xml; do docker compose exec -T mediawiki php maintenance/run.php importDump --quiet < \"\$f\"; done"
echo "  docker compose exec mediawiki php maintenance/run.php importImages --comment 'Imported from vrising.fandom.com (CC BY-SA)' /import/images-import"
echo "  docker compose exec mediawiki php maintenance/run.php rebuildrecentchanges"
