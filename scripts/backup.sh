#!/usr/bin/env bash
set -euo pipefail

# ZiperLab Media Stack — Nightly Backup Script
# Run via cron: 0 3 * * * /path/to/ziperlab-media-stack/scripts/backup.sh
#
# Backs up:
#   - Immich photo library (rsync)
#   - Immich Postgres DB (pg_dump)
#   - Navidrome data + music (rsync)
#
# TODO: Set BACKUP_DEST to an external drive or offsite target
BACKUP_DEST="/mnt/backup/ziperlab"
TIMESTAMP=$(date +%Y-%m-%d_%H-%M)

echo "[$TIMESTAMP] Starting backup to $BACKUP_DEST"

# Immich photo library
echo "[$TIMESTAMP] Syncing Immich library..."
rsync -av --delete /srv/ziperlab/immich/library/ "$BACKUP_DEST/immich/library/"

# Immich Postgres (dump inside the running container)
echo "[$TIMESTAMP] Dumping Immich Postgres..."
docker exec immich-postgres pg_dump -U postgres immich | gzip > "$BACKUP_DEST/immich/db-$TIMESTAMP.sql.gz"

# Navidrome
echo "[$TIMESTAMP] Syncing Navidrome..."
rsync -av --delete /srv/ziperlab/navidrome/ "$BACKUP_DEST/navidrome/"

echo "[$TIMESTAMP] Backup complete."
