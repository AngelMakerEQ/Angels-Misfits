# ADR-025: Faction Reconciliation (Classic/Kunark/Velious)

**Status:** Accepted — In Progress
**Date:** 2026-08-16

---

## Context

ADR-010 corrected the 8 global faction tier boundaries, and the hit
mechanism itself was verified correct (`HateList::DoFactionHits` applies
`npc_faction_entries` values directly, unscaled). But the underlying
per-NPC faction data — which factions each NPC is affiliated with, what
faction hits fire when an NPC is killed, and what players' starting
faction standings are — has never been reconciled against the primary
source (P99 wiki).

PROJECT_STATUS.md lists two related open items:
- "Broader faction system verification beyond tier boundaries (2,105
  factions total) — ongoing background item"
- "Faction kill/quest increment verification" as a standing research gap

The PEQ-imported data may carry later-era faction assignments, incorrect
hit values, missing factions, or wrong starting standings — the same
class of drift that stats (ADR-003/018), loot (ADR-017), and spells
(ADR-019/020) have already been corrected for.

## Decision

Reconcile all Classic/Kunark/Velious faction data against the P99 wiki,
using the same structured, queryable methodology established for the NPC
stat reconciliation (superseding ADR-018's manual zone-sweep approach):

1. **Parse** faction hit data from the existing P99 wiki cache
   (`p99_reference_npcs` and individual faction pages).
2. **Compare** against live database tables (`npc_faction_entries`,
   `npc_types.npc_faction_id`, `faction_list`, `faction_list_mod`).
3. **Stage** corrections in dedicated staging tables for review before
   any live database change.
4. **Apply** via versioned, committed SQL migrations after validation.

### Scope

- NPC faction affiliations (`npc_types.npc_faction_id`)
- Per-NPC faction hits on kill (`npc_faction_entries`)
- Faction list completeness (`faction_list`)
- Starting faction standings by race/class/deity (`faction_list_mod`)
- Active version-0, expansion 0-2 content only (same scope as ADR-018)

### Out of scope

- Faction tier boundary values (already corrected by ADR-010)
- The hit mechanism itself (already verified correct)
- Quest-granted faction changes (quest script review, not database)
- Factions exclusive to post-Velious content

## Consequences

- Killing an NPC will produce the correct classic-era faction hits
  rather than PEQ's all-era defaults.
- NPC faction affiliations will match P99's documented assignments,
  affecting con color, aggro behavior, and assist chains.
- Starting faction standings will match classic race/class/deity
  combinations, affecting which cities are safe at character creation.
- No schema changes — all corrections target existing PEQ-standard
  tables.

## Spire Compatibility

No schema changes. All affected tables (`npc_types`, `npc_faction`,
`npc_faction_entries`, `faction_list`, `faction_list_mod`) are standard
PEQ tables Spire already manages.

## Implementation Status

**In progress.** Infrastructure (roadmap, staging tables, comparison
views, wiki parser) committed 2026-08-16. Data collection and
reconciliation phases pending.
