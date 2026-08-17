# Backup Strategy

Self-hosting means backup is your job, not a vendor's. This doc covers the backup plan for the ZiperLab Media Stack.

## What to back up

| Data | Location | Method |
|------|----------|--------|
| Immich photos/videos | `/srv/ziperlab/immich/library` | rsync (file copy) |
| Immich Postgres DB | Running in container | `pg_dump` (logical backup) |
| Navidrome data | `/srv/ziperlab/navidrome/data` | rsync |
| Navidrome music | `/srv/ziperlab/navidrome/music` | rsync |
| Stack config | This repo | git |

**Never** just copy the Postgres data directory while the DB is running — use `pg_dump` for a consistent snapshot.

## Nightly backup script

`scripts/backup.sh` handles the automated backup:

```bash
chmod +x scripts/backup.sh
```

### Configuration

Edit the top of `backup.sh`:

```bash
BACKUP_DEST="/mnt/backup/ziperlab"
```

Set this to your external drive mount point or offsite target path.

### Scheduling

Add to crontab:

```bash
crontab -e
```

Add this line (runs nightly at 3 AM):

```
0 3 * * * /opt/ziperlab-media-stack/scripts/backup.sh >> /var/log/ziperlab-backup.log 2>&1
```

### Manual run

```bash
./scripts/backup.sh
```

## Restore

### Immich photos

```bash
rsync -av /mnt/backup/ziperlab/immich/library/ /srv/ziperlab/immich/library/
```

### Immich Postgres

```bash
# Stop Immich first
docker compose stop immich-server

# Restore
gunzip -c /mnt/backup/ziperlab/immich/db-<timestamp>.sql.gz | docker exec -i immich-postgres psql -U postgres immich

# Restart
docker compose start immich-server
```

### Navidrome

```bash
rsync -av /mnt/backup/ziperlab/navidrome/ /srv/ziperlab/navidrome/
```

## What's NOT covered yet

- **No dedicated drive yet** — all data lives on the main disk, which is a single point of failure
- **No offsite backup** — `BACKUP_DEST` should eventually point to a remote target
- **No backup verification** — add a periodic test restore to confirm backups are valid
- **No immich ML model cache backup** — can be regenerated, but adds reprocessing time on restore

## Recommendations

1. Get an external drive and set `BACKUP_DEST` to its mount point
2. For offsite: consider a cheap VPS or cloud storage with rclone
3. Test a full restore at least once — don't wait for a disaster to find out your backup is broken
4. Monitor the cron log to confirm nightly runs are succeeding
