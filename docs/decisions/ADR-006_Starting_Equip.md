# ADR-006: Starting Kit Review (Classic Verification)

**Status:** Accepted — Implemented
**Date:** 2026-07-25

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
the table: cross-checking each remaining item against TAKP's own
`starting_items` table. TAKP has already been verified independently
(ADR-004) to match real classic client spell data exactly, making it
a reliable comparison point — more reliable than general web search,
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
| Backpack (universal) | Not classic — removed | Absent from TAKP's starting_items; absent from P99 guide's explicit item list; a general web source supporting it described current live EQ's mechanic, not the Velious-era one |

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
checking against TAKP's own data (once TAKP itself is verified
trustworthy, as established in ADR-004) is a stronger default check
than either assumption or general web search for this class of
question.

## Spire Compatibility

No schema changes. `starting_items` is a standard PEQ table Spire
already edits directly.

## Implementation Status

**Implemented 2026-07-25.** Applied directly against the live Angels
Misfits database (MCP connection). Verified post-run: querying for
both removed row IDs (`2`, `137`) returned zero results, confirming
successful deletion. No other rows in the table were affected.
