# Database Baseline

## Current Database

**Angels Misfits**

Purpose: Primary working database for the live server.

## Source Database

**PEQ**

Purpose: Reference database and ecosystem compatibility baseline.

Imported dump verified 2026-07-22. Confirmed to be a full, current-era
PEQ dump — not limited to classic/Velious content. Zone data includes
expansions through at least Torment of Velious (2019), evidenced by
zones such as `sarithcity`, `argath`, and `thevoida`.

Per **ADR-001 (Content Restrictions)**, this database's scope is
restricted to Velious-and-earlier content (`expansion` 0-2) for the
live server. The full dump is retained as the reference source, not
purged, so later-expansion content remains available for research or
future deliberate expansion per project philosophy.

## Supplemental Database

**TAKP Rebalanced**

Purpose: Reference material for Velious-era progression values.

TAKP has been compared against PEQ and adopted, in whole or in part,
across multiple areas — see ADR-002 (server rules), ADR-003 (NPC
combat stats), ADR-004 (spell mechanics), and ADR-005 (pet stats) for
full detail on what was adopted, rejected, or deferred from this
source.

## Database Philosophy

The PEQ structure is maintained unless a deliberate change is
documented. Content scope restrictions are enforced through gating
(see ADR-001), not through schema modification or data deletion.

## Verified Table Contents (PEQ Import, Content Category)

Row counts below are from the imported PEQ dump prior to any
expansion-scope filtering or content corrections. These reflect the
**original full dataset as first imported**, not the current live
state of the Angels Misfits database, which has since been modified
per the ADR series below.

| Table | Original Rows | Notes |
|---|---|---|
| `items` | 117,944 | Full modern item catalog; no reliable single-column expansion flag — scoping is deferred per ADR-001 |
| `npc_types` | 67,530 | Full NPC roster across all eras; subsequently modified by ADR-003 (combat stats), ADR-005 (pet stats), ADR-007 (race/model corrections) |
| `spells_new` | 40,722 | Full spell list; subsequently replaced in substantial part per ADR-004 (37,729 spells, 144,666 field changes) |
| `spawn2` | 165,711 | Spawn points, all zones |
| `zone` | 618 | All zone instances, all eras — primary gate point for ADR-001. Earlier figure of 2,449 was an extraction error that included zone_points (1,831 rows); corrected 2026-07-23.|
| `loottable` | 26,514 | Full loot table set |
| `lootdrop` | 51,943 | Full lootdrop entries |
| `grid` / `grid_entries` | 31,556 / 859,842 | NPC pathing data |
| `starting_items` | 148 | Reduced by 2 rows per ADR-006 (Gloomingdeep Lantern, Backpack removed) |
| `rule_values` | 1,001 (PEQ) / 714 (TAKP) | 17 rules changed per ADR-002; see that ADR for full diff |

## Privacy / Data Safety

Verified 2026-07-22: `create_tables_login.sql` and
`create_tables_player.sql` contain schema only — zero data rows. No
account or character data is present in this import.

## Content Scope Restriction

See **ADR-001: Content Restrictions** (`docs/decisions/`) for the full
decision record. Summary:

- Zones gated via `zone.expansion <= 2` (Classic, Kunark, Velious).
- Items and spells have no reliable single-column expansion gate in
  PEQ; scoping these is deferred and is being handled incrementally as
  zones are built out, cross-referenced against allowed zones and loot
  tables rather than filtered globally up front.

## Implementation Status

**ADR-001 implemented 2026-07-23.** All four gating rules
(`World:ExpansionSettings`, `Expansion:CurrentExpansion`,
`World:CharacterSelectExpansionSettings`,
`World:UseClientBasedExpansionSettings`) are live on the Angels
Misfits database, verified via direct query. This baseline document
previously described this work as "decided but not yet implemented" —
that was inaccurate as of 2026-07-23 and has been corrected here.

EQEmu MCP has been connected since ADR-001's implementation and has
been used for all subsequent database migrations (ADR-002 through
ADR-007). Live-database state should still be spot-checked against
this baseline periodically, but the "PEQ reference dump only, no live
connection" caveat that previously appeared here no longer applies.

## Open Items

- Item/spell/NPC-level expansion scoping not yet fully implemented —
  deferred per ADR-001, being handled incrementally as content review
  proceeds (Phase 3/5 work).
- Broader itemization
