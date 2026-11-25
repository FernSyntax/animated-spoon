# Security policy

This repository is an educational example. Its development defaults are
**intentionally insecure** (hard-coded JWT secret, `KD_DEV_MODE=true`, permissive
CORS, demo accounts) so that a fresh clone works offline. Do not deploy it as-is.

## Supported versions

Only the `main` branch receives fixes.

## Reporting a vulnerability

If you find a flaw that affects the authoritative engine, session handling, or
realm fencing, please open a **private security advisory** in the repository's
GitHub Security tab rather than a public issue. Include:

- the affected component and commit,
- a minimal reproduction,
- the impact you believe it has.

You should receive an acknowledgement within seven days. Fixes for confirmed
issues are released as part of the normal `main` branch flow and called out in
the release notes.

## Deployment checklist (before exposing any service)

- Set high-entropy `KD_JWT_SECRET` and `KD_INTERNAL_SECRET`, and disable `KD_DEV_MODE`.
- Set `KD_CORS_ORIGIN` to your real client origin; wildcard is rejected outside dev mode.
- Terminate TLS in front of every gateway and keep database/NATS networks
  private.
- Replace demo accounts and rotate credentials.
- Review `docs/threat-model.md` and `docs/runbooks.md`.
