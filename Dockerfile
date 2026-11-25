# Multi-stage build producing minimal runtime images for all Rust services.
FROM rust:1.99-slim-bookworm AS builder
RUN apt-get update && apt-get install -y --no-install-recommends \
    pkg-config libssl-dev protobuf-compiler cmake ca-certificates \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /build
COPY Cargo.toml Cargo.lock rust-toolchain.toml ./
COPY proto proto/
COPY crates crates/
COPY services services/
COPY migrations migrations/
RUN cargo build --release --workspace --locked

FROM debian:bookworm-slim AS runtime
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates libssl3 \
    && rm -rf /var/lib/apt/lists/*
COPY --from=builder /build/target/release/control-plane /usr/local/bin/control-plane
COPY --from=builder /build/target/release/gateway /usr/local/bin/gateway
COPY --from=builder /build/target/release/realm-worker /usr/local/bin/realm-worker
COPY --from=builder /build/target/release/outbox-worker /usr/local/bin/outbox-worker
COPY --from=builder /build/target/release/loadgen /usr/local/bin/loadgen
COPY --from=builder /build/target/release/payments /usr/local/bin/payments
ENV RUST_LOG=info
ENTRYPOINT ["/usr/local/bin/gateway"]
