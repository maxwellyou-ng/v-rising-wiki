#!/usr/bin/env bash
# Regenerate the XML sitemap into the public images mount.
# Cron (deploy user), e.g. daily at 4am:
#   0 4 * * * cd /home/deploy/vrising-wiki && ./scripts/generate-sitemap.sh >> /var/log/wiki-sitemap.log 2>&1
set -euo pipefail
cd "$(dirname "$0")/.."

docker compose exec -T mediawiki php maintenance/run.php generateSitemap \
	--fspath /var/www/html/images/sitemap \
	--urlpath /images/sitemap \
	--server https://wiki.v-ris.ing \
	--compress yes

echo "[$(date -Is)] sitemap regenerated"
