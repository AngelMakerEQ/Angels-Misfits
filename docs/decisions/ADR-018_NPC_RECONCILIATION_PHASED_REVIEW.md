# ADR-018: NPC Reconciliation Phased Review

**Status:** Superseded (2026-08-10) — see note below. Retained as the
historical decision record for Phase 1's already-applied database changes;
the forward-looking process it describes (manual seven-zone phase batches,
zone selection logic, Phase 2 Queue) is no longer the active methodology.

**Date:** 2026-08-06

---

**Superseded 2026-08-10.** This ADR's manual, wiki-page-at-a-time zone-sweep
process has been replaced by a structured, queryable tool: a parsed P99 wiki
reference table (`p99_reference_npcs`) plus live-database comparison views
(`npc_reconciliation_match`/`npc_reconciliation_diff`) that surface
discrepancies directly via SQL instead of requiring a fresh manual wiki read
per zone. The current, sole working process lives in
`docs/development/wip/NPC_RECONCILIATION_REMAINING_ZONE_ROADMAP.md` — that
document is authoritative for how this work is done going forward; the
Zone Selection Logic, Phase 1 zone list, and Phase 2 Queue sections below
are preserved only as a record of what Phase 1 actually covered and why,
not as active instructions. Phase 1's own findings and applied migration
(`scripts/Applied/2026-08-06_npc_reconciliation_phase_1_APPLIED.sql`)
remain valid and unaffected by this supersession — only the *process* for
future work has changed, not anything already decided or applied.

**Relationship to ADR-003 (added 2026-08-12):** this reconciliation work
(both this ADR's original Phase 1 and its successor process) individually
re-verifies and overrides ADR-003's bulk arithmetic-midpoint `aggroradius`
values against the primary source (P99's wiki) on a per-NPC basis. Neither
ADR previously cross-referenced the other despite ADR-003's values now
being routinely superseded NPC-by-NPC — see
`docs/decisions/000_UNCLASSIC_DECISIONS.md`'s "NPC combat tuning" entry for
the current count of NPCs affected.

---

## Context

The PEQ-derived database contains useful all-era data, but broad tuning and
later-era additions can diverge from classic behavior. NPC reconciliation
therefore needs field-specific source evidence rather than another broad
normalization pass. P99 is the primary authority for classic values; the FV
Project 2001 ShowEQ spawn list and the classic-resource MCP fill gaps such as
coordinates only when P99 does not provide the field.

The task covers active NPC templates, spawn positions, behavior where runtime
semantics are understood, and loot. It also discovers later-era NPCs and gates
them with the native `content_flags` mechanism, following ADR-016. It does not
delete PEQ data and does not change the database schema.

## Decision

Reconcile the active Classic, Kunark, and Velious population in bounded,
repeatable seven-zone phases. A phase produces one HeidiSQL-ready migration
after its findings are validated; sources, unresolved questions, and SQL
targets remain in the reconciliation ledger.

`NULL` version values in this imported database are treated as legacy version
0 during selection (`COALESCE(version, 0) = 0`). Later revamps are excluded.
Only zone eras 0 through 2 are reviewed. A later-era NPC found in those zones
is precisely gated at `spawnentry` so a shared spawngroup's classic members
remain available.

## Zone Selection Logic

Each phase has the same number of zones and applies these priorities in order:

1. Active version-0, eras 0-2 consumers only.
2. Low and mid-level ordinary populations before 50+ content. A high-level
   event, guard, Fabled replacement, or other exception does not promote a
   zone into the 50+ priority band by itself.
3. Geographic or encounter continuity from recently reviewed zones, so the
   same P99/FV source batches and NPC families can be reused efficiently.
4. Higher active-spawn population and clear P99/FV coverage before sparse or
   poorly documented zones.
5. At every pass, inspect discovered loot and clearly post-era NPCs; defer
   ambiguous loot rates, special abilities, and mismatched same-name templates
   rather than guessing.

## Phase 1

The initial seven-zone pass was selected under this rule, beginning with the
explicitly requested Kurn's Tower and Oasis of Marr, then following the
low-level Blackburrow/Crushbone/Faydark/Mistmoore progression:

1. Kurn's Tower
2. Oasis of Marr
3. Blackburrow
4. Crushbone
5. Greater Faydark
6. Lesser Faydark
7. Castle Mistmoore

Earlier source-confirmed findings in Lower Guk, Emerald Jungle, Crystal
Caverns, Plane of Hate, Veeshan's Peak, and Temple of Veeshan are included in
the same migration because they were independently validated before this
phase was closed. Same-name Veeshan template 108500 was deliberately excluded:
P99 identifies template 108037, so transferring those values would be unsafe.

Migration: `scripts/2026-08-06_npc_reconciliation_phase_1.sql`.

The migration gates 27 active Fabled `spawnentry` rows and eight individually
evidenced post-era/event rows. It does not repeat ADR-016's already-applied
global loot flags.

## Phase 2 Queue

Phase 2 retains the seven-zone batch size and uses the same version, level,
continuity, population, and source-coverage logic. These are unreviewed,
low/mid-level next steps connected to the Faydark and Old World progression:

1. Butcherblock Mountains
2. Steamfont Mountains
3. The Estate of Unrest
4. Befallen
5. The Nektulos Forest
6. West Commonlands
7. East Commonlands

All seven still require a normal source pass; this queue is an execution order,
not a pre-approval of any data change.

## Consequences

- P99-backed values supersede prior broad tuning on a field-by-field basis.
- The resulting SQL is guarded by observed old values and ends in `COMMIT;` so
  it can be run as a single HeidiSQL transaction after backup and review.
- Content flags preserve future-era content for future activation without
  retaining it in the active Velious population.
- Phase boundaries keep the review auditable and prevent 50+ zones from
  consuming the early reconciliation effort.
