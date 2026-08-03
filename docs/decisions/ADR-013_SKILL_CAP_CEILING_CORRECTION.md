# ADR-013: Skill Cap Ceiling Correction (All Classes)

**Status:** Accepted — Implemented
**Date:** 2026-08-02

---

## Context

While auditing Necromancer character skills (prompted by investigating
Angel's specific skill values), the `skill_caps` table was found to follow
a runaway linear formula with **no ceiling** — rows continued climbing
per-level all the way out to level 100 instead of plateauing at the
correct maximum once a class's real per-skill cap was reached. This meant
characters could train skills well past their intended classic ceiling.

A P99 forums reference (thread since removed/renumbered) suggested a
general shape of `(Level × 5) + 5` for many skills, which was verified
against our own data (Necromancer's Channeling matched this exactly) but
shown to be too simple a rule to apply universally — different skills
have different multipliers and offsets entirely (Offense follows
`Level × 4`; Meditate follows `Level × 5 + 25`). Rather than reverse-
engineer every skill's exact per-level formula, the chosen fix targets the
actual defect directly: the missing ceiling, not the climb rate, which was
already correct wherever it had been checked.

## Decision

Apply an idempotent clamp to `skill_caps`: `SET cap = X WHERE cap > X`,
where X is each class's documented ceiling for that skill, sourced from
that **specific class's own P99 wiki skills table** — not the generic
per-skill wiki pages, which were found to carry known-outdated or
disputed numbers for at least Shadow Knight. Because the clamp only ever
lowers out-of-range values and never touches values already at or below
the correct ceiling, it's safe to apply without a separate verification
pass first, and safe to re-run without side effects.

Two-tier clamps (a different ceiling before vs. after level 50) are used
specifically for:
- **Meditate**, across every class checked.
- **Channeling**, specifically for Shadow Knight.

These were the only skill/class combinations where the source wiki tables
showed a materially different "Cap Until 50" vs. "Cap Above 50" value;
every other skill uses its single "Cap Above 50" value as a flat ceiling
throughout, since that value is always ≥ the pre-50 figure.

Tradeskills are excluded from this pass entirely, consistent with the
scope of the original Necromancer audit.

## Scope

Two related but distinct fixes:

1. **`skill_caps` table correction** — class-wide, all levels, not
   character-specific. Covers all 8 classes with characters or relevance
   to this project: Necromancer (class_id 11), Warrior (1), Cleric (2),
   Shadow Knight (5), Monk (7), Bard (8), Shaman (10), Enchanter (14).
2. **Character-level re-application** — individual characters whose
   *current* skill values were already set above the (now-corrected)
   ceiling need those specific values brought back down to match. This
   was done explicitly for the Necromancer test character ("Angel"),
   correcting seven skills that had drifted above the true cap (1H/2H
   Blunt, Bind Wound, Defense, Dodge, Hand to Hand, 1H Piercing,
   Throwing, Alcohol Tolerance) plus the chosen Specialize Conjoration
   specialization, which was sitting at 205 against a true training
   ceiling of 200 — separate from the "only one specialization may
   exceed 50" rule already enforced elsewhere.

## Consequences

- Any character whose current skill values exceed the corrected caps will
  have those specific skills reduced to the correct ceiling once the
  character-level re-application is run for them — this is a real,
  visible reduction for affected skills, not just a data-table cleanup.
- Future characters gain skills normally, correctly stopping at the
  intended ceiling instead of silently continuing to climb past it.
- The clamp approach deliberately does not verify or correct each skill's
  *climb rate* (the per-level formula on the way up to the ceiling) —
  only the ceiling itself. Wherever climb rate was spot-checked
  (Necromancer's Channeling, Offense, Meditate), it was already correct,
  but this was not exhaustively verified for every skill on every class.
  If a climb-rate defect is found later, it would need its own follow-up
  fix distinct from this one.

## Spire Compatibility

No schema changes. `skill_caps` and `character_skills` are both standard
PEQ tables Spire already edits directly.

## Implementation Status

**Implemented and fully verified 2026-08-02+.** Both pieces confirmed
applied against the live database:

- Necromancer-specific fix (`skillcaps_necromancer_audit_fix.sql`) and
  Angel's character-level correction: confirmed applied.
- 7-class expansion (`skillcaps_multiclass_audit_fix.sql`, Warrior/
  Cleric/Shadow Knight/Monk/Bard/Shaman/Enchanter): confirmed applied —
  all 188 covered skill/class/level combinations verified correctly
  capped, zero remaining outliers among them.

**Gaps found and closed during verification, not part of the original
file:**
- Begging (skill 67) was missing for Warrior and Shadow Knight —
  fixed to 200, matching every other class's confirmed value.
- Triple Attack (skill 76) and 2H Piercing (skill 77) were missing
  entirely for the classes that need them. Research confirmed both are
  genuine Velious-era content, not later-client-only artifacts: 2H
  Piercing weapons are documented Velious drops (e.g. Tantor's Tusk),
  usable by Warrior/Paladin/Shadow Knight; Monk's Triple Attack is
  confirmed by P99's own Monk page as an innate level-60 mechanic tied
  to Double Attack. Fixed by mirroring each class's own parallel skill:
  Warrior/Shadow Knight 2H Piercing set to match their existing 1H
  Piercing cap (240/210); Monk Triple Attack set to match their own
  Double Attack cap (250). Warrior's Triple Attack, not confirmed by
  any source as a real Warrior mechanic, was set to 1 (inert),
  following the same precedent as Bard's Meditate=1 ("bards do not
  meditate").

**Investigated and confirmed NOT gaps** (present in raw outlier data
but functionally correct as originally omitted):
- Bash (skill 10) for Cleric — P99 confirms only Paladin/Shadow
  Knight/Warrior can use Bash at all; Clerics cannot train it
  regardless of the stale cap value.
- Throwing (skill 51) for Cleric/Shadow Knight/Shaman — P99's
  dedicated Throwing page does not list these three classes among
  those with the skill at all.
- The remaining block of skills at a flat 300 across every class
  (IDs 57,58,59,60,61,63,64,65,68,69) are tradeskills, explicitly
  out of scope per the original file's own stated exclusion.

A final comprehensive sweep across all 7 classes post-fix confirms no
further outliers beyond the three confirmed-non-issues above.
