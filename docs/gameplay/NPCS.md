# NPCs

## Current State

NPC combat behavior and appearance have both undergone significant, database-level correction from the original PEQ import.

## Combat Stats

NPCs in Classic/Kunark/Velious zones (~12,574 affected) hit harder, have more HP and AC, regenerate HP far faster, and resist magic/fire/cold/disease/poison significantly better than stock PEQ defaults. Aggro radius is moderately wider than PEQ (not as wide as the TAKP-claimed comparison database's full values, to preserve Very Vanilla MQ multibox viability). Net effect: encounters are meaningfully tougher and more resistant to CC/DoTs than a stock PEQ server.

Full detail and per-stat ratios: **ADR-003**.

## Pets

Summoned pets (mage/necro/druid/shaman, levels 1-50, 140 of 423 templates affected) hit softer and self-heal more slowly than stock PEQ, but resist magic and fire better and move faster. This is a genuine difficulty tradeoff, not a straightforward buff or nerf — pets are less leanable-on as a sustained tank/DPS slot than before.

Full detail: **ADR-005**.

## Models

Skeleton-family NPCs (1,630 total) have been corrected to classic-style models at the database level (`npc_types.race`). Genuine Iksar-identity NPCs (Sythrax cult, named nobility, etc.) were deliberately excluded and remain on their original race value.

**Known limitation:** NPCs sharing one of the 12 true playable race IDs (e.g., Human/Elf/Dwarf guards) cannot have their model era (classic vs. Luclin) set independently from player characters of that race — this is a client-side engine limitation, not fixable via database or file changes while the NPC keeps its original race ID. Currently, since Luclin models are disabled project-wide, this means all such NPCs render classic by default.

Full detail: **ADR-007**, **ADR-008**.

## Not Yet Addressed

- Loot tables, spawn timers, and NPC placement have not been reviewed or changed — only combat stats and models have been touched to date.
- Item/spell-level expansion scoping (affects what NPCs can drop/cast) remains deferred per ADR-001.
