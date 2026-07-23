# ADR 0001: Restrict Content Scope to Velious-and-Earlier

**Status:** Accepted
**Date:** 2026-07-22

## Context
The imported PEQ database is a full, current-era dump containing items,
zones, and NPCs from all EverQuest expansions through recent years, not
just launch-through-Velious. The original Phase 1 plan was "Velious as
starting point, everything unlocked," which did not anticipate the
database including post-Velious content by default.

## Decision
Content will be restricted to Velious-and-earlier (expansion values 0-2:
Classic, Kunark, Velious). Later-expansion content will not be exposed
to players by default.

## Mechanism

**Under review as of 2026-07-23.** The originally documented mechanism
(`zone.expansion <= 2`) is incomplete.

A full `rule_values` comparison identified EQEmu's bitmask-based
expansion gating rules, which operate server-wide rather than
zone-by-zone and are likely the correct primary gate:

- `World:ExpansionSettings` (PEQ: 524287, TAKP: 0)
- `World:CharacterSelectExpansionSettings` (PEQ: 522239, TAKP: 0)
- `Expansion:CurrentExpansion` (PEQ: 9, TAKP: 0)
- `World:UseClientBasedExpansionSettings` (PEQ: false)

Exact bitmask semantics have **not** been verified against EQEmu
source. No value is specified here deliberately — implementing from a
guessed bitmask would be worse than leaving this open.

`zone.expansion` filtering may still serve as a secondary/complementary
gate. Items and spells remain deferred per the original decision.

## Revision History
- 2026-07-23: Mechanism marked under review following rule_values
  comparison; bitmask gating identified as likely primary mechanism.

## Consequences
- World design and exploration scope is now bounded and matches the
  original Velious-anchor intent more precisely.
- Item/spell cleanup is deferred work, not a one-time migration.
- Future expansion (per project philosophy) means deliberately raising
  this boundary later, not an accident of an unfiltered database.