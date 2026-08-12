# ADR-019: Full Spell Mechanics Resync Against Verified P99 Client Data

**Status:** Accepted — Implemented and Verified (2026-08-08; see Implementation Status and Addenda below)

**Date:** 2026-08-08

**Supersedes:** ADR-004 (Spell Mechanics — Classic Restoration)

---

## Context

ADR-004 (2026-07-23) adopted a "TAKP-claimed comparison database's" `spells_new`
table in full, on the basis that it had been "checked directly against the real
classic client's own `spells_us.txt` file and matched byte-for-byte." That
migration affected 37,729 of ~40,719 spells.

A ~40,719-spell dataset is not possible for a genuine Titanium-era P99 client
export — that id range only exists once several post-Velious expansions have
been added. This session located and verified a genuine P99 client install on
this machine (`C:\P99\spells_us.txt`, from a real `Launch Titanium.bat` /
`*_P1999Green.ini` install, MD5 `a8e7d07f725462842ee984e169e86c5a`), which
contains exactly 8,088 spells — consistent with a real Titanium/Velious-locked
spell roster. Running the mapping and comparison work below against this file
found that the live database (as left by ADR-004) diverges from genuine P99
data on effectively every spell. This strongly indicates ADR-004's source was
never actually Titanium/P99 data — most likely one of the larger 237-field/
~28MB files also present on this machine (`Desktop\Full_RoF2`, `Desktop\FV`,
`Downloads` copies), which this session separately proved diverge from true
P99 content despite matching its column format (see the FV-vs-P99 comparison
work earlier this session, and the pre-existing contradiction between
`docs/research/TAKP.md` calling that file Titanium-era and `ADR-005_PETS.md`'s
"Related Investigation: Client Files" section arguing its format looks
modern/RoF2-era). ADR-004's "byte-for-byte" verification was evidently a
narrow spot-check (a handful of named spells), not an exhaustive comparison.

This ADR does not resolve exactly what ADR-004's source file was — see
`docs/research/TAKP.md` for that open question — only that it was not the
genuine P99 export used here, and that this resync corrects the result.

## Field Mapping

P99's Titanium export uses a caret-delimited, 217-field-per-line format —
fewer than our live `spells_new` schema's 237 columns. Rather than inferring
the mapping by diffing (which produced a false positive early in this
investigation — see below), the mapping was proven directly from EQEmu's own
schema migration history:

- `utils/sql/svn/230_spells_table.sql` (the original `CREATE TABLE spells_new`)
  has exactly 215 columns, `id` through `field214`, using generic `fieldNNN`
  placeholders wherever no name had yet been assigned.
- `common/database/database_update_manifest.h` records every subsequent
  `ALTER TABLE spells_new` ever applied. Every one is either a `CHANGE`
  (rename-in-place, same ordinal position — e.g. `field168` → `IsDiscipline`)
  or an `ADD` that appends at the tail (bare `ADD`, or `ADD ... AFTER
  <previous newly-added column>`). No column was ever inserted mid-list.

Column position has therefore never shifted since the original 215-column
table; it only grew via renames-in-place plus a 22-column tail extension
(`field215` through `field236`). **P99's 217 fields map 1:1 by index to our
schema's `id` (index 0) through `field216` (index 216).** Columns 217-236
(`field217`, `aemaxtargets`, `maxtargets`, `field220-223`, `persistdeath`,
`field225-226`, `min_dist`, `min_dist_mod`, `max_dist`, `max_dist_mod`,
`min_range`, `field232-236`) don't exist in P99's format at all and are
untouched by this migration.

(An early comparison of spell id 4520 appeared to show a field misalignment
starting around index 101; this was a false positive — id 4520 is a genuine
duplicate/erroneous object in P99's own data (all 16 `classes` columns = 255,
i.e. grantable to nobody), not a mapping bug. A clean test spell, Sunbeam
(id 143), showed full positional alignment once compared correctly.)

## `field215` Exclusion

Index 215 (`field215`) is excluded from every SET clause in the migration.
Sampling all 8,088 P99 rows at that position shows 7,889 blank and 199
carrying text like `!Expansion:Velious`, `!Expansion:Kunark`, `!Expansion:Hole`
(a Kunark-era zone), or a dated patch tag (`!Expansion:Jan2001`, etc.) — this
is P99's own curator-added spell-introduction annotation, repurposing an
otherwise-unused `int(11)` column slot as text. It is not spells_new data and
cannot be meaningfully converted. (These 199 tags are independently useful as
era-introduction evidence and are worth a dedicated follow-up, separate from
this migration.)

## Decision

Update every mechanical/attribute column (indices 1-214 and 216 — i.e. every
column P99's format covers except `id` itself and `field215`) to match P99's
value, for every spell id present in both P99's file and the live database.

**This includes `classes1-16` and `deities0-16`.** These columns describe a
spell's attributes (who it's designed to be grantable to) the same as any
other field in this pass — they are not being used here to make new
era-availability determinations. A P99 raw-export value does not by itself
prove a spell was ever actually activated for players on P99 (client data
describes what a spell *is*; P99's live activation state is a separate,
unexported fact) — a dedicated comparison against the P99 **wiki** (not just
the raw file) is planned as a follow-up to determine actual Velious-era
availability. This migration is a starting point for that work, not a final
activation ruling.

**Scope:** all P99 spell ids except id 0 (blank placeholder) and ids 1348 /
5093 ("Open Testing slot" / "test immunity" — debug content, confirmed absent
from the live database, not inserted).

## Explicit Override: id 8616

The general resync would restore id 8616 (Unholy Aura Discipline, 25%,
Kunark-era version) to grantable via its P99 `classes5` value, alongside id
8618 (50%, Velious-era version) — both legitimately exist in P99's own
database, which itself spans classic through Velious and beyond in a single
export (the same reason both Kunark and Velious versions of this discipline
coexist there). This project deliberately keeps only the Velious-era version
active, per the existing resolution recorded in ADR-009's addendum. The
migration script re-applies `classes5=255` on id 8616 as an explicit override
statement immediately after the general resync, to preserve that decision.

## Discipline Re-examination (ADR-009 Addendum Correction)

Checking P99's raw data for the four disciplines ADR-009's addendum disabled
as "non-legacy":

| id | Name | P99 `classes1-16` | Verdict |
|---|---|---|---|
| 4659 | Sneak Attack | all 255 (nobody) | Confirms disable — no conflict |
| 4681 | Bellow | `classes1=52` (Warrior, grantable) | **Contradicts** the disable — P99 grants this |
| 5225 | Throw Stone | all 255 (nobody) | Confirms disable — no conflict |
| 25060 | Elbow Strike | not present in P99's file at all | Confirms disable — no conflict, untouched by this migration either way |

Bellow (id 4681) is genuinely grantable to Warriors at level 52 in P99's data,
contradicting ADR-009 addendum's "no P99 corroboration" conclusion — likely
the same class of wiki-research gap that caused the original Unholy Aura
Discipline mixup. This migration's general resync re-activates it. Final
confirmation is deferred to the planned wiki-based activation pass, same as
all other `classes1-16` values in this migration.

## Scale

- 8,085 spells updated (of 8,087 non-placeholder P99 ids; 2 excluded as
  debug/test content per above)
- 1 explicit post-resync override (id 8616, `classes5`)
- Every column in scope is touched somewhere in the dataset; per the
  background comparison pass, `recovery_time` differed on 3,090 spells,
  `recast_time` on 1,344, `effect_base_value1` on 1,039, `skill` on 666,
  among many others (full detail: `p99_diff_summary.md`, generated to the
  session scratchpad, not committed to the repo)

## Risk

This is the largest migration this project has run, larger in real terms
than ADR-004 since it corrects that migration's underlying data quality
rather than building on it. Spell effect fields determine what a spell
mechanically *does*; an error here can silently break function, not just
magnitude. Every value in this migration comes directly from the verified
genuine P99 export — none invented or inferred. `classes1-16`/`deities0-16`
changes carry additional risk noted above (attribute correctness only, not a
final activation ruling — follow-up wiki pass required).

## Consequences

- Effectively every spell mechanically resets to genuine P99/Velious-era
  values, correcting whatever the ADR-004 migration actually introduced.
- Bellow (id 4681) becomes grantable to Warriors again, reversing the ADR-009
  addendum's disable.
- id 8616 remains disabled (explicit override), preserving the deliberate
  Velious-era placement of Unholy Aura Discipline.
- `classes1-16`/`deities0-16` values across the broader dataset should be
  treated as provisional pending the planned P99-wiki activation-status pass.
- ADR-004 should be marked superseded; its "byte-for-byte match" claim
  should not be relied upon going forward.

## Spire Compatibility

No schema changes. `spells_new` is a standard PEQ table Spire already edits
directly. This is a large data update, not a structural change.

## Verification Plan (per `TESTING.md`)

To be performed immediately after manual application via HeidiSQL:

- Direct post-run query against live state for a sample of spells spanning
  multiple classes/levels, comparing against the corresponding P99 source
  line field-by-field.
- Targeted checks: id 8618 (`classes5` grantable, `EndurCost=900`), id 8616
  (`classes5=255`, override applied), id 4681/Bellow (`classes1=52`, now
  grantable), id 4520 (still fully ungrantable).
- Random, non-cherry-picked sampling across the 8,085 affected ids.
- Exclusion verification: confirm ids 1348, 5093, and 0 were not touched/
  inserted.
- Row count sanity check: `SELECT COUNT(*) FROM spells_new` unchanged
  (this migration only updates existing rows, never inserts/deletes).

## Addendum (2026-08-08): Icon Regression Discovered and Fixed

Several hours after deployment, classic spell icons and spell gems broke.
Investigation traced this to `new_icon` (and, on a smaller scale, `icon`/
`memicon`), which this migration overwrote for all 8,085 P99-matched spells
as part of the general attribute resync.

`new_icon` is the field the client actually reads spell-gem/buff-window
icon indices from (`uifiles/default/spells??.tga`, per `common/spdat.h`'s
own comment: "Looks to depreciate icon & memicon"). ADR-008 established the
classic-icon appearance by replacing the client's icon *sheet files*
(sourced from FV Project, paired with TaipoUI as `TaipoUI_FVP`) while
deliberately leaving the database's icon-index values untouched — ADR-008
explicitly states this was intentional, "to preserve current RoF2 spell
name/description/AA data integrity while still reverting the visual/
particle assets." This resync broke that pairing: P99's Titanium-era export
does not reliably carry `new_icon` data (the field postdates Titanium's
real use) — post-resync, 1,587 spells (of ~8,085 touched) collapsed to
`new_icon=161`, the column's bare schema default, confirming P99's raw
values are mostly placeholder/unpopulated for this specific field, not
genuine classic icon data.

**Verification of client-side files first:** confirmed via file
modification timestamps that none of the actual icon sheet files
(`uifiles/default/spells01-07.tga`, `uifiles/TaipoUI_FVP/spells01-05.tga`)
were touched by today's work — all predate this session (July 25 - Aug 2).
This ruled out a missing/corrupted asset as the cause and confirmed a
pure database-value regression.

**Fix:** `scripts/2026-08-08_spell_icon_regression_fix.sql` — restored
`new_icon` (6,074 spells), `icon` (295 spells), and `memicon` (297 spells)
to their pre-migration values, sourced from a temporary comparison table
loaded from the pre-migration backup (`angels_misfits_backup_2026-08-08.sql`,
taken before this migration was applied). All three were restored, not
just `new_icon`, per project-lead direction — to fully honor ADR-008's
original decision rather than leave it partially reverted. Verified via
direct query: 0 remaining differences across all three columns after the
fix. Server restarted, `spells_us.txt` re-exported (all 40,722 lines still
exactly 237 fields) and redeployed to `Full_RoF2/spells_us.txt`.

**Lesson for future resyncs against P99 raw data:** `new_icon` (and
possibly `icon`/`memicon`) should be excluded from any future full-table
resync against P99's raw export, the same way `field215` already is —
P99's Titanium-era data is not a reliable source for this specific field.
This was flagged as a risk by the project lead *before* this migration was
applied ("The spell icons directly link to all the work we did for classic
gems. if that mapping goes wrong they go wrong.") but no exclusion was
built in at the time; this addendum corrects that gap after the fact.

## Implementation Status

**Implemented 2026-08-08.** A full database backup
(`angels_misfits_backup_2026-08-08.sql`) and a copy of the pre-migration
client `spells_us.txt` (`Full_RoF2/spells_us_backup_2026-08-08.txt`) were
taken beforehand. Applied via the `mysql` CLI directly against the live
database (`scripts/2026-08-08_p99_full_spell_mechanics_resync.sql`,
8,085 UPDATE statements + 1 override), completing in 6.4 seconds.

Verified via direct post-run query against live state (never trusting the
script's own exit status):

- **Targeted checks:** id 8618 (`classes5=55`, `EndurCost=900` — active
  Velious version), id 8616 (`classes5=255` — override applied
  successfully, Kunark version stays disabled), id 4520 (`classes1-16` all
  255 — duplicate stays fully ungrantable), id 4681/Bellow (`classes1=52` —
  now correctly grantable to Warriors, confirming the ADR-009 addendum
  correction).
- **Random, non-cherry-picked sample:** 5 ids (5401, 3496, 2103, 2618,
  4856) checked across `mana`, `cast_time`, `recast_time`,
  `effect_base_value1`, `resisttype`, `skill` — all matched P99 exactly.
  (Note: zero-valued numeric columns render as blank in the MCP query
  tool's table output, not literal "0" — confirmed as a display quirk, not
  missing data, by cross-checking a spell with known non-zero values.)
- **`classes1-16` gating spot check:** id 2618 (Spirit of Yekan) — all 16
  columns matched P99 exactly (`classes15=39`, rest 255).
- **Exclusion check:** ids 0, 1348, 5093 confirmed absent from
  `spells_new` (0 rows returned) — correctly excluded, not inserted.
- **Row count:** `spells_new` totals 40,722 rows post-migration, consistent
  with an update-only migration (no rows inserted or deleted).

## Addendum (2026-08-08): Server Restart, Client Export, and a `CONCAT_WS`/NULL Defect

After verification, the server was cycled (`spire.exe eqemu-server:launcher
restart` — the CLI form of `server_restart.bat`) to confirm the live game
processes, not just the database, reflect the resync. Zone logs confirmed a
clean restart with no errors introduced by this migration (one pre-existing,
unrelated `Failed to get zone_name [freeporte]` bootup error recurred, first
seen in logs from 2026-08-02, well before this migration) and — critically —
`Loaded [40,722] spells via shared memory`, exactly matching the live
`spells_new` row count, confirming shared memory rebuilt from current
database state rather than serving a stale cache.

`bin/export_client_files.exe spells` (the compiled form of
`client_files/export/main.cpp`, discovered earlier this session) was then
run to generate a fresh client-facing `spells_us.txt`. Initial spot-checking
of the export uncovered a real defect: `SpellsNewRepository::GetSpellFileLines`
builds each line via SQL `CONCAT_WS('^', ...)`, and `CONCAT_WS` **silently
drops any `NULL` argument** rather than emitting an empty field — it does
not preserve field position for NULLs. This migration used `NULL` (not
empty string) for blank values across `spells_new`'s 8 nullable text
columns (`name`, `player_1`, `teleport_zone`, `you_cast`, `other_casts`,
`cast_on_you`, `cast_on_other`, `spell_fades`), so any spell with a blank
message exported with fewer than 237 fields — and the count varied
row-to-row depending on how many of those columns were NULL for that spell,
which would corrupt fixed-position client-side parsing for every affected
spell. Querying the live database found this affected up to 7,774 spells
(`you_cast` alone) — and predates this migration; ADR-004's original July
resync almost certainly carried the same defect, meaning every export since
then was likely similarly malformed.

Fixed via `scripts/2026-08-08_spells_new_null_text_normalization.sql`:
`COALESCE(column, '')` across all 8 nullable text columns, database-wide
(not just this migration's touched spells). This is a pure format fix —
`NULL` and `''` are functionally identical in-game (both mean "no
message"), so no game behavior changed. Applied via the `mysql` CLI,
verified via direct query (all 8 columns show zero remaining NULLs), server
restarted again, and the export re-run. The corrected export was verified
line-by-line: all 40,722 lines now have exactly 237 fields (previously
variable), and both id 8618/8616 spot-checks now read correctly at their
proper field positions. Deployed to `Desktop\Full_RoF2\spells_us.txt`
(pre-migration copy preserved at `spells_us_backup_2026-08-08.txt` in the
same folder).
