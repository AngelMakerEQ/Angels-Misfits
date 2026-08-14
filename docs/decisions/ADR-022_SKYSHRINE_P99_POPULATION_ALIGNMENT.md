# ADR-022: Skyshrine Population Alignment (Zone Version Swap)

**Status:** Accepted — implemented 2026-08-13
**Date:** 2026-08-13

---

## Context

`skyshrine` carries two populations in `spawn2`:

| version | spawn points | distinct NPCs | reachable? |
|---|---|---|---|
| 0 | 470 | 428 | yes — `zone` has a version 0 row |
| 1 | 228 | 190 | **no** — `zone` has no version 1 row |

The version 1 population has never been reachable in game. Any spawn point
on a zone version the `zone` table does not define simply never loads, so
those 190 NPCs cannot appear.

This was found while investigating why 481 wiki-documented NPCs were dormant
(no active spawn). Most dormant cases resolved to documented later-expansion
revamps — `sirens`, `citymist`, `droga`, `nurga` (LDON, 2003), `lavastorm`
(Dragons of Norrath), `nektulos` (DoDH), `paw` (2005 Splitpaw revamp) — each
of which the `zone` table records as a second version with a dated note.
Skyshrine had no such row and no such explanation.

### Which population is era-correct

Project 1999 revamped their Skyshrine in October 2002 to make it more
classic-accurate, so P99's zone is a curated set rather than a copy of any
single EQ Live state. Their roster was fetched from the live wiki
(`Special:DynamicZoneList/Skyshrine`, 201 NPCs with race/class/level) and
compared against both of our populations by normalised name:

| | in P99 roster | not in P99 roster |
|---|---|---|
| **version 0** (currently active) | 72 | **356** |
| **version 1** (currently dormant) | **185** | 5 |

Version 1 matches P99's Skyshrine at 97%. Version 0 is 83% content P99 does
not have — the `Elder`/`Elite` drake tier (levels 58–62), `A_Shrine_Protector`,
`A_Shrine_Defender`, `An_Old_Racnar` and similar.

**All 201 P99 roster NPCs already exist in our database.** Nothing is missing;
the correct population is simply on the version that never loads.

Two weaker signals were tested and explicitly rejected as inconclusive, to
record that they were considered:

- **Level distribution.** P99's zone page states monsters are level 35–60.
  Version 0 is 79% inside that band, version 1 is 71% — no discrimination.
- **Coordinates.** Both versions occupy the same bounding box
  (x[-1212,2461] vs x[-1184,2461]), confirming an interior/population swap on
  shared geometry rather than a spatial split, but saying nothing about which
  population is correct.

The roster comparison is the only decisive evidence and is what this decision
rests on.

## Decision

Align Skyshrine so that **version 0 holds the P99 population** and version 1
holds the remaining EQ Live content, per spawn point:

| move | spawn points |
|---|---|
| version 0 → 1 (non-roster content, currently live) | 408 |
| version 1 → 0 (roster content, currently unreachable) | 223 |
| stay 0 (roster content, already live) | 58 |
| stay 1 (non-roster, already dormant) | 5 |
| untouched — spawn points with no `spawnentry` rows | 4 |

**No `zone` row is added for version 1.** Its unreachability is the mechanism
that keeps non-P99 content out of the game; adding the row would make that
content spawnable, which is the opposite of the intent.

Assignment is by spawn point, not by NPC, because `spawn2.version` is a
property of the spawn point. Every spawngroup in the zone is wholly inside or
wholly outside the roster (zero mixed groups), so no spawngroup restructuring
is required. The 14 spawngroups containing two level-variants of the same NPC
(e.g. `Liason_Dolvak` at 38 and 39) stay intact — roster membership is by
name, and both variants match.

## Mechanism

`scripts/2026-08-13_skyshrine_p99_population_alignment.sql`, generated from
the roster comparison rather than hand-written. Only `spawn2.version` changes.
No rows are inserted or deleted, no `npc_types`, `spawnentry`, `spawngroup`,
or `loottable` data is touched, and no schema changes are made.

Rollback is the inverse version assignment over the same two explicit
`spawn2.id` lists, which the script records.

## Consequences

- Skyshrine's live population changes from 428 NPCs to 201 — the zone becomes
  what P99 runs, which is smaller and lacks the Elder/Elite drake tier.
- 185 previously unreachable NPCs become spawnable, including the roster's
  named content.
- Existing character progress, faction, and loot tables are unaffected;
  only which spawn points load changes.
- The non-P99 population is retained in place on version 1 rather than
  deleted, consistent with ADR-001's precedent of gating rather than removing
  data. It can be restored by reversing the version assignment.
- **This is one zone.** `sirens`, `citymist`, `lavastorm`, `nektulos`, `paw`,
  `droga`, and `nurga` also carry version pairs. Their version 1 rows are
  documented later-expansion revamps and are believed correctly dormant, but
  none has been checked against a P99 roster the way Skyshrine has. That
  comparison is deliberately out of scope here.

## Spire Compatibility

No schema change. `spawn2.version` is a standard PEQ column that Spire reads
and edits directly.

## Verification

Per `docs/development/TESTING.md`, after applying:

- version 0 spawn point count is **285** (58 kept + 223 moved + the 4
  entry-less points, which are themselves on version 0); version 1 is 413
  (408 + 5).
- **No NPC name outside the P99 roster remains on version 0.** This is the
  assertion that matters, not a raw ID count: distinct `npc_types` IDs on
  version 0 (258) exceed the roster's 201 entries because level variants
  share one name and one wiki page. Distinct *names* on version 0 is 202
  (202 rather than 201 because the roster itself contains case-variant
  duplicates such as `A Crystal Spider` / `A crystal spider`).
- The 5 known non-roster NPCs remain on version 1
  (`Sentry_Dumtew`, `Sentry_Trid`, `Guardian_Dojma`, `Guardian_Rarejy`,
  `Larquin_Fe`Dhar`).
- Exclusion check: no `spawn2` row outside `zone = 'skyshrine'` was modified,
  and total skyshrine spawn point count is unchanged at 698.
- In-game confirmation that the zone populates and that a roster NPC absent
  before the change now spawns.

## Implementation Status

**Applied 2026-08-13.** Executed against the live database inside a single
transaction, with the verification checks above run before COMMIT.

- Backup taken first:
  `<server>\backups\angelsmisfits_full_20260813_pre_ADR022.sql` (full
  `mysqldump --single-transaction`, 295 MB, confirmed complete by its
  terminating "Dump completed" marker and by containing the `spawn2` schema).
- Rows updated: 223 spawn points to version 0, 408 to version 1 — matching
  the generated id lists exactly.
- Post-apply state confirmed by an independent read-only query (not the
  applying script's own reporting): version 0 = 285 spawn points / 202
  distinct names, version 1 = 413 / 172, total 698 unchanged. Zero
  off-roster names remain on version 0. All five known non-roster NPCs
  remain gated on version 1.
- Spot-checked previously unreachable roster NPCs now live on version 0:
  `a_shambling_cube` (21 spawn points, levels 43-54), `a_crystal_spider`
  (16, levels 23-26), `a_gargoyle_guard` (14, level 38), `Lord_Yelinak`
  (2, level 70), `Ziglark_Whisperwing` (2, levels 27 and 40).
- Script moved to `scripts/Applied/`.

**Two verification expectations in the original draft were wrong and were
corrected before applying** (the dry run failed on both and rolled back,
which is why they were caught):

1. Spawn points on version 0 stated as 281; the correct figure is 285,
   because the 4 entry-less spawn points already sit on version 0.
2. "Distinct NPCs on version 0 is 201" compared a distinct-`npcID` count
   against a roster of names. Level variants break that comparison. The check
   was replaced with "no off-roster name remains on version 0".

**Not verified in game.** The zone has not been entered since applying;
confirmation that it populates correctly is still outstanding.

### Correction applied 2026-08-14 — duplicate placements

**The original migration had a defect, found the same day and corrected.**

The decision above selected spawn points by whether their occupants' *names*
appear in P99's roster. Name membership does not identify which *arrangement*
a spawn point belongs to — and a zone revamp can reuse the same mobs at
different placements within the same zone. Consequently 29 spawn points
carrying P99-named mobs at revamp-era positions were kept on version 0
alongside the P99 placements of those same mobs.

The result was 29 duplicated NPCs, including:

| NPC | placement A | placement B |
|---|---|---|
| Lord_Yelinak | (1977, 2645) | (1977, 2645) — *identical, two spawns stacked* |
| Commander_Leuz | (-852, 199) | (-286, 286) |
| Ziglark_Whisperwing | (-547, 830) | (-696, 180) |
| Sentry_Kale | (-436, 829) | (-457, 194) |

**Fix:** move to version 1 exactly those kept points whose every occupant is
already placed by the P99 arrangement — 29 points. Points carrying NPCs the
P99 arrangement does *not* place stay on version 0: **27 NPCs** (barkeeps,
chefs, counts, patrollers, Liason_Dolvak, Yeinn_Kor`Va and others) exist only
in the old arrangement, so a full version swap would have lost them. That is
why the correct fix is neither the original per-name filter nor a clean
version swap.

Post-correction state, verified independently by read-only query:

- version 0: 285 → **256** spawn points; version 1: 413 → **442**; total 698
  unchanged.
- Distinct NPC names on version 0: **202, unchanged** — no P99 content lost.
- NPCs placed by both arrangements: **0**.
- Named uniques confirmed single-pointed at their P99 placement
  (Lord_Yelinak, Ziglark_Whisperwing, Commander_Leuz, Sentry_Kale).

A first version of the verification query flagged 9 remaining "duplicates";
those were generic mobs legitimately holding many points within one
arrangement (`a_shambling_cube` ×21, `a_gargoyle_guard` ×14). The check was
corrected to test for NPCs placed by *both* arrangements, which is the actual
defect condition.

**Method lesson for future zone alignments:** filter spawn points by which
arrangement they belong to, not by whether their occupants' names appear in a
roster. A revamp that reuses mobs at new positions will otherwise produce
duplicates that a name-based check cannot see.

Backup taken before the correction:
`<server>\backups\angelsmisfits_full_20260814_pre_ADR022fix.sql`.

**Follow-on observed, not addressed here:** some now-live roster NPCs sit
slightly outside the levels P99 documents (`a_crystal_spider` live at 23-26
vs the roster's 27-31; `a_shambling_cube` at 43-54 vs 44-49). Those are stat
discrepancies belonging to the NPC reconciliation workstream, not to spawn
placement, and this ADR deliberately did not adjust them.
