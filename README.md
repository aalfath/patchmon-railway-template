[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/patchmon?utm_medium=integration&utm_source=button&utm_campaign=patchmon)

# PatchMon on Railway

A one-click [Railway](https://railway.com) template for [PatchMon](https://github.com/PatchMon/PatchMon), the open-source Linux patch monitoring and automation platform. Lightweight agents on your servers report pending package and security updates to one web dashboard, where you can review, schedule and run patching.

**Version:** PatchMon `2.1.8` (2026-11-06), from the official image `ghcr.io/patchmon/patchmon-server:2.1.8`, pinned by digest in the [`Dockerfile`](Dockerfile).

## What the template deploys

| Service | Built from | Role | Public | State |
|---|---|---|---|---|
| `PatchMon` | this repository ([`Dockerfile`](Dockerfile)) | Web UI, REST API, agent WebSocket endpoint, background jobs | yes | Railway volume at `/data` (Web SSH host-key pins) |
| `Postgres` | Railway's Postgres | Hosts, packages, users, settings, reports | no | Railway volume |
| `Redis` | Railway's Redis | Job queue, agent presence, rate limits | no | Railway volume |

- The PatchMon service builds from this repository, so Railway tells deployers when a new version is merged here.
- [`railway-start.sh`](railway-start.sh) sets `CORS_ORIGIN` to the Railway public domain, refuses to start without `DATABASE_URL`, `JWT_SECRET` or `SESSION_SECRET`, makes the volume writable and then runs PatchMon as the image's non-root user.
- Database migrations run automatically on every start.
- Health check: `/health` (checks Postgres and Redis, no login).

## Variables

| Variable | Value | Notes |
|---|---|---|
| `DATABASE_URL` | `${{Postgres.DATABASE_URL}}` | Private-network connection to Postgres |
| `REDIS_HOST`, `REDIS_PORT`, `REDIS_PASSWORD` | references to the Redis service | Private-network connection to Redis |
| `JWT_SECRET` | random, 64 characters | Signs login tokens |
| `SESSION_SECRET` | random, 64 characters | Session and fallback encryption secret |
| `AI_ENCRYPTION_KEY` | random, 64 hex characters | Encrypts stored secrets (bootstrap tokens, notification credentials, AI keys). Keep it: changing it makes those values unreadable |
| `PORT` | `3000` | Port PatchMon listens on |

There is nothing to fill in. Fixed defaults (`TZ=UTC`, `PATCHMON_SSH_KNOWN_HOSTS=/data/ssh/known_hosts`) are set in the `Dockerfile`. Any other [PatchMon setting](https://github.com/PatchMon/PatchMon/blob/main/docker/env.example) (OIDC single sign-on, password policy, rate limits, `TZ`) can be added as a service variable. With a custom domain, set `CORS_ORIGIN=https://your-domain` (comma-separate several origins).

## After deploying

1. Open the PatchMon service's public URL. The first-run wizard asks for the first admin's name, username, email and password. Do this right away: until an admin exists, anyone with the URL can create one.
2. Check **Settings → Server URL** shows your Railway URL (the wizard saves the URL you opened it from). Agents use it to reach PatchMon.
3. Click **Add Host**, copy the one-line install command and run it as root on each Linux server. The agent connects back over HTTPS and WebSocket and reports its pending updates.

## Not included

- **In-browser RDP for Windows hosts.** Upstream runs a `guacd` sidecar that must share the server's network namespace, which Railway doesn't offer. Everything else, including the Web SSH terminal, works.

## Updates

When this repository bumps the PatchMon version, Railway shows an "update available" notice on your project and you choose when to apply it. Read [`CHANGELOG.md`](CHANGELOG.md) first: breaking changes are listed at the top of each entry. Migrations run on start. Back up the Postgres volume before a major version.

## License

PatchMon is AGPL-3.0, see [PatchMon/PatchMon](https://github.com/PatchMon/PatchMon). This wrapper is MIT.
