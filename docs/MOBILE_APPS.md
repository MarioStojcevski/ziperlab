# Mobile Apps

Phone app setup for accessing the stack on iOS and Android.

## Immich — Photos

**Official app:** search "Immich" on the App Store (iOS) or Google Play (Android).

### Setup

1. Open the app
2. Server URL: `https://cloud.ziperlab.com/photos`
3. Log in with your Immich account credentials
4. Enable background backup in app settings (optional, but recommended — auto-uploads new photos)

### Notes

- The app works over the Cloudflare tunnel, no VPN needed
- First sync may take a while depending on your photo library size
- Face recognition and search work fully in the app

## Navidrome — Music

No official Navidrome app exists. It speaks the **Subsonic API**, so use any Subsonic-compatible client.

### Android

| App | Price | Notes |
|-----|-------|-------|
| **Ultrasonic** | Free | Clean, open source, solid |
| **Symfonium** | Paid | More polished, better offline support |

### iOS

| App | Price | Notes |
|-----|-------|-------|
| **play:Sub** | Paid | Good library management |
| **Amperfy** | Free | Newer, focused on streaming |

### Setup (all apps)

1. Open the app
2. Server URL: `https://cloud.ziperlab.com/music`
3. Log in with your Navidrome account credentials
4. The app will index and display your music library

### Notes

- Subsonic API works over HTTPS through the Cloudflare tunnel
- Download for offline listening depends on the client app's support
- Gapless playback and streaming quality settings are client-side
