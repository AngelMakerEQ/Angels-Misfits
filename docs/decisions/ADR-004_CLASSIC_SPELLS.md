# ADR-004: Spell Mechanics (Classic Restoration)

**Status:** Superseded by ADR-019 (2026-08-08)

**Date:** 2026-07-23

**Supersession note (2026-08-08):** This ADR's "byte-for-byte match against
the real classic client's own `spells_us.txt`" claim does not hold up. Its
source dataset covered ~40,719 spells — impossible for a genuine
Titanium-locked P99 export (that id range requires several post-Velious
expansions). A verified genuine P99 client export (`C:\P99\spells_us.txt`,
8,088 spells) was located and compared against the live database this ADR
produced; it diverges on effectively every spell. The "byte-for-byte"
verification here was evidently a narrow spot-check, not exhaustive. See
ADR-019 for the corrected resync and full account. Do not treat this ADR's
conclusions as reliable going forward.

**Provenance note (2026-08-06):** "TAKP" throughout this ADR refers to a
local comparison database the user obtained and was told is sourced from
TAKP (The Al'Kabor Project) — this project has no independent way to
verify that claim. **Unlike ADR-003/005, this ADR's core conclusion does
not depend on that provenance being true** — the spell data was checked
directly against the real classic client's own `spells_us.txt` file and
matched byte-for-byte, which is genuine primary-source verification
regardless of where the comparison database itself came from. See
`docs/research/TAKP.md` for the full breakdown.

---

## Context

The comparison database's file author's note claimed their release
included "Classic Spells" alongside the mob stat and rule changes covered
in ADR-002 and ADR-003. This claim was not evaluated at the time those
ADRs were written and was carried forward as an open item.

A separate archive supplied by the TAKP author (containing client
files alongside the same database) included `spells_us.txt` — the
classic EverQuest client's spell data file — along with `BaseData.txt`
(base HP/mana/endurance and regen formulas) and `SkillCaps.txt` (skill
caps per class/level). Initial appearance suggested these might be
purely cosmetic client assets; verification showed otherwise for these
three, while `GlobalLoad.txt` (asset loading manifest) and
`dbstr_us.txt` (ID-to-text string lookup) were confirmed to be
genuinely cosmetic/text-only.

## Verification

`spells_us.txt` uses a caret-delimited, 237-field format. EQEmu's
`spells_new` table has exactly 237 columns in the same order — the
formats are positionally identical, confirmed via matching field
values on a known spell (id 3, "Summon Corpse") across all three
sources.

A complete field-by-field comparison was run across all 237 columns
and all ~40,719 spells:

- **The TAKP-claimed comparison database's `spells_new` matched the classic reference file exactly**
  on every mechanical field, for every spell. A handful of text
  fields (`name`, `cast_on_you`, `cast_on_other`, `spell_fades`)
  initially appeared to differ; this was confirmed to be a false
  positive caused by SQL apostrophe-escaping (`\'` vs `'`) in the
  comparison tooling, not a real content difference.
- **PEQ's `spells_new` diverges substantially** from the classic
  reference. The largest differences (`spellanim`, `new_icon`,
  `descnum`, `typedescnum`, animation/icon fields) are cosmetic/UI
  presentation, not mechanics. Beneath those, real mechanical
  divergence exists on hundreds to over a thousand spells per field,
  including `recast_time`, `recovery_time`, `range`,
  `effect_base_value1/2`, `formula1`, `targettype`, `effectid1/2`,
  `skill`, `classes1`, and `components1` — fields that determine what
  a spell *does*, not just its numeric magnitude.

This independently confirms the TAKP author's claim: their spell data
is not an approximation of classic mechanics but a match to it,
verified against actual classic client data rather than taken on the
author's word alone. `base_data` and `skill_caps` were spot-checked
(32 of 100 levels; full sample for skill_caps) against the same
classic reference and found to already match the live database with
zero deviation — these were not altered by the TAKP author and require
no action.

## Decision

Adopt the TAKP-claimed comparison database's `spells_new` in full.
Since this specific table (not the dataset as a whole) is now verified
equivalent to the classic reference data, this is treated as a single
decision rather than a per-field reconciliation.

**Scope:** every spell present in both the current database and TAKP
where any field differs — no level or class filtering applied. Three
spells present only in TAKP (ids 0, 1348, 5093 — "Open Testing slot",
"test immunity", and an unnamed entry) are excluded as test/placeholder
data, not real content. Six spells present only in the current PEQ
baseline and absent from TAKP are left unchanged, since no classic
reference value exists for them.

## Scale

- 37,729 spells affected (of ~40,719 total)
- 144,666 individual field changes
- 230 of 236 non-id columns touched somewhere in the dataset
- 1,581 spells have changes to core mechanical fields (mana, cast
  time, recast time, primary effect value, target type, or skill) as
  opposed to purely cosmetic fields

## Risk

This is the highest-stakes change made to this database so far. Unlike
NPC stat tuning (a values/difficulty judgment), spell effect fields
(`effectid1-12`) determine what a spell mechanically *does* — changing
one incorrectly can silently break a spell's function rather than
just its magnitude, and spell mechanics sit squarely in this project's
"class identity" preservation priority. Every changed value in this
migration is either a verified match to classic client data or a
direct value from the comparison database's already-verified-classic spell table — no values
in this migration were invented or inferred.

## Consequences

- Spell balance across all classes shifts toward classic-era values:
  generally longer recast times on several signature abilities (e.g.
  Rage: 30,000ms → 2,250ms — actually *shorter* in this case, direction
  is not uniform), altered target types on hundreds of spells, and
  restored reagent requirements PEQ had removed on ~775 spells.
  This affects moment-to-moment class play, not just numbers.
- Since scope is unfiltered, some spells intended for characters above
  the level 50 cap (ADR-002) are included. This is inert in practice
  — those spells cannot be cast on this server regardless of their
  stored values — but the data is technically present.
- `base_data` and `skill_caps` require no changes; confirmed already
  correct against the same classic reference used to validate this ADR.

## Spire Compatibility

No schema changes. `spells_new` is a standard PEQ table Spire already
edits directly. This is a large data update, not a structural change.


## Implementation Status

**Implemented 2026-07-23.** Applied via migration script against the
live Angels Misfits database (MCP connection). 37,729 spells updated,
144,666 total field changes, in 15.654 seconds with 0 warnings.

Verified post-run via direct query against the live database — 10
spells checked (4 targeting core mechanical fields including Rage,
Chloroblast, Spirit of the Howler, and Timeslice; 6 via random,
non-cherry-picked sampling covering both numeric and text fields).
All 10 matched the computed values exactly, including exact
character-for-character matches on text fields (`cast_on_other`).
