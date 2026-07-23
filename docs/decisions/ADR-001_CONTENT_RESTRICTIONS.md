# ADR-001: Content Scope Restriction (Velious and Earlier)

**Status:** Accepted (implementation pending MCP connection)
**Date:** 2026-07-22
**Last Revised:** 2026-07-23

---

## Context

The imported PEQ database is a full, current-era dump. Zone data spans
nearly the entire expansion history — zones such as `sarithcity` and
`argath` (Broken Mirror / Ring of Scale era) and `thevoida` (Torment of
Velious, 2019) are present.

The original Phase 1 plan was "Velious as starting point, everything
unlocked." That plan did not anticipate that the stock database ships
with post-Velious content enabled by default.

## Decision

Content is restricted to **Velious-and-earlier**: Classic (0),
Kunark (1), Velious (2). Later-expansion content is not exposed to
players.

---

## Mechanism — Verified 2026-07-23

### Expansion Internal IDs

Per official EQEmu documentation:

| Expansion | ID |
|---|---|
| Classic | 0 |
| The Ruins of Kunark | 1 |
| The Scars of Velious | 2 |
| The Shadows of Luclin | 3 |
| The Planes of Power | 4 |
| ... through Torment of Velious | 26 |

### Primary Gate — Server Rules

| Rule | Value | Notes |
|---|---|---|
| `World:ExpansionSettings` | **3** | `maskSoV` — Classic + Kunark + Velious |
| `Expansion:CurrentExpansion` | **2** | Velious |
| `World:CharacterSelectExpansionSettings` | **3** | Or `-1` to disable the override entirely |
| `World:UseClientBasedExpansionSettings` | **false** | Must remain false — see Critical Dependency |

### Bitmask Reference

| Token | Value |
|---|---|
| `bitEverQuest` (Classic) | 0 |
| `bitRoK` (Kunark) | 1 |
| `bitSoV` (Velious) | 2 |
| **`maskSoV`** | **3** |

Classic has no bit of its own — it is the base game and always active.
The cumulative mask for Velious-and-earlier is therefore 3.

### Critical Dependency

`World:UseClientBasedExpansionSettings` **must remain false**. EQEmu's
compiled default is `true`; PEQ overrides it to `false`. If it were
true, the RoF2 client's own expansion level would override
`World:ExpansionSettings` and silently defeat this entire restriction.

### PEQ Default Note

PEQ ships `World:ExpansionSettings = 524287`, which is `maskRoF` —
everything through Rain of Fear. The rule's own embedded note text
claims "up to TSS" and is stale; it does not match the seeded value.

### Secondary Gate — Zone Column

`zone.expansion` uses the same ordinal scheme. Verified empirically
against 16 known-era zones:

| Zones | `expansion` |
|---|---|
| blackburrow, qeynos, freportw, airplane | 0 |
| burningwood, fieldofbone, sebilis, skyfire | 1 |
| greatdivide, thurgadina, templeveeshan, sirens | 2 |
| ssratemple, nexus | 3 |
| bothunder, poknowledge | 4 |

`zone.expansion <= 2` may be applied as a complementary filter.

### Unrelated Mechanism — Do Not Conflate

`zone.min_expansion` / `zone.max_expansion` use a different scale and
are almost always -1 (unset); `sirens` carries 6/99. These are not part
of this decision.

---

## Items and Spells — Deferred

PEQ's `items` and `spells_new` tables have no reliable single-column
expansion flag. Scoping these is deferred and will be handled
incrementally as zones are built out, cross-referenced against allowed
zones and loot tables rather than filtered globally up front.

## Consequences

- World design and exploration scope is bounded to the Velious anchor.
- The full dump is **retained, not purged** — later-expansion content
  remains available for research or deliberate future expansion.
- Item/spell scoping is ongoing deferred work, not a one-time migration.
- Future expansion means deliberately raising this boundary (e.g.
  `maskSoL = 7` for Luclin) through a new ADR, rather than inheriting
  it by accident from an unfiltered database.

## Spire Compatibility

No schema changes. All four rules live in `rule_values`, a standard PEQ
table Spire edits directly. `zone.expansion` is an existing stock
column. Nothing in this decision affects Spire functionality.

## Verification Notes

- Expansion IDs and bitmask values: **verified** against official EQEmu
  documentation.
- `zone.expansion` ordinal: **verified empirically**, 16/16 known-era
  zones.
- `UseClientBasedExpansionSettings` default behavior: **verified**
  against EQEmu `ruletypes.h` and PEQ's seeded value.

## Revision History

- **2026-07-22** — Created. Mechanism stated as `zone.expansion <= 2`.
- **2026-07-23** — Mechanism marked under review after a full
  `rule_values` comparison identified server-level expansion rules.
- **2026-07-23** — Mechanism verified and finalized.
  `World:ExpansionSettings = 3` confirmed as the primary gate;
  `zone.expansion` retained as a secondary gate.

## Implementation Status

**Not implemented.** No database changes have been made. Implementation
will occur against the live Angels Misfits database once EQEmu MCP is
connected, following the project's backup and rollback process.