# Threat model

| Threat | Mitigation |
|---|---|
| Forged client identity / player id | JWT verified by control-plane on every validate; gateway is the only caller of internal gRPC and authenticates with a shared secret; worker rejects empty/malformed principal |
| Cross-realm mutation | Realm in command must match WS session realm; every realm-scoped query includes realm_id; separate shard DBs |
| Replayed / double-submit | Dedup table PK(realm, principal, command id) + canonical protobuf payload hash; conflicting reuse rejected; both accept and reject results are persisted durably |
| Negative / overflow quantities | CHECK constraints, i64 checked arithmetic, caps on counts/costs/rates, typed payload validation at dispatch |
| Client-controlled cost/timer/result | All derived from server catalogs and clock; client never sends amounts that affect cost except validated units/counts |
| Stale owner writes after failover | Fencing epoch + lease checked inside every mutating transaction; takeover increments epoch |
| Broker/cache loss | Outbox rows remain pending until published; JetStream uses stable message IDs; broker is never an authority |
| Malformed frames / abuse | Bounded frame size, rate limit per session, bounded subscription count, bounded outbound queue, strict protobuf decoding |
| Credential leakage | Argon2id hashes, no passwords in logs, JWT secret from env, demo accounts disabled when dev_mode=false |
| Browser origin abuse | `KD_CORS_ORIGIN` is configurable; `Settings::load` refuses `*` when `dev_mode=false`; Compose dev uses permissive CORS for local Flutter web only |
| Private data leak | Server-side visibility filtering before encoding; reports visible only to participants/allies |
| Admin abuse | Clock control requires a valid session + `dev_mode`; `create_realm` is dev-only. These are development conveniences, not production admin APIs — keep dev_mode off in production. |

## Production hardening still required (not validated locally)

TLS termination, rotate `KD_INTERNAL_SECRET`, private admin network, least-privilege DB roles,
network policies, secret management, audit review and external penetration testing.

### Known residual risk

The browser client authenticates the WebSocket with a bearer token in the query
string (`/ws?token=...`) because the Flutter `WebSocketChannel` API has no
first-frame hook before connection. Query strings can be captured by proxy and
access logs. Until the protocol moves to a subprotocol or an authenticated
upgrade header, keep access logs free of full URLs and terminate TLS in front of
the gateway. This is acceptable for a local/reference deployment, not for
internet-facing production.
No real-money flow exists, so payment fraud is out of scope.
