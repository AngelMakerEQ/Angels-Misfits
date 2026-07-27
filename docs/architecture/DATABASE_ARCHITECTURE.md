# Database Architecture

## Purpose

This document is a structural manifest of which database tables have been modified from stock PEQ, at a glance. It answers "what's been touched" — not what changed within each table (see `docs/database/PEQ_CHANGES.md`) and not the database's overall identity/content scope (see `docs/database/DATABASE_BASELINE.md`).

## Table Status

| Table | Status | Modified By |
|---|---|---|
| `rule_values` | Modified | ADR-002 |
| `npc_types` | Modified | ADR-003, ADR-005, ADR-007 |
| `spells_new` | Modified | ADR-004 |
| `starting_items` | Modified | ADR-006 |
| `items` | Unmodified | Scoping deferred — ADR-001 |
| `zone` | Unmodified | Content gating applied via `rule_values`, not this table — ADR-001 |
| `spawn2` | Unmodified | — |
| `loottable` / `lootdrop` | Unmodified | — |
| `grid` / `grid_entries` | Unmodified | — |

## No Custom Tables

No new tables have been introduced. Every change to date modifies existing PEQ-standard tables. See `docs/database/CUSTOM_TABLES.md`.

## History

Full value-level change ledger: `docs/database/PEQ_CHANGES.md` and `docs/database/TAKP_IMPORTS.md`. Full decision reasoning: `docs/decisions/`.
