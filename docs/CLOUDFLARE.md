# Cloudflare Tunnel Setup

This doc covers creating and configuring the Cloudflare Tunnel that exposes the stack at `cloud.ziperlab.com` without opening any router ports.

## Overview

```
Internet → Cloudflare (HTTPS) → cloudflared tunnel → Caddy (:8080) → {Immich, Navidrome}
```

Cloudflare handles TLS termination. The tunnel daemon runs in Docker and connects outbound to Cloudflare — no inbound ports needed on the router.

## Step 1 — Create the tunnel

1. Log in to the [Cloudflare Zero Trust dashboard](https://one.dash.cloudflare.com/)
2. Go to **Networks > Tunnels**
3. Click **Create a tunnel**
4. Name it: `ziperlab-media`
5. Choose **Docker** as the connector type
6. Copy the generated token — you'll need it for the config

## Step 2 — Configure the tunnel

Copy the example config:

```bash
cp cloudflared/config.yml.example cloudflared/config.yml
```

Edit `cloudflared/config.yml`:

```yaml
tunnel: <YOUR_TUNNEL_ID>
credentials-file: /etc/cloudflared/<YOUR_TUNNEL_ID>.json

ingress:
  - hostname: cloud.ziperlab.com
    service: http://caddy:8080
  - service: http_status:404
```

Replace `<YOUR_TUNNEL_ID>` with the tunnel ID from the dashboard.

## Step 3 — Credentials file

The dashboard will give you a credentials JSON file. Download it and place it at `cloudflared/<TUNNEL_ID>.json`.

**Important:** this file is a secret — it's already in `.gitignore` via the `.env` pattern, but double-check before committing.

## Step 4 — DNS record

Cloudflare auto-creates a CNAME record for `cloud.ziperlab.com` pointing to the tunnel. Verify in the **DNS** tab:

| Type | Name | Content | Proxy |
|------|------|---------|-------|
| CNAME | cloud | `<tunnel-uuid>.cfargotunnel.com` | Proxied |

## Step 5 — Test

```bash
docker compose up -d cloudflared
docker compose logs -f cloudflared
```

Look for `connection registered` and `healthy` in the logs. Then check the Zero Trust dashboard — the tunnel status should show green.

Visit `https://cloud.ziperlab.com` — you should see Immich (it redirects to `/photos`).

## Tunnel token (alternative setup)

Instead of the config file approach, you can use a tunnel token directly. Add to `docker-compose.yml` under the `cloudflared` service:

```yaml
command: tunnel run
environment:
  TUNNEL_TOKEN: <YOUR_TOKEN>
```

This is simpler but keeps the token in the compose file rather than a separate config.

## Revoking access

To lock down the tunnel temporarily, set the Caddyfile's catch-all to return 403, or stop the cloudflared container:

```bash
docker compose stop cloudflared
```

The DNS record stays, but traffic won't reach your server.
