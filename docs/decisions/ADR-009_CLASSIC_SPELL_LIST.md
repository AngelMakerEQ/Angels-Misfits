# ADR-009: Spell & Discipline Legacy Correction

**Status:** Accepted — Implemented
**Date:** 2026-07-28

---

## Context

Following the level cap correction (ADR-002 addendum, 2026-07-26), a
comprehensive audit was undertaken to identify every spell and discipline
currently learnable by each class that did not exist by the end of
Velious. Unlike prior ADRs, which relied primarily on comparison against
the TAKP reference database, this audit used the **Project 1999 wiki**
as the primary source of truth throughout.

This choice was deliberate: TAKP progressed through Kunark, Velious,
Luclin, and Planes of Power before its data was captured, and its spell
tables have no era tagging — a spell existing in TAKP only confirms it
existed by TAKP's snapshot point, not that it existed by end of Velious
specifically. P99, by contrast, is explicitly Velious-locked (its Blue
and Green servers do not progress into Luclin), and its class spell
pages carry explicit **Cla / Kun / Vel** era tags per spell, along with
several sub-era tags (Pai = Paineel Era, Fea = Fear Era, Hol = Hole Era,
Sky = Sky Era, C2.0 = Chardok Revamp Era) that are all still pre-Luclin
and therefore in scope. This was confirmed as the right call mid-audit
by an independent source: a P99 forum thread notes that a spell set to
a class but "beyond era/patch" for that class displays as level 255 in
game — the same signal this audit uses to flag non-legacy content.

All 14 classes playable through Velious were audited: Warrior, Monk,
Rogue, Cleric, Shaman, Enchanter, Bard, Paladin, Ranger, Shadow Knight,
Druid, Necromancer, Wizard, and Magician. Beastlord and Berserker were
excluded entirely from the outset — both postdate Velious (Luclin and
Gates of Discord respectively), so every spell and discipline available
to them is non-legacy by definition regardless of content.

### Column Mapping Correction

Building the migration surfaced and corrected two errors in this
project's own prior documentation of the `spells_new` class columns.
The columns follow the standard EQ class ID scheme, verified empirically
against known spell content:

| Column | Class | Column | Class |
|---|---|---|---|
| classes1 | Warrior | classes9 | Rogue |
| classes2 | Cleric | classes10 | Shaman |
| classes3 | Paladin | classes11 | Necromancer |
| classes4 | Ranger | classes12 | Wizard |
| classes5 | Shadow Knight | classes13 | Magician |
| classes6 | Druid | classes14 | Enchanter |
| classes7 | Monk | classes15 | Beastlord |
| classes8 | Bard | classes16 | Berserker |

Two corrections to prior assumptions: `classes1`/`classes7` are
Warrior/Monk respectively, not the reverse; `classes12`/`classes13` are
Wizard/Magician respectively, not the reverse.

---

## Methodology

For each class, our current live database's spell list was compared
level-by-level against that class's dedicated P99 wiki page. Findings
were sorted into four categories:

1. **Non-legacy** — spell/discipline granted to the class in our
   database but absent from P99's table entirely. Corrected by setting
   the relevant `classesN` column to 255 (cannot learn).
2. **Duplicate at wrong level** — the same spell exists twice under one
   class, once at the P99-confirmed level and once at an incorrect
   level. The correct copy is retained; the incorrect copy is disabled.
3. **Wrong-level placement** — a spell that is genuinely classic content
   for a class, but the only copy in our database sits at the wrong
   level. Corrected by moving it to the P99-confirmed level rather than
   disabling it.
4. **Omission** — P99 confirms a spell as legitimate content for a
   class, but our database does not grant it at all. In every case
   found, the spell object already existed correctly under a different
   class, making the fix a one-line level correction rather than new
   content creation.

A recurring false-positive worth recording: tradeskill-flavored spells
(the Cleric/Shaman Imbue gem line, the Enchanter Enchant-metal
progression) are not automatically non-legacy. Several were verified as
genuine classic content and were not touched.

---

## Findings Summary

### Disciplines (Warrior, Monk, Rogue)

The discipline system as a whole is genuine Velious-era content, not a
later addition as initially assumed. Warrior retains 12 confirmed
disciplines/abilities (including Bellow, confirmed via direct
in-game verification), Monk retains 10, Rogue retains 8. Non-legacy
content in this group is narrow and specific: Mercenary abilities
(Seeds of Destruction, 2008-2009), "Rk. II/III" ranked-ability suffixes
(a live-EQ convention from roughly 2010 onward), "Aura"-named effects,
Beta/test artifacts, and three individually-verified Warrior entries
(Provoke, Berate, Elbow Strike).

### Full spell lists (Cleric, Shaman, Enchanter, Bard, Paladin, Ranger,
Shadow Knight, Druid, Necromancer, Wizard, Magician)

Every class showed a strong classic-content core, with non-legacy
content clustering into recognizable, recurring patterns rather than
being scattered randomly:

- **"Ancient:"-prefixed variants** — recurring across Cleric, Shaman,
  Bard, Wizard, Necromancer, and Magician. Consistently non-legacy.
- **"Aura"-named effects** — recurring across Cleric, Shaman, Bard,
  Enchanter, Paladin. Consistently non-legacy.
- **The Zephyr/Ring/Circle teleport family** — a large, systematic
  later-era teleport convenience system, tied to zones that postdate
  Velious (Natimbi, Barindu, Undershore, Arcstone, Bloodfields,
  Blightfire Moors, Dawnshroud, The Steppes, Sunderock Springs). Found
  extensively on Druid and Wizard.
- **Guild Hall teleports** — guild halls are a confirmed later feature;
  found on Druid and Wizard.
- **"Eradicate X" / "Remove Greater Curse" family** — recurring across
  Cleric, Shaman, Paladin, Druid.
- **Wuggan's family** (Appraisal/Discombobulation/Extrication, all
  tiers) — recurring across Enchanter and Necromancer.
- **Focus.../Focus Mass...Spellcaster's Empowering Essence family** —
  recurring across every intelligence-caster class (Enchanter, Wizard,
  Magician, Necromancer).
- **Luclin/Seeds of Destruction race references** (Vah Shir, Drakkin) —
  found on Enchanter and Bard.

Three genuine wrong-level placements were found and corrected rather
than disabled: Necromancer's Scourge (was level 34, corrected to 39),
Plague (was 49, corrected to 52), and Demi Lich (was 56, corrected to
60) — all confirmed classic content, simply misplaced.

Ten omissions were restored: nine Shaman spells (Scourge, Plague,
Sicken, Invisibility versus Animals, Affliction, Insidious Fever,
Insidious Malady, Insidious Decay, Deliriously Nimble — all confirmed
shared content with Necromancer) and one Enchanter spell (Boon of the
Garou, confirmed shared with Beastlord, though Beastlord's own content
is out of scope).

### Items deliberately left unresolved (updated 2026-07-29)

Two of the three items originally flagged here are now resolved via
direct project-lead confirmation:

- **Throw Stone** (Warrior/Monk/Rogue, level 1) — confirmed a genuine
  classic skill. No action needed; remains active for all three
  classes as-is.
- **Death Peace** (Necromancer, level 60) — confirmed a genuine
  classic spell for Necromancer, not just Shadow Knight. No action
  needed; remains active as-is.

One item remains open and now has a specific lead to investigate:

- **"Harmful Touch"** (id 2774) two duplicate spells (ids 88, 2821) with a wrong 30-second recast were disabled; the correctly-configured entry (id 2774, "Harmful Touch," 72-min recast) is confirmed active.

---

## Decision

Disable all confirmed non-legacy spells and disciplines across all 14
audited classes by setting the relevant `classesN` column to 255.
Correct all confirmed duplicate-at-wrong-level entries the same way.
Correct the 3 confirmed wrong-level placements by moving them to their
correct level rather than disabling them. Restore the 10 confirmed
omissions by setting the correct level rather than 255.

## Consequences

- Roughly 150 unique spells/disciplines across 14 classes had their
  class availability corrected; some spell IDs were touched for
  multiple classes where the same non-legacy addition recurred (e.g.
  "Reflect" was granted non-legacy to Shadow Knight, Necromancer,
  Wizard, and Magician alike).
- No player-facing character is currently above level 10, so no
  existing character loses access to a previously-learned spell as a
  direct result of this change.
- Spell mechanics themselves are untouched — this migration only
  changes which classes can learn which spells, not what any spell
  does. ADR-004's mechanical corrections remain fully in effect.
- Three items remain intentionally unresolved (see above) and should be
  revisited individually rather than assumed either way.
- The column-mapping documentation error (Warrior/Monk and
  Wizard/Magician swaps) is now corrected project-wide; any future
  spell work should reference the corrected table in this ADR.

## Spire Compatibility

No schema changes. `spells_new` is a standard PEQ table Spire already
edits directly. This is a large data update, not a structural change —
identical in nature to ADR-004.

## Implementation Status

**Implemented 2026-07-28.** Applied directly against the live Angels
Misfits database (MCP connection, read-only — SQL executed by project
lead via HeidiSQL per established workflow). Database backup taken
immediately prior via HeidiSQL's export function.

Verified post-run via direct query against the live database:

- All 3 Necromancer wrong-level corrections (Scourge, Plague, Demi
  Lich) confirmed at their correct levels.
- All 10 omission restores (9 Shaman, 1 Enchanter) confirmed at their
  correct levels.
- 24 sampled non-legacy disables across all classes confirmed at 255.
- 12 duplicate corrections confirmed disabled for the affected class
  only, with legitimate same-ID grants for other classes (e.g.
  Paladin's own Superior Healing at 57, Shadow Knight's own Expel
  Undead at 55, Druid's own Firestrike at 39) confirmed untouched —
  no collateral damage from the duplicate-cleanup pass.
- One gap identified during verification and corrected via follow-up
  statement: "Focused Will Discipline" (id 4721) was disabled for
  Warrior in the original migration but not for Monk or Rogue, despite
  being flagged non-legacy for all three pure-melee classes. Corrected
  post-verification.
