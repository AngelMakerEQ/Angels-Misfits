# ADR-010: Faction Tier Boundary Correction

**Status:** Accepted — Implemented
**Date:** 2026-07-28

---

## Context

Following a question about faction gain rates feeling off, investigation
turned to the EQEmu `Faction` rule category — the set of numeric minimums
that define where each named faction tier begins (Ally, Warmly, Kindly,
Amiable, Indifferent, Apprehensive, Dubious, Threatening). These minimums
determine when a player actually crosses into a tier that unlocks
real in-game consequences: vendor pricing, city safety, and — most
concretely — the Velious armor quests documented on P99's Significant
Factions page (Kindly for Thurgadin armor, Warmly for the Di'Zok Signet
of Service, Ally for Kael and Claws of Veeshan armor).

This is a distinct issue from the faction *hit* mechanism itself, which
was separately verified correct: a direct comparison against P99's
documented Death Fist Orcs example (killing an Orc Pawn) matched almost
exactly, both in which factions are affected and the direction of each
hit. No diminishing-returns or repeat-kill decay mechanic exists in
EQEmu's code, and no hidden global faction-rate multiplier was found —
`HateList::DoFactionHits` applies whatever values are stored in
`npc_faction_entries` directly, unscaled. The tier boundaries were the
one place a real discrepancy was found.

## Findings

Every one of EQEmu's 8 compiled default tier boundaries differed from
what P99 documents, in a consistent pattern: positive-side boundaries
were all set roughly 49-50 points higher than P99's values, and
negative-side boundaries roughly 50 points lower — both changes making
every tier harder to reach than intended.

| Tier | P99 documented minimum | EQEmu default (as found) |
|---|---|---|
| Ally | 1051 | 1100 |
| Warmly | 701 | 750 |
| Kindly | 451 | 500 |
| Amiable | 51 | 100 |
| Indifferent | -49 | 0 |
| Apprehensive | -50 | -100 |
| Dubious | -450 | -500 |
| Threatening | -700 | -750 |

P99's own wiki notes these values derive from a 2011 GM forum post,
subsequently refined by the community — not beyond-all-doubt precise,
but clearly more era-researched than EQEmu's round-number compiled
defaults, which show no sign of being classic-sourced at all.

## Decision

Adopt P99's documented values for all 8 tier boundaries in full.

## Consequences

- Every faction in the game is affected identically, since these are
  global tier-boundary rules, not per-faction data. No individual
  faction's `faction_list` or `npc_faction_entries` rows are touched.
- Players will now reach Amiable, Kindly, Warmly, and Ally roughly
  50 points sooner than before — most noticeable on the Velious armor
  quest factions, where reaching the required tier was previously
  harder than intended.
- The negative side becomes correspondingly easier to fall into
  (Apprehensive, Dubious, Threatening all trigger 50 points sooner on
  the negative side too), matching the same corrected scale.
- No other faction mechanic required correction — the underlying hit
  values and hit mechanism were already verified accurate.

## Spire Compatibility

No schema changes. All 8 values live in `rule_values`, a standard PEQ
table Spire already edits directly.

## Implementation Status

**Implemented 2026-07-28.** Applied via direct SQL against the live
Angels Misfits database (MCP connection, read-only — SQL executed by
project lead via HeidiSQL per established workflow). Verified post-run
via direct query — all 8 values confirmed matching P99's documented
minimums exactly.
