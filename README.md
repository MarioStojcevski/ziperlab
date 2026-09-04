# ZiperLab Media Stack

Your own private Google Photos and Spotify — but you own it. Everything runs on a home server, nothing gets uploaded to anyone else's cloud.

**For photos:** [Immich](https://immich.app) — auto-backup from your phone, face recognition, search by what's in the photo, albums, the works. There's a mobile app that feels just like Google Photos.

**For music:** [Navidrome](https://www.navidrome.org) — points at a folder of your music files and serves them up with proper metadata, album art, and streaming. Works with a bunch of phone apps.

**For server monitoring:** [Glances](https://nicolargo.github.io/glances/) — a live dashboard showing CPU, RAM, disk space, network traffic, and everything Docker is running. So you know what's going on under the hood.

## How it fits together

```
    Production (anywhere)              Local dev (localhost)
    ─────────────────────              ─────────────────────
         You                               You
           |                                 |
  photos.ziperlab.com              localhost:2283  (Immich)
  music.ziperlab.com               localhost:4533  (Navidrome)
  admin.ziperlab.com               localhost:61208 (Glances)
           |                                 |
      cloudflared                           |
           |                                 |
        Caddy (subdomains)                  |
           |                                 |
    Immich  Navidrome  Glances               -
```

The whole thing runs in Docker. One command to start, one command to stop.

## Quick start — local dev

Works on Windows, Mac, or Linux. Install Docker, copy `.env.example` to `.env`, set paths for your OS, then:

```bash
docker compose up -d
```

Open in your browser:

| Service | URL |
|---------|-----|
| Photos | http://localhost:2283 |
| Music | http://localhost:4533 |
| Dashboard | http://localhost:61208 |

Cloudflared is skipped by default. See [docs/SETUP.md](docs/SETUP.md) for the full walkthrough.

## What you need for production

- A Linux server (even a modest one works)
- Docker installed
- A Cloudflare account (free tier is fine) with `ziperlab.com` pointing to it
- DNS records: `photos`, `music`, `admin` A records pointing to your server
- Your music files dumped into a folder

The full setup steps are in [docs/SETUP.md](docs/SETUP.md) — it walks through everything from cloning the repo to seeing your photos in the browser.

## What it looks like

Immich gets a custom retro-sci-fi HUD theme (deep space black, phosphor green accents, monospace chrome). It's applied through Immich's built-in custom CSS field — no rebuilding Docker images, just paste and save.

Navidrome ships with its default UI for now. Theming it properly means forking the source, which is a separate project.

## Guides

| What | Where |
|------|-------|
| Full installation walkthrough | [docs/SETUP.md](docs/SETUP.md) |
| Cloudflare tunnel setup (how to expose it to the internet) | [docs/CLOUDFLARE.md](docs/CLOUDFLARE.md) |
| Adding users and sharing photos/music | [docs/USERS_AND_SHARING.md](docs/USERS_AND_SHARING.md) |
| Phone app setup | [docs/MOBILE_APPS.md](docs/MOBILE_APPS.md) |
| Backups — because this is self-hosted now | [docs/BACKUP.md](docs/BACKUP.md) |

## One thing to know about music sharing

Immich has real per-user libraries — you and your partner can each have your own photo collections and selectively share albums.

Navidrome does **not** do this. Everyone who logs in sees the same music library. You can have separate logins, but there's no "your music vs. my music." It's one shared household collection. If you need per-user music separation later, that means running a second Navidrome instance — but for most households, one shared library is fine.
