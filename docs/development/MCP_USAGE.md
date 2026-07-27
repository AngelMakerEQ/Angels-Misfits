# MCP Usage

## What This Is

EQEmu MCP is the external development interface used to inspect and directly interact with the live Angels Misfits database and server environment. It is connected and in active use — this is not a hypothetical/future capability, it has been the primary mechanism for every database change made to date.

## How It's Used

MCP is used to:
- Query the live database directly to verify actual state before making assumptions (row counts, current values, table contents).
- Apply migrations (SQL) directly against the live database rather than working from a static offline copy.
- Verify changes post-implementation by querying the affected rows/tables directly.

Per project philosophy, MCP should be used to check actual server/database state before assuming implementation, configuration, or data details — not just for making changes.

## What's Been Accomplished With It

Every database-level ADR to date was implemented via direct MCP connection:

- **ADR-001** — Applied and verified all four content-scope gating rules (`World:ExpansionSettings`, `Expansion:CurrentExpansion`, `World:CharacterSelectExpansionSettings`, `World:UseClientBasedExpansionSettings`) directly against the live database.
- **ADR-002** — Applied 17 changed server rules via migration script; verified all 17 post-run.
- **ADR-003** — Applied NPC combat stat changes across ~12,574 NPCs (HP, damage, AC, resists, regen, aggro radius); verified via direct query sampling (12 NPCs checked, 4 initial + 8 random).
- **ADR-004** — Applied the full spell mechanics replacement (37,729 spells, 144,666 field changes) in a single migration run (15.654 seconds, 0 warnings); verified via 10 sampled spells including exact text-field matches.
- **ADR-005** — Applied pet NPC stat tuning across 140 templates; verified via 7 sampled templates.
- **ADR-006** — Applied starting item corrections (2 rows removed); verified via direct query confirming zero remaining rows at the removed IDs.
- **ADR-007** — Applied NPC race/model corrections (1,630 NPCs across three sequential SQL statements); verified via zero-remaining-row checks, cross-referenced ID sampling, and targeted name checks.

## Current Status

MCP access is intermittently unavailable (as of this writing). During downtime, work continues on client-side items (not database-dependent) and documentation/research tasks. Database-dependent open items (Krono verification, further expansion scoping, the in-progress spell overhaul) are blocked until MCP access is restored.

## History

Full detail on each migration: see the individual ADR referenced above.
