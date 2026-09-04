# CHECKPOINT — ZiperLab Media Stack

Last updated: 2026-09-04

## What this repo is

Self-hosted media stack: Immich (photos), Navidrome (music), Glances (server dashboard), all behind Caddy reverse proxy + Cloudflare Tunnel. Each service gets its own subdomain in production. Everything runs in Docker on a home Ubuntu/Debian server.

**Important:** Immich does NOT support sub-path routing. Each service must be served at the root of its own domain/port.

## What's built (local, not deployed)

All files are scaffolded locally at `C:\Users\mario\projects\ziperlab\`:

```
├── .env.example              # all env vars, needs real .env on server
├── .gitignore                # secrets + editor junk excluded
├── docker-compose.yml        # 8 services: Immich (4), Navidrome, Glances, Caddy, cloudflared
├── caddy/Caddyfile           # subdomain routing: photos/music/admin → each service
├── cloudflared/config.yml.example  # tunnel ingress template (subdomains)
├── scripts/
│   ├── init-volumes.sh       # creates /srv/ziperlab/* host dirs
│   └── backup.sh             # nightly cron: rsync + pg_dump
├── themes/immich-hud/
│   ├── custom.css            # retro-sci-fi HUD theme (paste into Immich admin)
│   └── README.md             # design tokens + application steps
├── docs/
│   ├── SETUP.md              # full install walkthrough
│   ├── CLOUDFLARE.md         # tunnel setup
│   ├── USERS_AND_SHARING.md  # multi-user + sharing
│   ├── MOBILE_APPS.md        # phone apps
│   └── BACKUP.md             # backup strategy
└── README.md                 # friendly overview + architecture diagram
```

## Services (what runs)

| Service | Local URL | Production URL | Port (host) | What it does |
|---------|-----------|----------------|-------------|-------------|
| Immich Server | localhost:2283 | photos.ziperlab.com | 2283 | Photo/video library, face recognition, search |
| Immich ML | — | — | internal | Machine learning worker (face detect, etc.) |
| Immich Redis | — | — | internal | Cache layer |
| Immich Postgres | — | — | internal | Database (VectorChord for vector search) |
| Navidrome | localhost:4533 | music.ziperlab.com | 4533 | Music streaming, Subsonic API |
| Glances | localhost:61208 | admin.ziperlab.com | 61208 | Server monitoring dashboard |
| Caddy | — | — | 8080 (internal) | Reverse proxy, subdomain routing (production) |
| cloudflared | — | — | none | Tunnel to Cloudflare (production) |

## Bugs fixed during local testing

1. **Missing DB/Redis env vars** — immich-server had no DB_HOSTNAME/REDIS_HOSTNAME, defaulted to nonexistent `database` host.
2. **Incompatible postgres image** — `pgvecto-rs:pg14-v0.2.0` doesn't work with Immich v3.1.0. Swapped to `ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0`.
3. **Immich sub-path routing** — Immich does NOT support being served on a sub-path (e.g. `/photos`). Switched to port-based routing for local dev, subdomain-based for production.

## What needs to happen next (deployment)

This is the order of operations when you sit down to deploy:

### 1. Commit the code
Configure git identity, commit everything.

### 2. Push to GitHub
Create the repo on GitHub, push. You'll need this to clone on the server.

### 3. Server prep
SSH into the server and:
- Verify Docker is installed: `docker compose version` (install from Docker's official apt repo if not)
- Verify disk space: `df -h` — report back if low, this determines if a dedicated drive is needed
- Clone the repo: `cd /opt && git clone <repo-url> ziperlab-media-stack`

### 4. Configure .env
```bash
cd /opt/ziperlab-media-stack
cp .env.example .env
openssl rand -hex 24   # paste output as DB_PASSWORD
```
Review all paths in `.env` — they default to `/srv/ziperlab/*` on the main disk.

### 5. Create host directories
```bash
chmod +x scripts/init-volumes.sh
./scripts/init-volumes.sh
```

### 6. Add music
Drop music files into `/srv/ziperlab/navidrome/music`. Any folder structure works.

### 7. Cloudflare Tunnel
Full steps in `docs/CLOUDFLARE.md`. Summary:
1. Zero Trust dashboard → Networks → Tunnels → Create tunnel (name: `ziperlab-media`)
2. Copy generated token
3. Add public hostnames (each service gets its own subdomain):
   - `photos.ziperlab.com` → `http://caddy:8080`
   - `music.ziperlab.com` → `http://caddy:8080`
   - `admin.ziperlab.com` → `http://caddy:8080`
4. Download credentials JSON, place at `cloudflared/<TUNNEL_ID>.json`
5. Fill in `cloudflared/config.yml` with tunnel ID and credentials path

### 8. Start everything
```bash
docker compose --profile tunnel up -d
docker compose logs -f immich-server
```

### 9. First login + theme
- `https://photos.ziperlab.com` — create Immich admin
- `https://music.ziperlab.com` — Navidrome auto-creates admin
- `https://admin.ziperlab.com` — Glances dashboard (no login by default)
- Immich admin → Settings → Custom Styling → paste `themes/immich-hud/custom.css`

### 10. Pin image tags
Once confirmed working, pin exact image tags in docker-compose.yml (not `latest`) so future `docker compose pull` doesn't silently break things. Check each project's GitHub releases for current stable tags.

## Known issues / decisions

- **Navidrome sharing:** all users see the same music library. No per-user private music. This is a Navidrome architectural limitation, not something we can configure around.
- **Navidrome theming:** deferred. Real theming means forking the source and building a custom Docker image. Not worth doing until the core stack is stable.
- **Glances has no auth by default.** It's behind the Cloudflare tunnel, so only people with the URL can access it, but consider adding basic auth if you want an extra layer.
- **No dedicated drive yet.** All data lives on the main disk. Single point of failure until a second drive or offsite backup exists.
- **backup.sh is a placeholder.** Needs `BACKUP_DEST` configured and a cron job set up after deployment.

## Verification checklist (post-deploy)

- [ ] `docker compose ps` — all services `Up`
- [ ] `https://photos.ziperlab.com` — Immich login loads over HTTPS
- [ ] `https://music.ziperlab.com` — Navidrome login loads over HTTPS
- [ ] `https://admin.ziperlab.com` — Glances dashboard loads
- [ ] HUD theme applied on Immich
- [ ] Second Immich user created, album sharing tested
- [ ] Mobile app tested on phone (Immich official + Subsonic client for music)
- [ ] `scripts/backup.sh` runs manually without error
- [ ] `.env` is gitignored, `.env.example` has no real secrets
