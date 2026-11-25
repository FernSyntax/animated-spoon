# Game rules and formulas (content version 1)

All authoritative quantities are integers. No floats are used for resources, troops or
costs. Checked arithmetic and caps prevent overflow.

## Economy

`Modifiers` are aggregated from city building levels + player-wide research + the hero
assigned to the city. Production values are scaled by 1000 per hour. Accrual since the
persisted `last_accrued_ms` uses fixed point with a 1e6 fractional remainder per
resource:

```
per_sec_micro = prod_scaled_per_hour * 1_000_000 / (1000 * 3600)
total_micro   = persisted_remainder + per_sec_micro * elapsed_secs
whole_units   = total_micro / 1_000_000
remainder     = total_micro % 1_000_000
stored        = min(capacity, stored + whole_units)
```

Saturation discards excess production and its remainder. Polling frequency never
changes the result. Capacity derives from Town Hall + Warehouse; gold capacity is half
general capacity. Resource spends are checked against the accrued balance and debited
atomically with the mutation.

## Buildings / research

- 12 buildings, max level 20. Cost/time grow with integer permille multipliers per
  level (`base * growth^(level-1) / 1000`). Prerequisites are validated against actual
  building or research levels. One construction queue per city.
- 14 technologies × 3 levels, one research queue per player, prerequisites checked
  against real levels, effects applied to the `Modifiers` used by economy, movement and
  combat. No cosmetic research.

## Troops

5 unit families (infantry, ranged, cavalry, siege, scout) × 3 tiers. Each has integer
attack, defense, speed (tiles/hour), carry and per-unit cost. Tier unlock requires a
Barracks level. Troops reserved for a march are deducted at dispatch and restored (as
survivors) at return; a second dispatch/train of the same units is impossible. Wounded
are tracked separately and healed by a timed Hospital queue.

## March movement

```
speed_tiles_per_hour = min(non-scout unit speeds) * speed_permille / 1000
travel_ms = max(2000, Chebyshev_distance * 3_600_000 / speed_tiles_per_hour)
```

At most `1 + town_hall/4 + logistics_research` simultaneous marches. Recall cancels the
pending arrival event atomically and starts a return march. Arrival re-validates target
ownership, shield and alliance against current state; a returning army whose home was
lost routes to any still-owned city, never to an enemy city.

## Combat (version 1)

Deterministic integer resolution (`kd_domain::sim::resolve`). Inputs: aggregate armies,
attack/defense permille modifiers, hero levels, wall level, terrain defense and a seed
persisted in the report.

```
power(side) = Σ count * stat * matchup_permille * modifier * hero / 1000^3
matchup: infantry>cavalry 1250, cavalry>ranged 1250, ranged>infantry 1200,
         siege vs infantry/ranged 1150, scout 200, otherwise 1000
defender wins ties; wall adds 80 permille per level
ratio     = winner_power*1000 / loser_power
loser_loss_permille = clamp(300 + (ratio-1000)/2, 300, 950)
winner_loss_permille= clamp(100 + (ratio-1000)/8, 80, 400)
```

A seeded xorshift adds bounded ±5% jitter per unit stack; sorting stacks by (unit,tier)
before hashing makes the seed canonical. ~70% of casualties become wounded (bounded by
wounded capacity), the rest dead. Loot is at most 20% of each defender resource and is
further bounded by the survivors' carry capacity; it is debited from the defender in
the same transaction. Same inputs + seed always replay identically.

## PvP / capture

Scouting is required before attacking a city. Shielded and same-alliance targets are
rejected. Primary cities are never deleted: the defender loses eligible loot/defense
and continues in a protection state. An undefended subordinate city can be captured in
one transaction, resolving its queues, wounded and reinforcements. Forts transfer
territory and season score on a win. There is no friendly fire or shield bypass.

## Alliances / rallies

Roles leader/officer/member. Invite-then-join, kick, leadership transfer on leave, 100
member cap. Alliance help reduces an ally's queued task once per helper with a cap.
Rally members reserve real troops from their garrisons; launch builds one combined march
from those reservations, and cancel returns them to their original owners.

## Heroes / items

Six heroes with attack/defense/economy/speed bonuses that scale with level; exclusive
assignment to a city or march. Items (resource bundles, timed speedups, shields) are
earned, consumed atomically, and speedups only shorten the player's own active queues.

## Market / demolition

Every catalog item has a fixed gold price. Buying debits that price times quantity
(1..99) from the capital and credits the items; selling credits half the price per
item and removes the items from inventory. Both are atomic and emit versioned deltas.
Demolishing a building refunds half of every resource spent across its upgrade levels
(integer floor); the town hall is indestructible and only the city owner may demolish.
