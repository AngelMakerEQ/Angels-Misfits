# ADR-006: Starting Kit Review (Classic Verification)

**Status:** Accepted — Implemented

**Date:** 2026-07-25

**Provenance note (2026-08-06):** "TAKP" throughout this ADR refers to a
local comparison database the user obtained and was told is sourced from
TAKP (The Al'Kabor Project) — this project has no independent way to
verify that claim. See `docs/research/TAKP.md` for the full caveat; this
ADR's findings were cross-checked against the P99 guide as well, which
strengthens the underlying conclusions independent of this note.

---

## Context

Upon first login, a "modern lvl 1 loadout" was observed. Investigation
of the `starting_items` table (148 rows) initially misidentified the
majority of entries — race/class-specific "recruitment letter"
items — as a later-era new-player-guidance system layered onto
classic content.

This was incorrect, and the error is worth recording. The
identification was based on pattern-matching item *names*
("Recruitment Letter," "Tattered Note") against a plausible-sounding
assumption, without checking the mechanic's actual history first.

## Correction and Verification Method

Verification via Project 1999 Wiki's Newbie Guide (a source
specifically documenting 1999-2001 classic behavior) confirmed new
characters have always received a note to their guildmaster as part
of the base starting kit — the "recruitment letters" are that
mechanic, not a later addition. No changes needed to this system.

Given this error, a more rigorous method was applied to the rest of
the table: cross-checking each remaining item against the TAKP-claimed
comparison database's own `starting_items` table. That database's
*spell* table has already been independently verified (ADR-004) to
match real classic client data exactly — its `starting_items` table
carries no such independent verification, so treat this cross-check as
a useful secondary signal, more informative than a general web search,
which often describes current live EverQuest rather than the Velious
era specifically.

## Findings

| Item category | Verdict | Evidence |
|---|---|---|
| Guildmaster recruitment note (per race/class) | Classic — keep | P99 Newbie Guide |
| Starting weapon by class (Dagger/Short Sword/Club) | Classic — keep | Present in TAKP |
| Food/drink (Bread Cakes, Skin of Milk) | Classic — keep | Present in TAKP; P99 guide |
| Bandages (universal) | Classic — keep | Present in TAKP starting_items |
| Pre-scribed starting spells (2 per casting class) | Classic — keep | P99 guide confirms 2; recount of table confirms every pure caster already receives exactly 2 (initial single-spell read was a miscount) |
| Tome of Order and Discord | Not present in either database's starting kit; exists in item tables but ungranted | Confirmed via P99 guide: item exists classically but exists solely to enable PVP flagging. Explicitly irrelevant to this PVE server. No action — absence is correct, not a gap. |
| Gloomingdeep Lantern | Not classic — removed | Absent from TAKP; tied to Gloomingdeep Mines, a post-Velious tutorial zone (confirmed optional/toggleable at character creation, not forced) |
| Backpack (universal) | Not classic — removed | Absent from the TAKP-claimed comparison database's starting_items; absent from P99 guide's explicit item list; a general web source supporting it described current live EQ's mechanic, not the Velious-era one |

## Decision

Removed two rows from `starting_items`:
- `id=2` (Gloomingdeep Lantern, item 9979)
- `id=137` (Backpack, item 32601)

All other rows retained unchanged.

## Consequences

- New characters no longer receive a starting backpack. A separate,
  intentional starting-bag system is planned independently and is out
  of scope for this ADR.
- No change to the optional Gloomingdeep tutorial zone itself — only
  the lantern item was removed, since the zone's opt-in toggle at
  character creation already respects player choice, consistent with
  this project's Luclin-model-optionality precedent.

## Methodology Note

This ADR's main lasting value may be procedural: assuming a database
entry is a "modern addition" because it doesn't immediately look
classic, or conversely confirming it's classic because a source says
"this is what you get at character creation" without checking which
era that source describes, are both unreliable shortcuts. Cross-
checking against the TAKP-claimed comparison database's own data is a
useful additional signal — but note that ADR-004 only independently
verified that database's *spell table* against real classic client
data, not the dataset as a whole (see `docs/research/TAKP.md`); treat
a `starting_items` match as corroborating evidence alongside the P99
guide, not as proof on its own.

## Spire Compatibility

No schema changes. `starting_items` is a standard PEQ table Spire
already edits directly.

## Implementation Status

**Implemented 2026-07-25.** Applied directly against the live Angels
Misfits database (MCP connection). Verified post-run: querying for
both removed row IDs (`2`, `137`) returned zero results, confirming
successful deletion. No other rows in the table were affected.

## Addendum (2026-08-08): Reconciliation Against Genuine P99 Test Characters

Three P99 test characters (Human/Innoruuk Necromancer, Human/Bertoxxulous
Wizard, Ogre Shaman) were created directly on P99 and their actual starting
inventories recorded firsthand, then compared against the live
`starting_items` table. This is stronger evidence than the guide-based
cross-checks used above, since it reflects exactly what P99 currently hands
a real character rather than a secondhand description.

**Tome of Order and Discord — prior "no action" conclusion reversed.** This
ADR originally concluded its absence was correct (a PVP-flagging item,
irrelevant to a PVE server, per a P99 guide read). All three test characters
received it. The original guide-based reasoning does not hold up against
direct observation; it is now wired as a universal starting item.

**"A Worn Candle" — resolved as a naming/wiring gap, not a missing item.**
Initially appeared absent from the item table under any name. The P99 wiki
disambiguates it as the same item as "Wax Candle" (id 12219 in this
database) — icon 1127 matches the wiki's `lucy_img_ID` exactly, and
weight/size match. Per the wiki, it's Human/Barbarian/Erudite starting gear,
not deity- or class-specific.

**Four genuine wiring gaps confirmed** (item exists, zero `starting_items`
rows, verified via a `LEFT JOIN` ruling out a missed duplicate-name item):
`Spell: Minor Shielding*` not granted to Necromancer (only Wizard/Magician/
Enchanter), `Spell: Shock of Frost*` (Wizard) and `Spell: Inner Fire*`
(Shaman) entirely unwired, and `Candle of the Plaguebringers` (Bertoxxulous
holy symbol) entirely unwired.

**One quantity mismatch:** Skin of Milk and Bread Cakes* are granted at 20
charges live vs. P99's 5.

Two items present in our data but not mentioned on any of the three P99
test characters — `Spell: Siphon Strength` (wired to Necromancer) and
`Spell: Burst of Flame` (wired to Shaman) — are left as-is; their absence
from a single test character's inventory isn't proof they're wrong, and
no corroborating P99 source was checked for them specifically.

**Implemented 2026-08-08.** Applied via
`scripts/2026-08-08_starting_items_p99_reconciliation.sql`. Verified via
direct post-run query against live state: `id=4`/`id=5` (Skin of Milk/Bread
Cakes*) now carry `item_charges=5`; `id=14` (Minor Shielding) widened to
`class_list='11|12|13|14'`; four new rows confirmed with correct scoping —
Tome of Order and Discord (universal), Shock of Frost* (Wizard only),
Candle of the Plaguebringers (deity 201/Bertoxxulous), Inner Fire* (Shaman
only), and Wax Candle/"A Worn Candle" (`race_list='1|2|3'`, Human/Barbarian/
Erudite).
