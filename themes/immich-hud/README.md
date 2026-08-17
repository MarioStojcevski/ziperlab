# Immich HUD Theme

Retro strategic sci-fi command console theme for Immich.

## Design Tokens

| Token | Hex | Usage |
|---|---|---|
| `--hud-bg` | `#05070A` | Deep space black background |
| `--hud-green` | `#39FF88` | Phosphor green — primary accent, active states |
| `--hud-amber` | `#FFB000` | Amber — warnings, danger, date separators |
| `--hud-cyan` | `#4DE8FF` | Cold cyan — secondary accent, hover states |
| `--hud-border` | `#123322` | Dim green — hairline borders |
| `--hud-text` | `#C8D6C0` | Primary text (slightly green-tinted) |
| `--hud-text-dim` | `#5A6B54` | Secondary / muted text |

## Typography

- **Chrome/labels/buttons:** Share Tech Mono (monospace, uppercase, letter-spaced)
- **Body/content text:** System sans-serif (readability for photo metadata)

## Features

- Scanline overlay (subtle CRT effect, 4px repeating gradient)
- Bracket-corner cards instead of rounded rectangles
- Boot-sequence flicker animation on login screen only
- Restrained hover glow on interactive elements
- Custom scrollbars, modals, dropdowns, tables — all HUD-styled
- Print stylesheet strips effects back to basics

## Application

1. Log in to Immich as admin
2. Go to **Administration > Settings > Custom Styling**
3. Paste full contents of `custom.css`
4. Save — applies immediately for all users, no restart needed

This is a manual sync step since Immich stores custom CSS in its own database, not as a mounted file. Keep this repo copy as the source of truth.
