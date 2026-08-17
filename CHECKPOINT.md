# CHECKPOINT — ZiperLab Media Stack

Last updated: 2026-08-18

## What this repo is

Self-hosted media stack: Immich (photos), Navidrome (music), Glances (server dashboard), all behind Caddy reverse proxy + Cloudflare Tunnel at `cloud.ziperlab.com`. Everything runs in Docker on a home Ubuntu/Debian server.

## What's built (local, not deployed)

All files are scaffolded locally at `C:\Users\mario\projects\ziperlab\`:

```
├── .env.example              # all env vars, needs real .env on server
├── .gitignore                # secrets + editor junk excluded
├── docker-compose.yml        # 8 services: Immich (4), Navidrome, Glances, Caddy, cloudflared
├── caddy/Caddyfile           # /photos → Immich, /music → Navidrome, /admin → Glances
├── cloudflared/config.yml.example  # tunnel ingress template
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

## Git status

Repo is initialized on `main`. 15 files staged from initial scaffold + 4 modified files from Glances addition. **Nothing committed yet** — git identity needs to be configured first:

```bash
git config user.email "your@email.com"
git config user.name "Your Name"
git commit -m "feat: scaffold ziperlab media stack with Immich, Navidrome, Glances"
```

## Services (what runs)

| Service | URL path | Port | What it does |
|---------|----------|------|-------------|
| Immich Server | `/photos` | 2283 (internal) | Photo/video library, face recognition, search |
| Immich ML | — | internal | Machine learning worker (face detect, etc.) |
| Immich Redis | — | internal | Cache layer |
| Immich Postgres | — | internal | Database (pgvecto-rs for vector search) |
| Navidrome | `/music` | 4533 (internal) | Music streaming, Subsonic API |
| Glances | `/admin` | 61208 (internal) | Server monitoring dashboard |
| Caddy | — | 8080 (host) | Reverse proxy, routes all traffic |
| cloudflared | — | none | Tunnel to Cloudflare |

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
3. Add public hostname: `cloud.ziperlab.com` → `http://caddy:8080`
4. Download credentials JSON, place at `cloudflared/<TUNNEL_ID>.json`
5. Fill in `cloudflared/config.yml` with tunnel ID and credentials path

### 8. Start everything
```bash
docker compose up -d
docker compose logs -f immich-server
# wait for "Immich Server is listening"
```

### 9. First login + theme
- `https://cloud.ziperlab.com/photos` — create Immich admin
- `https://cloud.ziperlab.com/music` — Navidrome auto-creates admin
- `https://cloud.ziperlab.com/admin` — Glances dashboard (no login by default)
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
- [ ] `https://cloud.ziperlab.com/photos` — Immich login loads over HTTPS
- [ ] `https://cloud.ziperlab.com/music` — Navidrome login loads over HTTPS
- [ ] `https://cloud.ziperlab.com/admin` — Glances dashboard loads
- [ ] HUD theme applied on Immich
- [ ] Second Immich user created, album sharing tested
- [ ] Mobile app tested on phone (Immich official + Subsonic client for music)
- [ ] `scripts/backup.sh` runs manually without error
- [ ] `.env` is gitignored, `.env.example` has no real secrets
