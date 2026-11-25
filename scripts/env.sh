export KD_JWT_SECRET=local-development-secret-not-for-production
export KD_INTERNAL_SECRET=dev-internal-secret-change-me
export KD_DEV_MODE=true
export KD_NATS_URL=nats://localhost:4222
export KD_VALKEY_URL=redis://localhost:6379
export KD_GLOBAL_DB_URL=postgres://kd:kd@localhost:15432/kd_global
export KD_SHARD_DBS__SHARD_A=postgres://kd:kd@localhost:15433/kd_realm_a
export KD_SHARD_DBS__SHARD_B=postgres://kd:kd@localhost:15434/kd_realm_b
export KD_REALMS=realm-a:shard_a:12345,realm-b:shard_b:67890
export KD_CONTROL_PLANE_GRPC=http://localhost:50051

# Payments (optional). Leave KD_STRIPE_SECRET_KEY unset to use the local dev
# stub checkout provider; no real money moves in that mode.
# export KD_HTTP_ADDR=0.0.0.0:8088
# export KD_PUBLIC_BASE_URL=http://localhost:8088
# export KD_STRIPE_SECRET_KEY=sk_test_...
# export KD_STRIPE_WEBHOOK_SECRET=whsec_...
# export KD_STRIPE_SUCCESS_URL=http://localhost:8088/checkout/success
# export KD_STRIPE_CANCEL_URL=http://localhost:8088/checkout/cancel
export RUST_LOG=info
