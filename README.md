# ZiperLab Media Stack

Self-hosted photo and music library. Immich for photos (auto backup, face recognition, semantic search, albums) and Navidrome for music (Subsonic API compatible, works with streaming apps). All processing local, nothing leaves the server.

## Architecture

```
                    ┌─────────────────────┐
                    │   Cloudflare DNS    │
                    │ cloud.ziperlab.com  │
                    └─────────┬───────────┘
                              │ HTTPS (auto)
                    ┌─────────▼───────────┐
                    │     cloudflared      │
                    │   (Tunnel daemon)    │
                    └─────────┬───────────┘
                              │
                    ┌─────────▼───────────┐
                    │       Caddy         │
                    │   Reverse Proxy     │
                    │   :8080 (internal)  │
                    └──┬──────────────┬───┘
                       │              │
              /photos  │              │  /music
                       │              │
              ┌────────▼──┐    ┌──────▼───────┐
              │  Immich   │    │  Navidrome   │
              │  Server   │    │              │
              │  :2283    │    │  :4533       │
              └─────┬─────┘    └──────────────┘
                    │
         ┌──────────┼──────────┐
         │          │          │
   ┌─────▼──┐ ┌────▼───┐ ┌───▼────┐
   │ Redis  │ │ Postgres│ │  ML    │
   │        │ │(pgvecto)│ │ Worker │
   └────────┘ └────────┘ └────────┘
```

## Quick Start

1. Clone this repo on the server
2. `cp .env.example .env` and generate a real `DB_PASSWORD` with `openssl rand -hex 24`
3. `chmod +x scripts/init-volumes.sh && ./scripts/init-volumes.sh`
4. `docker compose up -d`
5. Wait for Immich server logs: `docker compose logs -f immich-server`
6. Visit `https://cloud.ziperlab.com/photos` — create admin account
7. Visit `https://cloud.ziperlab.com/music` — Navidrome auto-creates first-run admin
8. Apply HUD theme: Immich admin > Settings > Custom Styling > paste `themes/immich-hud/custom.css`

See [docs/SETUP.md](docs/SETUP.md) for the full walkthrough, [docs/CLOUDFLARE.md](docs/CLOUDFLARE.md) for tunnel setup.

## Documentation

- [SETUP.md](docs/SETUP.md) — full installation guide
- [CLOUDFLARE.md](docs/CLOUDFLARE.md) — Cloudflare Tunnel configuration
- [USERS_AND_SHARING.md](docs/USERS_AND_SHARING.md) — multi-user accounts and library sharing
- [MOBILE_APPS.md](docs/MOBILE_APPS.md) — phone app setup for both services
- [BACKUP.md](docs/BACKUP.md) — backup strategy and scripts

## Known Limitations

**Navidrome sharing is effectively one shared library.** Navidrome supports multi-user accounts, but there is no per-user private library with selective sharing. Every user with an account sees the same music collection. Permissions can restrict admin actions, not library visibility. If true per-user music separation matters later, that requires a second Navidrome instance or a different tool.

Immich does not have this limitation — it has full shared albums and partner sharing between accounts.
