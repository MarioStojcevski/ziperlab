# Users and Sharing

How to set up multiple accounts and share libraries between users.

## Immich — Photos

Immich has full multi-user support with real per-user libraries and selective sharing.

### Creating users

1. Log in as admin
2. Go to **Administration > Users > Create**
3. Enter email and password for the new user
4. The new user gets their own login, timeline, and uploads

### Sharing options

**Option A: Share specific albums**

1. Open an album
2. Click **Share**
3. Invite by email or username
4. The invitee sees only shared albums, not your full library

**Option B: Partner Sharing (standing share)**

1. Go to **Account Settings > Partner Sharing**
2. Add your partner's account
3. Each partner's full library becomes visible to the other
4. This is the closest to "your library + shared library"

**Recommendation:** Use Partner Sharing for household members who want full access to each other's photos. Use album sharing for one-off sharing with specific people.

## Navidrome — Music

### Creating users

1. Log in as admin
2. Go to **Settings > Users > Create**
3. Set username and password

### The sharing caveat

Navidrome does **not** support per-user private libraries. Every user with an account sees the same music collection. Admin permissions can restrict who can manage the library, but not who can see what's in it.

This is a known architectural limitation of Navidrome. Options if you need per-user music separation later:

- Run a second Navidrome instance with its own music directory
- Switch to a different music server that supports user libraries
- Accept one shared household library (simplest, works for most households)

## Summary

| Service | Per-user library | Selective sharing | Limitation |
|---------|-----------------|-------------------|------------|
| Immich | Yes | Albums + Partner Sharing | None |
| Navidrome | No | N/A | All users see all music |
