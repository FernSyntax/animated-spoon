# Developer entry points. Every command here is also run by CI
# (.github/workflows/ci.yml), so a green `make check` locally means a green PR.

FLUTTER ?= flutter
DART ?= dart
CLIENT_DIR := clients/game
KD_TEST_DB_A ?= postgres://kd:kd@localhost:15433/kd_realm_a

.DEFAULT_GOAL := help
.PHONY: help generate fmt fmt-check lint test test-integration test-golden build check \
        client-get client-fmt client-fmt-check client-lint client-test \
        client-build-web client-build-linux client-build-android \
        client-build-macos client-build-windows client-build-ios \
        up down gen-dart clean

help: ## Show available targets.
	@grep -hE '^[a-zA-Z0-9_-]+:.*?## ' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-24s\033[0m %s\n", $$1, $$2}'

generate: ## Regenerate the client from game.config.json (reskin in one command).
	python3 scripts/generate_game.py

# ----- Rust -----------------------------------------------------------------

fmt: ## Format all Rust code.
	cargo fmt --all

fmt-check: ## Verify Rust formatting without changing files.
	cargo fmt --all -- --check

lint: ## Run Clippy with warnings denied.
	cargo clippy --workspace --all-targets -- -D warnings

test: ## Run fast unit, property and binary tests (no database needed).
	cargo test --workspace --lib --bins

test-integration: ## Run real-PostgreSQL engine and multiplayer tests.
	KD_TEST_DB_A=$(KD_TEST_DB_A) cargo test -p kd-engine --test engine -- --test-threads=2
	KD_TEST_DB_A=$(KD_TEST_DB_A) cargo test -p kd-engine --test multiplayer -- --test-threads=2

test-golden: ## Run the real-DB golden happy-path suite.
	KD_TEST_DB_A=$(KD_TEST_DB_A) cargo test -p kd-engine --test golden -- --test-threads=1

build: ## Build every workspace binary.
	cargo build --workspace

# ----- Flutter --------------------------------------------------------------

client-get: ## Fetch Dart dependencies.
	cd $(CLIENT_DIR) && $(FLUTTER) pub get

client-fmt: ## Format all Dart code.
	cd $(CLIENT_DIR) && $(DART) format .

client-fmt-check: ## Verify Dart formatting.
	cd $(CLIENT_DIR) && $(DART) format --output=none --set-exit-if-changed .

client-lint: ## Analyze the Flutter client.
	cd $(CLIENT_DIR) && $(FLUTTER) analyze

client-test: ## Run Flutter unit and widget tests.
	cd $(CLIENT_DIR) && $(FLUTTER) test

client-build-web: ## Build the web client.
	cd $(CLIENT_DIR) && $(FLUTTER) build web --release

client-build-linux: ## Build the Linux desktop client.
	cd $(CLIENT_DIR) && $(FLUTTER) build linux --release

client-build-android: ## Build the Android APK.
	cd $(CLIENT_DIR) && $(FLUTTER) build apk --release

client-build-macos: ## Build the macOS desktop client.
	cd $(CLIENT_DIR) && $(FLUTTER) build macos --release

client-build-windows: ## Build the Windows desktop client.
	cd $(CLIENT_DIR) && $(FLUTTER) build windows --release

client-build-ios: ## Build the iOS app without codesigning.
	cd $(CLIENT_DIR) && $(FLUTTER) build ios --release --no-codesign

# ----- Infrastructure & codegen --------------------------------------------

up: ## Start the local infrastructure and services.
	docker compose up -d --build

down: ## Stop the local stack.
	docker compose down

gen-dart: ## Regenerate Dart protobuf bindings from proto/kd.proto.
	bash scripts/gen_dart.sh

check: fmt-check lint test client-fmt-check client-lint client-test ## Run all fast local checks.

clean: ## Remove build artifacts.
	cargo clean
	rm -rf $(CLIENT_DIR)/build
