# ADR-023: Western Wastes Missing Dragon Spawns (Inferred Coordinates)

**Status:** Accepted — implemented 2026-08-14
**Date:** 2026-08-14

**Extended by ADR-024**, which applies this ADR's coordinate method to seven
further zones and resolves the Sivar placeholder case deferred below.

---

## Context

Six named dragons that Project 1999 documents in Western Wastes exist in this
database as `npc_types` templates but have **never had a spawn point** — no
`spawnentry` row, no `spawn2` row, in any zone or version. They cannot appear
in game and never could.

| npc_id | NPC | level (ours / P99) |
|---|---|---|
| 120088 | Bufa | 54 / 54 |
| 120108 | Makala | 51 / 51 |
| 120111 | Mav Sapara | 60 / 60 |
| 120105 | Rak Sapara | 59 / 59 |
| 120085 | Yal | 52 / 52 |
| 120093 | Zil Sapara | 60 / 60 |

The templates themselves are correct — levels match P99 exactly, and each
carries a 31–33 item loot table (the Velious dragon-armour tiers plus
high-end spells such as `Aegolism`, `Arch Lich`, `Gift of Brilliance`). Only
placement is missing.

Found during the dormant-NPC investigation
(`docs/development/wip/NPC_RECONCILIATION_INACTIVE_INVESTIGATION.md`), which
compared P99's `Special:DynamicZoneList/Western_Wastes` roster (77 NPCs)
against our 106 spawned NPCs.

### Why this was initially judged unfixable

No conventional source documents where these NPCs spawn:

| Source | Result |
|---|---|
| P99 wiki roster | `Location = ?` for seven of eight |
| FV Project Classic Spawn List (26 Aug 2001 ShowEQ) | 96 zones, **zero Velious content** |
| EQArchives — gameznet `wwdragons`, archived 2001 | every field reads "Submit this Info!" |
| Allakhazam | quest involvement only, no coordinates |

The location data appears never to have been recorded publicly.

### What changed

Brewall's community map pack (`brewall-20240109.zip`, 1,707 files) labels
these dragons as points of interest. EQ map files store coordinates
**negated** relative to database coordinates.

The transform `db_x = -map_x, db_y = -map_y, db_z = map_z` was validated
against 295 POI labels across 9 zones by matching to live spawn points of the
same-named NPC, with three rival transforms tested alongside so a spurious
fit would be visible:

| transform | median error | within 60u |
|---|---|---|
| **negate x,y** | **7u** | **242 / 295** |
| identity | 2,087u | 0 |
| swap x/y | 1,089u | 5 |
| negate + swap | 1,584u | 2 |

Per-zone medians: skyshrine 3u (120 matches), eastwastes 7u, kael 11u,
greatdivide 13u, cobaltscar 14u, necropolis 15u, sebilis 16u, karnor 25u,
**westwastes 131u**.

## Decision

Create spawn points for the six dragons at Brewall-derived coordinates, using
the conventions already in use for this zone's solo named dragons
(`#Travala` sg16328, `#Mraaka` sg16329): `version 0`, `heading 0`,
`respawntime 21600`, `variance 0`, `pathgrid 0`, `chance 100`, and a
spawngroup roam box of `point ± dist(2500)` with `delay 20000 / mindelay 15000`.

**This is an intentional non-classic decision** in the sense that matters
here: the coordinates are inferred from a live-EQ source rather than
documented for the Velious era. It is recorded in
`docs/decisions/000_UNCLASSIC_DECISIONS.md` so a later era-accuracy pass does
not "correct" it without knowing it was deliberate.

### Excluded from this decision

- **Del Sapara (120125)** — appears only in Brewall's legend block, which
  carries no real coordinate. No source places it. Remains unspawned.
- **Sivar (120113)** — P99 states "Sivar is a Myga PH". Myga (120087) already
  spawns in rotation spawngroup 16324 alongside `#Amcilla`, `Gangel`, `Onava`
  and `Quoza` at 20% each. Sivar belongs in that rotation rather than on its
  own point, but adding a sixth member reduces the other five NPCs' spawn
  odds. That is a balance decision, not a data correction, and is deferred.

## Mechanism

`scripts/2026-08-14_westwastes_missing_dragon_spawns.sql`, generated from the
transform rather than hand-written. Inserts only:

- `spawngroup` ids 3288209–3288214
- `spawn2` ids 3266011–3266016
- six `spawnentry` rows

No existing row is modified or deleted. No schema change. Columns not listed
take their schema defaults (`cond_value 1`, `min/max_expansion -1`,
`content_flags NULL`), which is what the existing dragon rows hold.

Rollback is deleting the three explicit id ranges, recorded in the script.

## Consequences

- Six named dragon encounters become reachable for the first time on this
  server.
- No item becomes newly obtainable in a way that matters for scarcity — every
  drop checked has other reachable sources (`Matchless Dragonskin Mask` from
  4 other live NPCs, `Spell: Aegolism` from 102). This restores encounters and
  drop diversity, not unique content.
- **Spawn positions are approximate.** All six are tagged `(Raid,Roam)` on the
  map, so the POI marks a sighting rather than a spawn origin; measured
  roamer error for this zone is ~131u median against a 2500u roam box. They
  will spawn in the right region and roam, but not necessarily from the exact
  historical point.
- If a Velious-era spawn dataset ever surfaces, these six coordinates should
  be re-checked against it before being treated as settled.
- Western Wastes remains incomplete: Del Sapara is still unplaced and Sivar's
  placeholder wiring is still absent.

## Spire Compatibility

No schema change. `spawngroup`, `spawn2` and `spawnentry` are standard PEQ
tables that Spire reads and edits directly.

## Verification

Per `docs/development/TESTING.md`, after applying:

- Preflight: all six report `spawn_points = 0` before the insert.
- `spawn2` row count for `westwastes` goes from 219 to 225.
- All six appear with `zone='westwastes'`, `version=0`, `chance=100`,
  `respawntime=21600`, `variance=0`.
- Exclusion check: new `spawn2` ids reference only the new spawngroup ids;
  no pre-existing Western Wastes row is touched.
- In-game confirmation that at least one of the six spawns and is targetable.

## Implementation Status

**Applied 2026-08-14.** Executed in a single transaction with the verification
checks above gating the COMMIT.

- Backup taken first:
  `<server>\backups\angelsmisfits_full_20260814_pre_ADR023.sql`
  (full `mysqldump --single-transaction`, 295 MB, confirmed complete by its
  terminating "Dump completed" marker).
- Preflight confirmed all six had 0 spawn points and Western Wastes held 219.
- Inserted 6 `spawngroup` (3288209–3288214), 6 `spawn2` (3266011–3266016),
  and 6 `spawnentry` rows.
- Verified independently by read-only query after commit, not from the
  applying script's own reporting:

| NPC | level | spawn_id | x | y | z | respawn | chance | roam |
|---|---|---|---|---|---|---|---|---|
| Bufa | 54 | 3266011 | 1763 | -1060 | -148 | 21600 | 100 | 2500 |
| Makala | 51 | 3266012 | -3305 | -754 | 125 | 21600 | 100 | 2500 |
| Mav_Sapara | 60 | 3266013 | -1173 | -99 | -229 | 21600 | 100 | 2500 |
| Rak_Sapara | 59 | 3266014 | 1269 | 68 | -149 | 21600 | 100 | 2500 |
| #Yal | 52 | 3266015 | -3985 | -1868 | 195 | 21600 | 100 | 2500 |
| #Zil_Sapara | 60 | 3266016 | -2247 | 882 | -171 | 21600 | 100 | 2500 |

- Western Wastes spawn points: 219 → 225. No orphaned `spawn2` rows.
- Dormant NPC count: 348 → 342.
- Script moved to `scripts/Applied/`.

**Not verified in game.** The zone has not been entered since applying;
confirmation that at least one of the six spawns and is targetable remains
outstanding, as does whether the derived positions look sensible in the world
rather than merely valid in the database.
