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

Purpose: Reference material for Velious-era progression values not yet
imported or merged.

## Database Philosophy

The PEQ structure is maintained unless a deliberate change is
documented. Content scope restrictions are enforced through gating
(see ADR-001), not through schema modification or data deletion.

## Verified Table Contents (PEQ Import, Content Category)

Row counts below are from the imported PEQ dump prior to any
expansion-scope filtering. These reflect the full dataset, not the
Velious-restricted subset that will be exposed on the live server.

| Table | Rows | Notes |
|---|---|---|
| `items` | 117,944 | Full modern item catalog; no reliable single-column expansion flag — scoping is deferred per ADR-001 |
| `npc_types` | 67,530 | Full NPC roster across all eras |
| `spells_new` | 40,722 | Full spell list; expansion scoping deferred per ADR-001 |
| `spawn2` | 165,711 | Spawn points, all zones |
| `zone` | 2,449 | All zone instances, all eras — primary gate point for ADR-001 (`expansion <= 2`) |
| `loottable` | 26,514 | Full loot table set |
| `lootdrop` | 51,943 | Full lootdrop entries |
| `grid` / `grid_entries` | 31,556 / 859,842 | NPC pathing data |

## Privacy / Data Safety

Verified 2026-07-22: `create_tables_login.sql` and
`create_tables_player.sql` contain schema only — zero data rows. No
account or character data is present in this import.

## Content Scope Restriction

See **ADR-001: Content Restrictions** (`docs/decisions/`) for the full
decision record. Summary:

- Zones gated via `zone.expansion <= 2` (Classic, Kunark, Velious).
- Items and spells have no reliable single-column expansion gate in
  PEQ; scoping these is deferred and will be handled incrementally as
  zones are built out, cross-referenced against allowed zones and loot
  tables rather than filtered globally up front.

## Open Items

- ADR-001 content restrictions (zone `expansion <= 2` gating) are
  **decided but not yet implemented**. No database changes have been
  made. Implementation will occur directly against the live Angels
  Misfits database once EQEmu MCP is connected, rather than as a
  standalone SQL migration applied to this reference dump.
- Item/spell/NPC-level expansion scoping not yet implemented — deferred
  per ADR-001, to be handled as Phase 3/5 work proceeds, once zone
  gating is in place.
- TAKP Rebalanced data not yet compared against PEQ baseline values.
- This document is based on the uploaded reference PEQ dump, not a
  live connection to the running Angels Misfits database. Once MCP is
  connected, the live database should be verified against this
  baseline before any restriction work begins, in case Angels Misfits
  has already diverged from a clean PEQ import.