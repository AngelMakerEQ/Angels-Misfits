# ADR-024: Orphaned NPC Spawn Restoration (Multi-Zone) and Sivar Placeholder Wiring

**Status:** Accepted — implemented 2026-08-14
**Date:** 2026-08-14

**Extends:** ADR-023, which established the precedent and the coordinate
method for a single zone. This ADR applies the same method across seven
further zones and resolves one case ADR-023 explicitly deferred. It is a
separate record rather than an edit to ADR-023 because that document's scope
is Western Wastes; folding unrelated zones into it would make its title wrong
for any future reader.

---

## Context

The dormant-NPC investigation
(`docs/development/wip/NPC_RECONCILIATION_INACTIVE_INVESTIGATION.md`)
identified P99-documented NPCs that exist as `npc_types` templates but have
never had a spawn point in any zone or version. After filtering out those that
are quest-spawned, live under a different id, or sit in out-of-scope zones,
56 candidates remained.

Sweeping those against Brewall map POI data using ADR-023's validated
transform yielded **8 with usable coordinates** and 48 without.

### Two false-positive classes found and eliminated

The first sweep reported 14 matches. Six were wrong, and both causes are worth
recording because either would have written bad data:

1. **Legend blocks.** 340 of Brewall's zone files stack many POIs at one fixed
   x value as a map key. These are not locations. Del Sapara "matched" at
   `(100, -7400)` purely from such a block. Any POI whose x is shared by 8 or
   more POIs in the same file is now discarded.
2. **Cross-zone name collisions.** Searching all 575 zone maps by name alone
   matched Sivar (Western Wastes) to a `sleepertwo` POI. A match is now only
   accepted when the map file corresponds to the NPC's own documented zone.

After tightening, Sivar resolved to the same Western Wastes coordinate derived
independently during ADR-023 — a useful check that the corrected logic agrees
with a known-good result.

### Placement validation

Every derived coordinate was checked to fall inside its zone's existing spawn
bounds, and measured against the nearest existing spawn. Several land beside
thematically matching neighbours, which corroborates the derivation rather
than merely showing it is in-bounds:

| NPC | zone | nearest existing spawn | distance |
|---|---|---|---|
| Clockwork XXIIB | akanon | Kimble_Nogflop | 5u |
| Master Yael | hole | a_fallen_adventurer | 40u |
| Dark Assassin | everfrost | a_snow_leopard | 51u |
| Solvedi Aldeberan | rathemtn | Albain_Tinderbrand | 94u |
| an abstruse phantasm | growthplane | a_phase_puma | 170u |
| #elder spearguard | iceclad | **Snowfang_spearguard** | 173u |
| #Coldain War Wolf | greatdivide | **a_coldain_tracking_wolf** | 308u |

An elder spearguard landing beside a Snowfang spearguard, and a Coldain war
wolf beside a Coldain tracking wolf, is not what a mis-derived coordinate
looks like.

## Decision

**Part A — create spawn points for seven orphaned NPCs** at Brewall-derived
coordinates, one per zone:

| npc_id | NPC | zone | x, y, z |
|---|---|---|---|
| 55038 | Clockwork_XXIIB | akanon | -796, 1330, -64 |
| 47172 | Dark_Assassin | everfrost | -5546, -989, 169 |
| 118103 | #Coldain_War_Wolf | greatdivide | -399, -1507, 170 |
| 127101 | an_abstruse_phantasm | growthplane | -2569, 1684, 259 |
| 39138 | Master_Yael | hole | 260, 720, 0 |
| 110106 | #elder_spearguard | iceclad | 2252, 1235, 48 |
| 50333 | Solvedi_Aldeberan | rathemtn | 1724, 5098, 125 |

`respawntime`, `variance`, `pathgrid` and roam `dist` are copied **per NPC
from its nearest existing neighbour**, not assumed uniform across seven
zones — hence `an_abstruse_phantasm` at 86400/17280 (Plane of Growth
convention), Solvedi at 600, `#Coldain_War_Wolf` with a 400u roam box, and the
rest at 640.

**Part B — wire Sivar (120113) as a placeholder pop**, resolving the case
ADR-023 deferred. P99 states "Sivar is a Myga PH". Myga (120087) already
spawns in rotation spawngroup 16324 with `#Amcilla`, `Onava`, `Gangel` and
`Quoza` at chance 20 each. Sivar joins that group at chance 20 rather than
receiving its own spawn point.

**This is a deliberate balance change:** the existing five members drop from
20% to ~16.7% spawn share. That cost was accepted because P99 documents Sivar
as a placeholder pop, so creating a separate fixed spawn would misrepresent
the mechanic more seriously than diluting a rotation does.

## Mechanism

`scripts/Applied/2026-08-14_orphan_npc_spawns_and_sivar_APPLIED.sql`,
generated from the sweep rather than hand-written. Inserts only:

- `spawngroup` ids 3288215–3288221
- `spawn2` ids 3266017–3266023
- seven `spawnentry` rows, plus one row adding Sivar to spawngroup 16324

No existing row is modified or deleted; no schema change. Columns not listed
take schema defaults (`cond_value 1`, `min/max_expansion -1`,
`content_flags NULL`).

## Consequences

- Eight P99-documented NPCs become reachable across eight zones.
- The five NPCs sharing Myga's rotation each lose ~3.3 percentage points of
  spawn share.
- **Coordinates are inferred from a live-EQ source**, same provenance caveat
  as ADR-023. Recorded in `docs/decisions/000_UNCLASSIC_DECISIONS.md`.
- 48 orphan candidates remain without usable coordinates. They are
  overwhelmingly city and indoor NPCs (Grobb, Kaladim, Neriak, Qeynos
  Aqueducts, Erudin, Cabilis, Rivervale, Kael) plus Plane of Mischief's
  event-spawned set. Brewall labels raid mobs and landmarks, not individual
  city NPCs, so this source is unlikely to resolve them and a different one
  would be needed.

## Spire Compatibility

No schema change. `spawngroup`, `spawn2` and `spawnentry` are standard PEQ
tables Spire reads and edits directly.

## Verification

Applied in a single transaction with checks gating the COMMIT; a full
`mysqldump` backup (`angelsmisfits_full_20260814_pre_orphans.sql`) was taken
first and confirmed complete.

- Preflight: all 8 reported 0 spawn points; Myga's rotation held exactly 5.
- 7 spawn rows created across 7 distinct zones, all `version 0`, `chance 100`.
- Myga rotation went 5 → 6 members with Sivar present at chance 20.
- 0 of the 8 remain unspawned.
- Confirmed post-commit by an independent read-only query, not from the
  applying script's own reporting.
- Dormant NPC count: 342 → 333.

**Not verified in game.** No zone has been entered since applying. For
inferred coordinates the open question is not only whether an NPC spawns but
whether it spawns somewhere sensible — a point inside world geometry would
only be visible by walking to it.

### Post-application review 2026-08-14 — arrangement and collision audit

Prompted by the ADR-022 correction (a zone revamp can reuse the same mobs at
different placements, which a name-based filter cannot detect), all 14 NPCs
added under ADR-023 and ADR-024 were re-checked.

**Duplicate placement: none.** Every one of the 14 holds exactly one spawn
point.

**Alternate arrangements: none exist.** All seven ADR-024 zones — `akanon`,
`everfrost`, `greatdivide`, `growthplane`, `hole`, `iceclad`, `rathemtn` —
carry only `spawn2.version = 0` and a single `zone` row, as does
`westwastes`. The ADR-022 failure mode is structurally impossible in them.

**Collision audit:** nearest-existing-spawn distance was measured for each new
point. Twelve of thirteen sit 40–334u from their nearest neighbour, which is
normal spacing. One did not.

### Clockwork_XXIIB (55038) — placement reverted

Its derived point (-796, 1330) fell **5 units** from `Kimble_Nogflop`'s
existing solo spawn at (-795, 1335) — effectively stacked. P99's Ak'Anon
roster resolves why:

| NPC | P99 location |
|---|---|
| Clockwork XXIIB | **`?`** |
| Kimble Nogflop | `(1335, -795)` — note P99 writes (y, x) |

The Brewall POI labelled "Clockwork XXIIB" is sitting on *Kimble's* spot. Two
readings are possible — Brewall mislabelled it, or the two share a spawn point
as a placeholder pair — and nothing available distinguishes them: Kimble is a
solo `spawnentry` at chance 100, and P99 documents no relationship.

Adding Clockwork XXIIB to Kimble's group would have asserted an undocumented
placeholder mechanic and changed Kimble's spawn rate on a guess. That is
weaker evidence than the Sivar case, where P99 states "Sivar is a Myga PH"
outright.

**Reverted** — `spawnentry`, `spawn2` id 3266017 and `spawngroup` id 3288215
deleted; Clockwork_XXIIB returns to unspawned. This matches the treatment of
Del Sapara under ADR-023: insufficient evidence for placement means the NPC
stays unplaced rather than being placed speculatively.

Verified: Clockwork_XXIIB now holds 0 spawn points, Kimble_Nogflop untouched
at 1, `akanon` back to 255 points.

**ADR-024 therefore restores 7 NPCs, not 8** (six ADR-023 dragons plus these
seven, minus Clockwork_XXIIB, plus Sivar's rotation wiring).
