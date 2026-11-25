# Decisions and deviations

- **Rust 1.99, tonic 0.13, prost 0.13, axum 0.8, sqlx 0.8** pinned for compatibility;
  lockfile committed. Config is read explicitly from env rather than a config crate
  because nested map env parsing differed across versions.
- **Per-realm serialization** through the ownership row lock instead of fine-grained
  row locking. Simpler and demonstrably correct; documented as the main single-realm
  throughput bottleneck in `docs/capacity.md`. Does not weaken scope: correctness and
  security are the top priority.
- **JSON snapshots/deltas inside protobuf bytes** for gameplay state, while the envelope
  and all commands/results are versioned protobuf. This keeps the schema stable while
  complex state evolves; generated Dart/Rust bindings still come from one schema.
- **Gateway CORS is permissive in dev only** so Flutter web can talk to localhost.
  Production must pin origins; this is listed as production hardening, not a local pass.
- **Local host ports remapped** (15432/15433/15434) because 5432/5433 were occupied by
  a pre-existing PostgreSQL on the development machine. Compose internal ports unchanged.
- **Browser integration evidence is partial**: a real Flutter web client was launched
  against the backend and the two-user UI harness reached sign-in/realm selection, but
  Chromium/chromedriver in this environment was flaky (renderer crashes). Web build,
  analyze and widget tests pass; the full two-user browser workflow is recorded as
  BLOCKED on that tooling in `ACCEPTANCE.md` and is not claimed as passed.
- No external art, no browser wrappers, no substitute stack, no mocked multiplayer,
  no skipped tests. No `goal.md` edits.
