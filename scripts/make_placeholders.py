#!/usr/bin/env python3
"""Generate flat-colour placeholder PNGs for future ChatGPT art.

These are intentionally simple geometric stand-ins. Replace the files in
clients/game/assets/art/ with your rendered images of the same name; the client
loads them at runtime and falls back to procedural geometry if one is missing.
No external art is shipped by this repository.
"""
import os
import struct
import zlib

OUT = os.path.join(os.path.dirname(__file__), "..", "clients", "game", "assets", "art")
os.makedirs(OUT, exist_ok=True)

# name -> (base RGB, accent RGB)
SPECS = {
    "grass": ((74, 126, 72), (104, 160, 88)),
    "forest": ((34, 92, 62), (54, 124, 78)),
    "hills": ((118, 110, 78), (150, 140, 96)),
    "water": ((34, 86, 118), (56, 122, 158)),
    "mountains": ((104, 106, 116), (138, 140, 150)),
    "city_own": ((54, 190, 140), (120, 235, 195)),
    "city_enemy": ((70, 140, 225), (130, 185, 245)),
    "monster": ((230, 90, 80), (250, 150, 120)),
    "resource_node": ((225, 175, 70), (250, 215, 120)),
    "fort": ((175, 105, 235), (210, 160, 250)),
    "march": ((250, 205, 95), (255, 235, 160)),
    "building_town_hall": ((210, 170, 120), (240, 210, 160)),
    "building_farm": ((120, 180, 90), (165, 215, 125)),
    "building_barracks": ((180, 100, 90), (220, 150, 130)),
    "building_academy": ((110, 140, 210), (155, 180, 235)),
    "building_wall": ((150, 150, 160), (190, 190, 200)),
    "hero_portrait": ((90, 130, 190), (140, 180, 230)),
    "item_bundle": ((215, 180, 90), (245, 220, 140)),
}


def png(path, w, h, pixels):
    def chunk(tag, data):
        return (struct.pack(">I", len(data)) + tag + data
                + struct.pack(">I", zlib.crc32(tag + data) & 0xffffffff))
    raw = b"".join(b"\x00" + bytes(pixels[y]) for y in range(h))
    with open(path, "wb") as f:
        f.write(b"\x89PNG\r\n\x1a\n")
        f.write(chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0)))
        f.write(chunk(b"IDAT", zlib.compress(raw, 9)))
        f.write(chunk(b"IEND", b""))


def make(name, base, accent, size=128):
    px = []
    for y in range(size):
        row = []
        for x in range(size):
            # Isometric diamond silhouette with a two-tone facet pattern.
            nx = abs(x - size / 2) / (size / 2)
            ny = abs(y - size / 2) / (size / 2)
            inside = nx + ny < 1.0
            facet = ((x // 16 + y // 16) % 2) == 0
            c = accent if facet else base
            row.extend([c[0], c[1], c[2], 255 if inside else 0])
        px.append(row)
    png(os.path.join(OUT, name + ".png"), size, size, px)


for n, (b, a) in SPECS.items():
    make(n, b, a)
print(f"generated {len(SPECS)} placeholders in {OUT}")
