# Reskinning / generating your own game

This repository is a **game generator**. The gameplay engine is theme-agnostic:
it knows about buildings, techs, troops and gold, but never about your game's
name, colours or art. Everything a player sees comes from one file and one
folder:

| What you change | Where |
| --- | --- |
| Game name, tagline, headline, description | `game.config.json` → `game` |
| Colours | `game.config.json` → `theme` |
| Item / building / tech / hero / unit labels | `game.config.json` → `labels` |
| All imagery | `clients/game/assets/art/` |

You do **not** edit Dart or Rust to reskin the game.

## The three-step reskin

```bash
# 1. Edit game.config.json (name, colours, labels).
# 2. Replace the PNGs in clients/game/assets/art/ using the same filenames
#    (or point the JSON at different filenames — the generator validates them).
# 3. Regenerate and verify.
make generate
make check
```

`make generate` runs `scripts/generate_game.py`, which:

- validates the JSON structure and every `#RRGGBB` colour,
- checks that every referenced asset actually exists (a missing sprite fails
  generation, not the running game),
- writes `clients/game/lib/game_config.dart` (generated, do not hand-edit),
- formats the generated file.

The Flutter app imports those constants everywhere: the app title, splash
screen, theme colours and all UI labels come from the generated file. Changing
`game.config.json` and rebuilding is sufficient to ship a differently branded
game with identical, fully tested gameplay.

## Asset contract

Keep the filenames referenced in `game.config.json` → `assets`. The defaults
are:

```
kingdom_splash.png  city_own.png  city_enemy.png
building_town_hall.png building_farm.png building_lumber_mill.png
building_quarry.png building_iron_mine.png building_market.png
building_warehouse.png building_barracks.png building_academy.png
building_wall.png building_hospital.png building_embassy.png
```

The Flame world renderer also uses `grass.png`, `forest.png`, `hills.png`,
`water.png`, `mountains.png`, `fort.png`, `monster.png`, `monster_dragon.png`,
`monster_golem.png`, `resource_node.png`, `march.png`, plus hero and unit
sprites. Those are looked up by a fixed key in `ui/world.dart`. Replace the
files with images of the same size/contract and no gameplay code changes.

> Placeholder art is intentionally simple geometric PNGs. `scripts/make_placeholders.py`
> regenerates them if you delete or corrupt one.

## Telling an AI agent to do it

The generator is designed for agent-driven reskins. A prompt like this is
sufficient (no code edits requested):

```
Read docs/RESKIN.md. Change game.config.json so the game is called "Empires of
Aether" with a violet/gold theme, update the labels for buildings and items to
match that fantasy setting, replace the artwork in clients/game/assets/art/
with the supplied files, then run `make generate` and `make check`. Fix any
failures the checks report. Do not edit gameplay code.
```

Because the server never reads these values, there is no protocol migration
and no database change: a reskin is a pure client-side rebuild.

## What is deliberately NOT configurable

- Game rules and numeric balance (`crates/kd-domain/src/content/`) — changing
  those changes gameplay and needs its own tests.
- The wire protocol (`proto/kd.proto`) — both clients are generated from it.
- Server secrets and endpoints — see `README.md` → Configuration.

Keeping these out of the reskin config is what makes generated games safe to
upgrade: you can pull engine fixes from this repository without merging
conflicts into your theme.
