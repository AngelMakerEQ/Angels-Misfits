# ADR-007: NPC Model Correction (Classic vs. Luclin/Later Models)

**Status:** Accepted — Implemented

**Date:** 2026-07-26

---

## Context

Player character models correctly support an optional Luclin toggle
(per VELIOUS_VISION.md's Character Model Philosophy), but this same
client-side toggle affects NPC models identically, since PCs and NPCs
of the same race share one underlying `race` value and rendering path.
Turning off Luclin models client-side to keep NPCs classic-looking
would also strip the player's own optional Luclin models — an
unacceptable tradeoff. This ADR investigates what can be corrected at
the database level instead, without touching player choice.

## Key Finding: Two Different Situations

Investigation established that "Luclin NPC models" is not one uniform
problem:

1. **Monster-type races with genuinely separate, coexisting race IDs**
   for old vs. new models (e.g., Skeleton: race 60 vs. race 367). These
   are real, independent `npc_types.race` values — fixable at the
   database level with zero effect on player characters, since players
   never use these race IDs.
2. **The 12 original humanoid player races** (Human, Barbarian,
   Erudite, the elf races, Dwarf, Troll, Ogre, Halfling, Gnome).
   NPCs and PCs of these races share the *identical* race ID, and
   which model renders is determined entirely by client-side file
   loading (`GlobalLoad.txt`) or the in-game model toggle — not by
   any database field. EQEmu documentation confirms Luclin-era model
   files for these races are only loaded when Luclin models are
   enabled. **This is not correctable via the database.** The only
   known method (per community sources) is a client executable
   modification, as Project 1999 uses — out of scope here.

Verified empirically (PEQ vs. TAKP race-value comparison, the same
method used throughout ADR-003) that wolves, orcs, gnolls, spiders,
bears, and snakes show **zero** race disagreement between the two
databases — consistent with these also falling into the
client-controlled category, not the database-fixable one. No changes
were made for these.

## Decision

Correct the skeleton-family model split at the database level. Do not
attempt humanoid race separation; not achievable without client
modification, which is out of scope.

## Historical Correction

Race 60 is commonly assumed to be "the classic skeleton," but
community sources indicate the true original 1999 skeleton model was
retired at the Luclin patch and is not restorable without illegal
client file modification. Race 60 is actually the **Luclin-era**
skeleton — it became the best *available* classic-style approximation
once LDoN introduced an even newer model (367). This is a correction
to the historical framing only; the practical decision (60 is the
right target) is unchanged from ADR-003.

## Scope and Categorization

`npc_types.race` was corrected in three steps:

1. **`race 367 → 60`** (1,365 NPCs). Applied unconditionally — the
   newer "global6" skeleton model corrected to the Luclin-era
   approximation, regardless of NPC name.
2. **`race 161 → 60`**, name-scoped (265 of 454 NPCs at race 161).
   Race 161 ("Undead Iksar") had been used inconsistently: some NPCs
   are generic zone-flavor skeleton variants (the "-bone" family —
   plaguebone, scalebone, charbone, icebone, spurbone, hexbone,
   war-boned, elementalbone — plus generic `skeletal_*` role names),
   which were corrected to 60. Others are genuine Iksar-identity
   NPCs and were deliberately **excluded** from conversion:
   - The Sythrax cult (Field of Bone, confirmed classic Kunark
     content via P99 wiki — a genuine undead-Iksar temple, not
     generic skeletons)
   - Xalgoz's minions (a named Kunark boss)
   - `an_ancient_Jarsath` (one of the five historic Iksar tribes,
     confirmed via P99 wiki's own quest description)
   - Explicit Iksar-identity names (`fallen_Iksar`, `iksar_slave`,
     `undying_iksar`, etc.)
   - The "Soriz" family (thematically consistent plague-lore set)
   - Named unique nobility (`Baron_Yosig`, `Arch_Duke_Iatol`,
     `Hierophant_Prime_Grekal`, and similar titled individuals)
   - A lower-confidence group (`decayed_soldier`, `decayed_prisoner`,
     `forlorn/forgotten_slave`, `undead_slave` — 23 NPCs) with no
     explicit Iksar marker in the name, kept at 161 as a judgment
     call given thematic proximity to the confirmed Iksar-slave
     entries, not a verified fact.
   - All `#`-prefixed special/GM NPCs, matching the established
     exclusion convention from ADR-003.
3. **`race 606 → 161`** (4 NPCs). Race 606 was a mismatched model;
   161 (Undead Iksar) is the correct final identity for these
   specific NPCs — not an intermediate step toward 60. Order-
   dependent: this statement must run after statement 2, otherwise
   these 4 newly-converted NPCs would be incorrectly swept into the
   161→60 conversion.

## Consequences

- 1,630 NPCs total received a corrected, classic-appropriate model
  (1,365 + 265), with zero effect on stats, damage, or any other
  mechanic — pure visual correction.
- 193 NPCs remain at race 161 deliberately, preserving genuine
  Iksar-identity content.
- Humanoid NPC/PC model separation remains unresolved and is not
  expected to be resolved without a client-side modification project,
  which is a substantially different scope of work than anything
  else in this project's history.

## Verification

Post-run, verified via direct query against the live database:
- Zero remaining rows at race 367 or 606 (complete conversion).
- Current race 161 count: 193, exactly matching 189 (preserved) + 4
  (newly converted from 606).
- 21 NPCs cross-referenced by ID (not name, to avoid ambiguity from
  shared names across race-value variants) against the pre-migration
  snapshot — all confirmed still at race 161, zero over-conversion.
- 5 sampled "convert" names checked for leftover race-161 rows — zero
  found, confirming complete conversion for the targeted set.

## Spire Compatibility

No schema changes. `npc_types.race` is a standard PEQ column Spire
already edits directly.

## Implementation Status

**Implemented 2026-07-26.** Applied via direct SQL against the live
Angels Misfits database (MCP connection). Verified clean as detailed
above.
