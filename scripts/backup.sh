#!/usr/bin/env bash
# Nightly backup: DB dump + images/config tarball, then prune local copies.
# Run from the repo root via cron, e.g.:
#   0 3 * * * cd /home/deploy/vrising-wiki && ./scripts/backup.sh >> /var/log/wiki-backup.log 2>&1
# Ship $BACKUP_DIR off the VPS afterwards (restic/rsync to a Hetzner Storage Box).
set -euo pipefail

cd "$(dirname "$0")/.."
source .env

BACKUP_DIR="${BACKUP_DIR:-/backups}"
KEEP_DAYS="${KEEP_DAYS:-14}"
STAMP="$(date +%F)"

mkdir -p "$BACKUP_DIR"

echo "[$(date -Is)] DB dump..."
docker compose exec -T db mariadb-dump -uroot -p"$DB_ROOT_PASSWORD" \
  --single-transaction "${DB_NAME:-vrising_wiki}" | gzip > "$BACKUP_DIR/db-$STAMP.sql.gz"

echo "[$(date -Is)] Files (images + config)..."
tar czf "$BACKUP_DIR/files-$STAMP.tgz" -C "${DATA_ROOT:-./data}" images config

echo "[$(date -Is)] Pruning local backups older than $KEEP_DAYS days..."
find "$BACKUP_DIR" -name 'db-*.sql.gz' -mtime +"$KEEP_DAYS" -delete
find "$BACKUP_DIR" -name 'files-*.tgz' -mtime +"$KEEP_DAYS" -delete

echo "[$(date -Is)] Done: $(ls -lh "$BACKUP_DIR" | tail -n +2 | wc -l) artifacts in $BACKUP_DIR"
