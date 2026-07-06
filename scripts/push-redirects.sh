#!/usr/bin/env bash
# Create redirects listed in wiki-content/redirects.tsv (source<TAB>target).
# Run on the VPS from the repo root: ./scripts/push-redirects.sh
#
# Safety: edit.php silently overwrites existing pages, so every source title
# is checked with getText first — pages that exist with real (non-redirect)
# content are skipped. Re-running is safe; existing redirects are rewritten
# in place (harmless no-op when unchanged).
set -euo pipefail
cd "$(dirname "$0")/.."

SUMMARY="Redirect pass (Phase 3)"
created=0 skipped=0

while IFS=$'\t' read -r src dst _; do
	[[ -z "$src" || "$src" == \#* ]] && continue
	if [[ -z "${dst:-}" ]]; then
		echo "SKIP (malformed line, no tab?): $src" >&2
		skipped=$((skipped + 1))
		continue
	fi
	existing=$(docker compose exec -T mediawiki php maintenance/run.php getText "$src" 2>/dev/null || true)
	if [[ -n "$existing" && ! "$existing" =~ ^#[Rr][Ee][Dd][Ii][Rr][Ee][Cc][Tt] ]]; then
		echo "SKIP (has content): $src"
		skipped=$((skipped + 1))
		continue
	fi
	echo "==> $src -> $dst"
	printf '#REDIRECT [[%s]]\n' "$dst" | docker compose exec -T mediawiki php \
		maintenance/run.php edit --user "Maintenance script" --summary "$SUMMARY" --bot "$src"
	created=$((created + 1))
done < wiki-content/redirects.tsv

echo "Done: $created created/updated, $skipped skipped."
echo "Remember: docker compose restart mediawiki && purgeParserCache are NOT"
echo "needed for new redirects, but run them if this batch replaced any pages."
