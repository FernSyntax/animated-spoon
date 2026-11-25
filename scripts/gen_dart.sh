#!/usr/bin/env bash
# Reproducible Dart protobuf codegen from the single canonical schema.
set -euo pipefail
cd "$(dirname "$0")/.."
command -v protoc >/dev/null || { echo "protoc required" >&2; exit 1; }
if ! command -v protoc-gen-dart >/dev/null; then
  echo "install with: dart pub global activate protoc_plugin" >&2
  exit 1
fi
# protoc-gen-dart is a Dart script: it needs `dart` on PATH as well.
export PATH="$HOME/.pub-cache/bin:$HOME/flutter-sdk/flutter/bin:$PATH"
protoc --dart_out=grpc:clients/game/lib/proto -I proto proto/kd.proto
echo "generated clients/game/lib/proto from proto/kd.proto"
