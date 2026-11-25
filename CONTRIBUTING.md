# Contributing

Thanks for helping make this a reference 4X implementation. Please read the
[README](README.md) for the architecture and local setup first.

## Ground rules

- **One canonical schema.** `proto/kd.proto` is the source of truth for the wire
  protocol. Regenerate both Rust and Dart bindings with `make gen-dart` and
  commit the results together with the schema change. Never hand-edit files
  under `clients/game/lib/proto/`.
- **The realm worker owns gameplay state.** Gateways and the control plane must
  never write gameplay tables. New mutations belong in `crates/kd-engine`.
- **Put new code in the matching module, not in a facade.**
  - Engine command handlers: `crates/kd-engine/src/commands/<feature>.rs`
    (`city`, `movement`, `alliance`, `rally`, `events`, `combat`, `logistics`,
    `progression`). Shared DB helpers and `dispatch` stay in `commands/mod.rs`.
  - Static game data: `crates/kd-domain/src/content/<domain>.rs`. Re-export from
    `content/mod.rs` so the public `kd_domain::content::*` API is unchanged.
  - Flutter screens: `clients/game/lib/ui/<feature>.dart`, declared as a `part`
    of `screens.dart`. Parts share the facade's imports, so the private helpers
    (`_Section`, `buildingArt`, …) remain private to the library. `main.dart`
    stays a thin entry point; session screens live in `auth.dart`.
  - Services keep `main.rs` to wiring only. Request handlers, shared state and
    pure helpers live in sibling modules (`app`, `http`, `service`, `seed`,
    `client`), which makes them unit-testable without starting a server.
- **No floats in economy or combat math.** Use integer units with persisted
  remainders (see `crates/kd-domain/src/economy.rs`) so results are identical
  for every client and every polling cadence.
- **Tests accompany behaviour.** A new command needs a unit/property test in
  `kd-domain`/`kd-engine` and, when it changes the UI, a Flutter widget test.

## Before you open a pull request

Run the same checks CI runs:

```bash
make check              # fmt-check, clippy, cargo tests, Dart format, analyze, Flutter tests
make test-integration   # requires docker compose up -d global-db realm-db-a nats valkey
```

Both commands must be green. If a platform build you touched cannot be run
locally, say so in the PR description and the CI matrix will cover it.

## Style

- Rust: `cargo fmt` and Clippy with `-D warnings`. Add a short `//!` module
  document to new modules and `///` docs to public items that encode a rule.
- Dart: `dart format` and `flutter analyze` with the strict options in
  `clients/game/analysis_options.yaml`.
- Prefer explaining *why* a rule or workaround exists; the *what* is usually
  visible in the code. Link the relevant section of `docs/rules.md` when a
  constant implements a game rule.

## Commit & review

Use conventional commit subjects (`feat:`, `fix:`, `docs:`, `refactor:`,
`test:`, `chore:`). Keep commits focused. Reviewers will look for protocol
compatibility, determinism, and safe failure modes (timeouts, retries, fencing).

## Security

Please report vulnerabilities privately as described in [SECURITY.md](SECURITY.md).
Do not open a public issue for an exploitable bug.
