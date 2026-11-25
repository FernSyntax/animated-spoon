# Protocol and command catalogue

Canonical schema: `proto/kd.proto`. Rust bindings via `tonic-build`/`prost`; Dart via
`protoc --dart_out=grpc` (`scripts/gen_dart.sh`). HTTPS for auth/bootstrap, binary
protobuf WebSocket frames for commands/results/deltas, gRPC internal.

## Wire envelope

`WsEnvelope { seq, oneof { hello, command, command_result, delta, snapshot,
heartbeat, error, subscription } }`. Frames are length-bounded (`max_frame_bytes`).
The gateway rejects cross-realm commands (client-supplied realm must equal the session
realm) and overwrites the principal with the verified one.

## Command → handler

All commands carry `command_id` and are deduplicated per realm/principal/id.

| Command | Effect |
|---|---|
| CreateCity | deterministic placement, unique tile, initial buildings/items/hero |
| UpgradeBuilding | priced + prerequisite + one city queue, scheduled completion |
| StartResearch | priced + prerequisite + player-wide queue |
| TrainTroops / HealTroops | priced, garrison capacity, timed queues |
| UseItem / SetShield | atomic consumption, speedup own queue, protection window |
| ScoutTile / AttackMonster / Gather | march dispatch, arrival resolution, reports |
| AttackCity / AttackFort | scouting + shield + alliance checks, deterministic combat |
| Reinforce / Transport | ally-only timed transfers, atomic reservation |
| Recall | invalidates pending arrival event atomically |
| CreateAlliance / Invite / Accept / Join / Leave / Kick / Help | full alliance lifecycle |
| RallyCreate / RallyJoin / RallyCancel | reservation, launch, safe return |
| Chat | world/alliance scope, size limit, visibility-filtered delivery |
| SwitchCapital | capital reassignment among owned cities |

## Results

`CommandResult { command_id, code, message, state_version, server_time_unix_ms,
state_json }`. Codes are the `ErrorCode` enum; game-rule rejections are distinct from
system errors. `state_json` contains the authoritative player snapshot after success,
so the UI reflects server-confirmed state rather than optimistic guesses.

## Deltas

`DeltaEvent` includes a stable event id, realm, type, optional spatial position,
private/ally visibility, server time and a cursor. The gateway filters by the
client's subscribed chunks and private visibility before encoding. Private data is
never encoded into another player's stream.
