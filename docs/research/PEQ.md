# PEQ (ProjectEQ Database)

## Reliability Summary

PEQ is Angels Misfits' structural foundation and the project's baseline import — reliable as a **modern, ecosystem-compatible database structure**, but consistently found to reflect current-era/live-game defaults rather than classic-era values wherever the two differ.

## What PEQ Is Good For

- **Schema and structure.** No project decision to date has required deviating from PEQ's table structure — every change made (ADR-002 through ADR-007) modifies existing PEQ columns/tables rather than restructuring them. This is exactly the Spire-compatibility and ecosystem-compatibility benefit PEQ provides.
- **Completeness.** The full PEQ dump (117,944 items, 67,530 NPCs, 40,722 spells, 618 zones, etc.) is comprehensive across all expansion eras — useful as a reference even for later-era content this project doesn't currently expose to players.

## Where PEQ Diverges From Classic — Confirmed Pattern

- **Spell mechanics.** Diverges from real classic client data on hundreds to 1,000+ spells per mechanical field (recast time, range, effect values, target type, skill, components) — not just cosmetic fields. See ADR-004.
- **NPC combat stats.** Consistently and uniformly softer than TAKP's classic-tuned values across every stat examined (HP, damage, AC, resists, regen) — 100% directional, no exceptions found. See ADR-003.
- **Server rules.** Defaults target a modern, full-expansion server experience by design (e.g., `World:ExpansionSettings` ships seeded to `524287`, everything through Rain of Fear) — expected to need correction for any era-restricted project, not a PEQ flaw so much as a mismatch with this project's goals. See ADR-001, ADR-002.
- **Starting items.** Included two non-classic items (Gloomingdeep Lantern, Backpack) not present in TAKP or documented classic sources. See ADR-006.
- **NPC models.** Certain skeleton-family NPCs left at newer race IDs rather than the best-available classic approximation. See ADR-007.

## Working Takeaway

Treat PEQ as correct on structure and completeness, but assume any given **default value** reflects modern/live-era design intent until checked against a more classic-focused source (TAKP, client data, P99 wiki) — this pattern has held without exception across every ADR to date. When evaluating a new PEQ default for a future area (itemization, quests), the default assumption should be "verify before trusting," not "PEQ is probably fine."
