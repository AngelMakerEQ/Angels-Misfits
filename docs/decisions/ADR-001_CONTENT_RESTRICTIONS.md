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
- Zones: gated via `zone.expansion <= 2`.
- Items/spells: no reliable single-column gate exists in PEQ; these will
  be scoped incrementally as zones are built out, cross-referenced
  against allowed zones and loot tables rather than filtered globally
  up front.

## Consequences
- World design and exploration scope is now bounded and matches the
  original Velious-anchor intent more precisely.
- Item/spell cleanup is deferred work, not a one-time migration.
- Future expansion (per project philosophy) means deliberately raising
  this boundary later, not an accident of an unfiltered database.