# Changelog

## 2.1.8 (2026-11-18)

- First release of this template: PatchMon 2.1.8 (official image `ghcr.io/patchmon/patchmon-server:2.1.8@sha256:bee093a3…cd094`), Railway Postgres and Railway Redis, health check `/health`.
- Generated `JWT_SECRET`, `SESSION_SECRET` and `AI_ENCRYPTION_KEY`; the first admin is created in PatchMon's first-run wizard.
- Not included: upstream's `guacd` sidecar (in-browser RDP), which needs a shared network namespace.
