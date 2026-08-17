# Setup Guide

Full installation walkthrough for the ZiperLab Media Stack.

## Prerequisites

1. SSH access to the Linux server (Ubuntu/Debian), sudo rights
2. Docker + Docker Compose v2 installed (`docker compose version`)
3. `ziperlab.com` on Cloudflare DNS (confirmed)
4. Enough free space — check with `df -h` before proceeding
5. Cloudflare account with access to the `ziperlab.com` zone

## Step 1 — Clone the repo

```bash
cd /opt
git clone <repo-url> ziperlab-media-stack
cd ziperlab-media-stack
```

## Step 2 — Configure environment

```bash
cp .env.example .env
```

Generate a real database password:

```bash
openssl rand -hex 24
```

Paste the output into `.env` as the value for `DB_PASSWORD`. Verify all paths in `.env` match your server layout.

## Step 3 — Create host directories

```bash
chmod +x scripts/init-volumes.sh
./scripts/init-volumes.sh
```

This creates `/srv/ziperlab/immich/library`, `/srv/ziperlab/immich/postgres`, `/srv/ziperlab/navidrome/data`, and `/srv/ziperlab/navidrome/music`.

## Step 4 — Add music files

Drop your music files into `/srv/ziperlab/navidrome/music`. Any folder structure works — Navidrome reads ID3 tags, doesn't need a strict scheme.

## Step 5 — Cloudflare Tunnel

See [CLOUDFLARE.md](CLOUDFLARE.md) for the full tunnel setup. You need this configured before the `cloudflared` container can connect.

## Step 6 — Start the stack

```bash
docker compose up -d
docker compose logs -f immich-server
```

Wait for `Immich Server is listening` in the logs, then `Ctrl+C`.

## Step 7 — First login

- **Photos:** visit `https://cloud.ziperlab.com/photos` — create the first admin account
- **Music:** visit `https://cloud.ziperlab.com/music` — Navidrome auto-creates its first admin on first visit
- **Server dashboard:** visit `https://cloud.ziperlab.com/admin` — Glances shows live CPU, RAM, disk, network, and Docker stats

## Step 8 — Apply HUD theme

In Immich: **Administration > Settings > Custom Styling** — paste the full contents of `themes/immich-hud/custom.css` and save. Applies immediately, no restart needed.

## Verify

- [ ] `docker compose ps` shows all services `Up`/healthy
- [ ] `https://cloud.ziperlab.com/photos` loads Immich login over HTTPS
- [ ] `https://cloud.ziperlab.com/music` loads Navidrome login over HTTPS
- [ ] `https://cloud.ziperlab.com/admin` loads Glances server dashboard
- [ ] HUD theme visibly applied on Immich
- [ ] A second user can be created and tested on Immich

## Troubleshooting

**cloudflared container won't start:**
Check `docker compose logs cloudflared` — usually a bad tunnel token or missing credentials file.

**Immich shows 502:**
Immich server is still starting. Give it 30-60 seconds after first boot, it needs to run ML model downloads.

**Navidrome shows empty:**
Music scan hasn't run yet. The default schedule is `1h`. Force a scan: open Navidrome > Settings > Scan > Force Scan.

**Caddy won't route:**
Verify the Caddyfile is mounted correctly: `docker compose exec caddy cat /etc/caddy/Caddyfile`
