#!/usr/bin/env python3
"""Generate the client's branding and labels from `game.config.json`.

This is the only step needed to reskin the game: edit the JSON, replace the
files in `clients/game/assets/art/`, run `make generate`, rebuild. The server
does not depend on any of these values, so a reskin cannot change gameplay.

Generated: clients/game/lib/game_config.dart
"""

from __future__ import annotations

import json
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CONFIG = ROOT / "game.config.json"
OUT = ROOT / "clients" / "game" / "lib" / "game_config.dart"
ART = ROOT / "clients" / "game" / "assets" / "art"

REQUIRED = ("game", "theme", "assets", "labels")


def fail(message: str) -> None:
    print(f"game config error: {message}", file=sys.stderr)
    raise SystemExit(1)


def dart_string(value: str) -> str:
    return "'" + value.replace("\\", "\\\\").replace("'", "\\'").replace("\n", "\\n") + "'"


def dart_map(name: str, mapping: dict[str, str]) -> str:
    lines = [f"const Map<String, String> {name} = {{"]
    for key, value in sorted(mapping.items()):
        lines.append(f"  {dart_string(key)}: {dart_string(value)},")
    lines.append("};")
    return "\n".join(lines)


def color(name: str, value: str) -> str:
    text = value.strip().lstrip("#")
    if len(text) != 6:
        fail(f"theme.{name} must be a #RRGGBB colour, got {value!r}")
    try:
        int(text, 16)
    except ValueError:
        fail(f"theme.{name} is not hexadecimal: {value!r}")
    return f"const Color {name} = Color(0xff{text.lower()});"


def main() -> None:
    if not CONFIG.is_file():
        fail(f"missing {CONFIG}")
    cfg = json.loads(CONFIG.read_text(encoding="utf-8"))
    for key in REQUIRED:
        if key not in cfg:
            fail(f"missing top-level section {key!r}")

    game, theme, assets, labels = (
        cfg["game"], cfg["theme"], cfg["assets"], cfg["labels"]
    )
    for key in ("name", "short_name", "tagline", "headline", "description", "version"):
        if key not in game:
            fail(f"missing game.{key}")

    # Validate asset references early: a reskin must fail at generation time,
    # never at runtime with a blank screen.
    referenced = [assets.get("splash"), assets.get("city_own"), assets.get("city_enemy")]
    referenced += list(assets.get("buildings", {}).values())
    missing = sorted({a for a in referenced if a and not (ART / a).is_file()})
    if missing:
        fail("missing asset files: " + ", ".join(missing))

    lines = [
        "// GENERATED FILE — do not edit. Run `make generate`.",
        "// Source of truth: game.config.json",
        "library;",
        "",
        "// ignore: deprecated_member_use",
        "import 'package:flutter/material.dart';",
        "",
        f"const String gameId = {dart_string(game['id'] if 'id' in game else 'game')};",
        f"const String gameName = {dart_string(game['name'])};",
        f"const String gameShortName = {dart_string(game['short_name'])};",
        f"const String gameTagline = {dart_string(game['tagline'])};",
        f"const String gameHeadline = {dart_string(game['headline'])};",
        f"const String gameDescription = {dart_string(game['description'])};",
        f"const String gameVersion = {dart_string(game['version'])};",
        "",
        f"const String assetPrefix = {dart_string(assets['prefix'])};",
        f"const String splashArt = {dart_string(assets['splash'])};",
        f"const String cityOwnArt = {dart_string(assets['city_own'])};",
        f"const String cityEnemyArt = {dart_string(assets['city_enemy'])};",
        "",
    ]
    for name in ("primary", "secondary", "surface", "background", "canvas", "text", "muted"):
        if name not in theme:
            fail(f"missing theme.{name}")
        lines.append(color(name, theme[name]))
    lines.append("")

    for section in ("buildings", "techs", "items", "heroes"):
        mapping = labels.get(section)
        if not isinstance(mapping, dict):
            fail(f"labels.{section} must be an object")
        lines.append(dart_map(f"{section}Labels", mapping))
        lines.append("")

    units = labels.get("units")
    if not isinstance(units, list):
        fail("labels.units must be a list")
    unit_list = ", ".join(dart_string(u) for u in units)
    lines.append(f"const List<String> unitLabels = [{unit_list}];")
    lines.append("")

    # Call sites append ".png" themselves; emit stems to stay compatible.
    art = {
        key: value[:-4] if value.endswith(".png") else value
        for key, value in assets.get("buildings", {}).items()
    }
    lines.append(dart_map("buildingArtFiles", art))
    lines.append("")

    OUT.write_text("\n".join(lines), encoding="utf-8")
    dart = shutil.which("dart") or str(
        Path.home() / "flutter-sdk/flutter/bin/cache/dart-sdk/bin/dart"
    )
    if Path(dart).is_file() or shutil.which("dart"):
        subprocess.run([dart, "format", str(OUT)], check=True, capture_output=True)
    print(f"generated {OUT.relative_to(ROOT)}")
    print(f"  game: {game['name']!r} ({len(art)} building skins, {len(labels['items'])} items)")


if __name__ == "__main__":
    main()
