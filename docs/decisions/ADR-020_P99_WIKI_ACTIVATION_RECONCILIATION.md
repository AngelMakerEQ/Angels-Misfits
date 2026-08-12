# ADR-020: P99-Wiki Spell Activation Reconciliation (7 Priority Classes)

**Status:** Implemented

**Date:** 2026-08-08

---

## Context

ADR-019 resynced `spells_new`'s mechanical/attribute fields (including
`classes1-16` grantability) against a genuine P99 Titanium client export.
That resync explicitly noted its own limitation: P99's raw database export
spans their server's entire content history in one file (classic through
many post-Velious expansions), so a spell being grantable in the raw export
doesn't prove it was actually available to players at Velious specifically
— only the P99 **wiki** documents that with confidence. ADR-019 treated its
`classes1-16` sync as a starting point for attribute correctness, not a
final activation ruling, and flagged a dedicated wiki-based pass as a
required follow-up. This ADR is that follow-up.

## Scope

The 7 classes originally prioritized for era-accuracy review earlier this
project: Necromancer, Shadow Knight, Bard, Enchanter, Shaman, Cleric,
Wizard.

## Methodology

For each class, every spell currently active (`classesN` between 1-60) was
checked against the P99 wiki:

1. Check the spell's own wiki page (`{{Spellpage}}` template's `classes =`
   field, which lists exact per-class grant levels) and its era category
   tag (Classic/Kunark/Velious Era, or a later expansion — a later-era tag
   means out of scope regardless of what the classes field says).
2. If not found or ambiguous, check the class's own wiki page for
   corroborating mention.
3. If not found anywhere, default to deactivation — undocumented content
   doesn't get the benefit of the doubt.
4. Duplicate names at the same level (the same "multiple era-versions
   coexisting" pattern already resolved for Unholy Aura Discipline in
   ADR-009's addendum): when the Velious-era version and a superseded
   Kunark-or-earlier version both exist, the Velious version wins.
5. When ambiguity existed even after the above, spell descriptions/effect
   text were used as an additional disambiguating signal alongside class
   grant-level cross-referencing.

Work was parallelized across 7 background agents (one per class), each
producing a findings report (`docs/development/wip/<CLASS>_P99_ACTIVATION_
AUDIT_2026-08-08.md`) rather than acting directly — read-only investigation
only, per this project's standard investigate-first workflow.

## Resolving the 29 Ambiguous Items

29 items across the 7 reports could not be resolved by the audits alone and
were decided in conversation with the project lead:

- **Chardok Revamp Era scope (10 spells)**: confirmed in-scope. This
  matches existing ADR-009 precedent — pre-Luclin sub-era tags (Paineel
  Era, Fear Era, Hole Era, Sky Era, Chardok Revamp Era) were already
  established as in-scope for this Velious-locked server, verified there
  against an independent P99 forum source. One of the two audits that hit
  this tag (Wizard's) had flagged it for a fresh decision without knowing
  this precedent already existed; the other (Necromancer's) had correctly
  applied it. No spells were deactivated on this basis.
- **Fully-identical duplicate ties (9 pairs)**: no mechanical difference
  existed between the two candidate ids in any of these — the higher/
  "8xxx"-style id was chosen as the standing convention, matching the
  pattern that held in every case across this audit batch where real
  evidence existed.
- **3 exceptions where real evidence overrode that convention**:
  - Shaman's **Cannibalize II** (kept **754**, not 8579) — computing the
    exact scaling formula from `zone/spell_effects.cpp` (`formula 109:
    result = ubase + caster_level/4`; `formula 110: result = ubase +
    caster_level/6`) showed id 754's values match the wiki's documented
    mana-return slope exactly (a consistent -3 offset, same shape); id
    8579 did not.
  - Bard's **Jonthan's Provocation** (kept 749, not 8585) and **Jonthan's
    Inspiration** (kept 1762, not 8584) — both "8xxx" ids shared an
    identical flat `effect_base_value1` (103) with each other despite
    being different spells at different levels, a placeholder-data
    signature; the non-8xxx ids had level-appropriate distinct values and
    a populated third effect slot the suspicious ids lacked.
- **7 remaining items** (Cleric's Antidote/Divine Light/Word of Vigor,
  Bard's Syvelian's Anti-Magic Aria) resolved via the same "keep higher
  id" convention, corroborated for 2 of them by `max1` (the spell's hard
  cap) matching the wiki's stated healing bounds almost exactly.
- **Necromancer's Corpal Empathy** (id 1413): deactivated — not found on
  the P99 wiki under any spelling tried.

## Decision

Deactivate (`classesN = 255`) 258 spell grants across the 7 classes:
Necromancer 30, Shadow Knight 16, Bard 15, Enchanter 112, Shaman 32,
Cleric 27, Wizard 26. No rows deleted — this project's standard
gate-don't-delete convention throughout.

## Independent Review

Before application, an independent agent with no involvement in building
the migration re-derived the expected per-class deactivation counts and
ids directly from the 7 source reports (not from any intermediate
compilation artifact), cross-checked all 3 evidence-based exceptions in
both directions, confirmed the Chardok Revamp Era exclusion, verified SQL
syntax, and spot-checked 21 ids against the live database. Verdict: "Safe
to apply. No discrepancies found."

## Scale note: Bind Affinity (id 40971)

One erroneous duplicate object (id 40971, "Bind Affinity") is grantable to
multiple classes and appears independently in 5 of the 7 class reports —
each class's grant of it is correctly and independently deactivated on its
own `classesN` column; this is expected, not a duplication error.

## Spire Compatibility

No schema changes. `spells_new` is a standard PEQ table Spire already
edits directly.

## Implementation Status

**Implemented 2026-08-08.** A fresh database backup
(`angels_misfits_backup_2026-08-08_pre-activation-reconciliation.sql`) was
taken beforehand. Applied via `scripts/2026-08-08_p99_activation_
reconciliation.sql` through the `mysql` CLI directly against the live
database.

Verified via direct query against live state:

- All 7 per-class target-id lists confirmed 100% deactivated (30/30,
  16/16, 15/15, 112-sample/112-sample, 32/32, 27/27, 26/26).
- All 3 evidence-based exceptions confirmed correct in both directions:
  754 (Cannibalize II), 749 (Jonthan's Provocation), and 1762 (Jonthan's
  Inspiration) remain active at their correct levels; 8579, 8585, and 8584
  confirmed deactivated.
- All 10 Chardok Revamp Era ids confirmed still active (not deactivated).
- Row count unchanged (40,722) — confirms update-only, no inserts/deletes.

Server restarted (`spire.exe eqemu-server:launcher restart`), confirmed
clean via zone logs (`Loaded [40,722] spells via shared memory`, no new
errors), `spells_us.txt` re-exported (verified all 40,722 lines still
exactly 237 fields) and redeployed to `Full_RoF2/spells_us.txt`.
