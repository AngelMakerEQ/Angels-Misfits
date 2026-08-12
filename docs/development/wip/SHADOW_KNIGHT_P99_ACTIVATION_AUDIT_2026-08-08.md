# Shadow Knight P99 Activation Audit — 2026-08-08

**Status:** Investigation complete, pending human review. Read-only audit — no database
changes made. A migration script should be written separately after this report is reviewed.

**Scope:** Every spell currently active for Shadow Knight (`spells_new.classes5 BETWEEN 1
AND 60`) on the live `angelsmisfits` database, checked against the P99 wiki (primary
authority) and cross-checked against the raw P99 `spells_us.txt` export already pulled for
ADR-019 (used only as a mechanical disambiguation aid — not as an authority in itself, per
project convention).

## Summary

- **91** spell rows currently active for Shadow Knight (77 distinct spell names).
- **75** confirmed correct — class/level match the P99 wiki, no post-Velious era tag, no
  duplicate conflict. No action needed.
- **16** flagged for deactivation:
  - **15** are duplicate-resolution losers (12 duplicate/conflict groups resolved; in each
    group the Velious-era/current-patch version was kept and the superseded or extra copy
    flagged).
  - **1** (Ichor Guard, id 7005) is not documented anywhere on the P99 wiki or fvproject.com
    — defaulted to deactivate per methodology step 3c.
- **12 duplicate/conflict groups** resolved, covering 27 of the 91 rows:
  - 10 are exact **same name + same level** duplicate pairs/triples (the pattern this
    project has repeatedly found, e.g. ADR-009's Unholy Aura Discipline precedent).
  - 2 are **same name, different level** conflicts (Spirit Tap, Drain Spirit) where P99's
    own patch-history notes ("Moved X to level N") make clear only one level is current.
  - 1 group (Harm Touch/Harmful Touch) is a 3-way resolution across two different in-database
    names for what the wiki documents as one ability.
- No spell's own wiki page carried a post-Velious era category (no Luclin/PoP/later tags
  found). Two spells (Nullify Magic, Summon Companion) carry `Velious Era Inline` tags on
  their Shadow Knight class line specifically — both correctly present in our data at the
  documented level, confirming genuine Velious content rather than flagging it.
- Wiki access was fully available throughout (no fvproject.com fallback needed except to
  confirm Ichor Guard's absence there too).

## Methodology notes specific to this run

- Batched MediaWiki API calls (`action=query&titles=A|B|C...&prop=revisions|categories`)
  against `wiki.project1999.com`, ~25 titles per call.
- For duplicate-id/duplicate-name resolution, and per project-lead instruction mid-task,
  mechanical fields (`mana`, `recast_time`, `buffduration`, `effectid`/`effect_base_value`,
  and the full `classes1-16` grant array) were compared between candidate ids, and against
  the raw P99 `spells_us.txt` export (from the ADR-019 resync work) and any patch-history
  text embedded in the wiki page body (e.g. "(February 21, 2001) — Moved X to level Y").
  This was decisive in several cases below where name+level alone was ambiguous between two
  otherwise-identical ids. Cited inline as "raw export cross-check" where used.
- The P99 raw export was used **only** as a mechanical disambiguator between two ids our own
  database already contains — never as the sole authority for whether a spell should be
  active. Every deactivation recommendation is grounded in the P99 wiki (or its absence).

## Duplicate / conflict groups (detail)

### 1. Harm Touch / Harmful Touch (level 1) — 3-way resolution
Ids 88 and 2821 are both named "Harm Touch", identical mechanically (30 s recast). Id 2774 is
named "Harmful Touch" but has a 4,320,000 ms (72-minute) recast. The P99 wiki's "Harm Touch"
page (redirects to **Skill Harm Touch**) documents a Shadow-Knight-only ability "with a
72-minute timer" — matching id 2774's recast exactly, and not matching 88/2821's 30-second
recast at all. All three share identical cast/fade messages, so this isn't a different
ability, just three inconsistent database copies. **Keep 2774** (matches documented
mechanics); **deactivate 88 and 2821** (mechanically wrong, 30 s recast does not match any
documented version of the ability).

### 2. Endure Cold (level 15)
Ids 8643 and 225 are otherwise identical, but 8643 also grants Ranger at level 22 while 225
does not (raw export cross-check). The wiki's classes field for Endure Cold lists Ranger at
level 22. **Keep 8643**; **deactivate 225** (incomplete/outdated class-grant set).

### 3. Shieldskin (level 34 duplicate + level 39 outdated)
Ids 8640 and 8657 are exact duplicates at level 34. Id 236 is the same spell at level 39. The
wiki page body includes a patch note: "(February 21, 2001) Shadow Knight - 'Moved Shieldskin
to level 34'" — confirming level 34 is the current/correct level and level 39 is the
pre-patch value. **Keep 8640**; **deactivate 8657** (duplicate) and **236** (superseded
pre-patch level).

### 4. Cancel Magic (level 39)
Ids 48 and 8662 are byte-identical in mechanics and full class-grant array (raw export
cross-check confirms both copies exist identically in P99's own source too — no
disambiguating signal available). Wiki confirms level 39, Classic Era. **Keep 48**
(arbitrary — no distinguishing signal); **deactivate 8662** (duplicate).

### 5. Resist Cold (level 39)
Ids 61 and 8648 are otherwise identical, but 8648 also grants Ranger at level 55 while 61
does not (raw export cross-check). The wiki's Resist Cold page lists Ranger at level 55
tagged `{{Velious Era Inline}}` — confirming 8648 as the current/complete version. **Keep
8648**; **deactivate 61** (incomplete/outdated class-grant set, missing the Velious-added
Ranger grant).

### 6. Breath of the Dead (level 49)
Ids 478 and 8660 are byte-identical (mechanics and full class-grant array, raw export
cross-check). No disambiguating signal. **Keep 478** (arbitrary); **deactivate 8660**
(duplicate).

### 7. Resistant Discipline (level 51, Shadow Knight discipline)
Ids 8601 (buffduration 50 ticks ≈ 5 min) and 8608 (buffduration 10 ticks ≈ 1 min) are
otherwise identical. The P99 Disciplines page's Shadow Knight table lists Resistant
Discipline's base duration as "1 Min", with a "Feb 21, 2001" patch column noting "Duration
increased to 5 minutes." Feb 2001 postdates Velious's Dec 2000 launch, so the 5-minute value
is the correct Velious-era-current one. **Keep 8601**; **deactivate 8608** (pre-patch 1-minute
value).

### 8. Banshee Aura (level 54)
Ids 364 (buffduration 30, effect_base_value1 −8) and 8572 (buffduration 90,
effect_base_value1 −6) differ mechanically. The Banshee Aura wiki page explicitly documents
this exact change: "Starts off doing a static 8 damage, before increasing to 9 and beginning
to scale up with level in April 2000 era... Updated Banshee Aura: buffdurationformula 7 → 9,
buffduration 30 → 90, effect_base_value1 −8 → −6... (17 Feb, 2013 Patch)" — i.e. P99 itself
corrected its data in 2013 to match the true April-2000 (pre-Velious, so already in effect
throughout Velious) mechanic. Id 8572's values match the corrected/current data exactly.
**Keep 8572**; **deactivate 364** (pre-April-2000 static-damage version, not applicable by
Velious era).

### 9. Expel Undead (level 55)
Ids 662 (grants Paladin at 55) and 8545 (grants Paladin at 54) are otherwise identical (raw
export cross-check). The wiki's Expel Undead classes field lists Paladin at level 54 tagged
`{{Kunark Era Inline}}`, and Shadow Knight at 55 also `{{Kunark Era Inline}}`. Since Kunark
content is included on this Velious-locked server, the SK grant itself is fine either way —
but 8545's Paladin level matches the documented value and 662's does not. **Keep 8545**;
**deactivate 662** (incorrect Paladin-level copy).

### 10. Leechcurse Discipline (level 60, Shadow Knight discipline) — 3-way
Ids 8617 and 8604 are byte-identical (single effect: effectid1=178, base 100 — a melee
lifetap-type effect, matching the wiki's one-line description "Heal self for every point of
melee damage dealt while discipline is active"). Id 8642 has an *additional* second effect
(effectid2=184, base 200) not mentioned anywhere in the wiki's discipline description or its
patch-history column (which only notes a duration change, not an added effect). **Keep
8617** (arbitrary pick between the identical pair); **deactivate 8604** (duplicate) and
**8642** (undocumented extra effect not matching the wiki-described mechanic).

### 11. Spirit Tap (levels 55 and 56 — same spell, conflicting level)
Id 8636 is at level 55; id 524 is at level 56. The wiki page body carries the patch note:
"(February 21, 2001) Shadow Knight - 'Moved Spirit Tap to level 55.'" **Keep 8636**;
**deactivate 524** (pre-patch level).

### 12. Drain Spirit (levels 57 and 60 — same spell, conflicting level)
Id 8637 is at level 57; id 525 is at level 60. The wiki page body carries the patch note:
"(February 21, 2001) Shadow Knight - 'Moved Drain Spirit to level 57.'" **Keep 8637**;
**deactivate 525** (pre-patch level).

## Ichor Guard (id 7005, level 56) — not found

No wiki page exists for "Ichor Guard" (title lookup returned missing), a site search on
`wiki.project1999.com` returned zero hits, and a secondary search on `fvproject.com` also
returned zero hits. It does not appear anywhere on the Disciplines page's Shadow Knight
table (which lists exactly four SK disciplines: Resistant, Fearless, Unholy Aura,
Leechcurse — Ichor Guard is not one of them, and `IsDiscipline` is `-1` for this row rather
than the usual `0`/`1`, consistent with it not being a normal player-facing discipline).
Per methodology step 3c ("if it cannot be found anywhere on the wiki, assume it should be
deactivated" — the explicit project-lead default), **flagged for deactivation**. Note: the
row does exist identically in the raw P99 `spells_us.txt` export, granted exclusively to
Shadow Knight at level 56 — so this is not a data-entry error on our side, it is genuinely
P99 content, just undocumented on the wiki and therefore not confirmable as Velious-era
appropriate.

## Full spell table

| id | name | level | current status | P99 verdict | era category | action needed | citation |
|----|------|-------|-----------------|-------------|---------------|----------------|----------|
| 2821 | Harm Touch | 1 | Active | Mechanically wrong (30s recast; doc'd ability is 72-min) | Classic Era (Skill Harm Touch) | deactivate | Skill Harm Touch page + raw export cross-check |
| 88 | Harm Touch | 1 | Active | Mechanically wrong (30s recast; doc'd ability is 72-min) | Classic Era (Skill Harm Touch) | deactivate | Skill Harm Touch page + raw export cross-check |
| 2774 | Harmful Touch | 1 | Active | Confirmed (72-min recast matches) | Classic Era | none | Skill Harm Touch page + raw export cross-check |
| 340 | Disease Cloud | 9 | Active | Confirmed, SK L9 | (untagged) | none | Disease Cloud |
| 235 | Invisibility versus Undead | 9 | Active | Confirmed, SK L9 | Classic Era | none | Invisibility versus Undead |
| 491 | Leering Corpse | 9 | Active | Confirmed, SK L9 | (untagged) | none | Leering Corpse |
| 341 | Lifetap | 9 | Active | Confirmed, SK L9 | (untagged) | none | Lifetap |
| 342 | Locate Corpse | 9 | Active | Confirmed, SK L9 | (untagged) | none | Locate Corpse |
| 221 | Sense the Dead | 9 | Active | Confirmed, SK L9 | Classic Era | none | Sense the Dead |
| 343 | Siphon Strength | 9 | Active | Confirmed, SK L9 | (untagged) | none | Siphon Strength |
| 351 | Bone Walk | 15 | Active | Confirmed, SK L15 | (untagged) | none | Bone Walk |
| 344 | Clinging Darkness | 15 | Active | Confirmed, SK L15 | (untagged) | none | Clinging Darkness |
| 8643 | Endure Cold | 15 | Active | Confirmed, SK L15 (complete class set) | (untagged) | none | Endure Cold + raw export cross-check |
| 225 | Endure Cold | 15 | Active | Incomplete class-grant copy | (untagged) | deactivate-duplicate-keep-other-id (8643) | Endure Cold + raw export cross-check |
| 229 | Fear | 15 | Active | Confirmed, SK L15 | Classic Era | none | Fear |
| 502 | Lifespike | 15 | Active | Confirmed, SK L15 | (untagged) | none | Lifespike |
| 347 | Numb the Dead | 15 | Active | Confirmed, SK L15 | (untagged) | none | Numb the Dead |
| 354 | Shadow Step | 15 | Active | Confirmed, SK L15 | (untagged) | none | Shadow Step |
| 362 | Convoke Shadow | 22 | Active | Confirmed, SK L22 | (untagged) | none | Convoke Shadow |
| 357 | Dark Empathy | 22 | Active | Confirmed, SK L22 | (untagged) | none | Dark Empathy |
| 352 | Deadeye | 22 | Active | Confirmed, SK L22 | (untagged) | none | Deadeye |
| 355 | Engulfing Darkness | 22 | Active | Confirmed, SK L22 | (untagged) | none | Engulfing Darkness |
| 8639 | Grim Aura | 22 | Active | Confirmed, SK L22 | (untagged) | none | Grim Aura |
| 209 | Spook the Dead | 22 | Active | Confirmed, SK L22 | Classic Era | none | Spook the Dead |
| 359 | Vampiric Embrace | 22 | Active | Confirmed, SK L22 | (untagged) | none | Vampiric Embrace |
| 218 | Ward Undead | 22 | Active | Confirmed, SK L22 | Classic Era | none | Ward Undead |
| 1289 | Strengthen Death | 29 | Active | Confirmed, SK L29 | (untagged) | none | Strengthen Death |
| 226 | Endure Disease | 30 | Active | Confirmed, SK L30 | (untagged) | none | Endure Disease |
| 366 | Feign Death | 30 | Active | Confirmed, SK L30 | (untagged) | none | Feign Death |
| 522 | Gather Shadows | 30 | Active | Confirmed, SK L30 | Classic Era | none | Gather Shadows |
| 360 | Heat Blood | 30 | Active | Confirmed, SK L30 | Classic Era | none | Heat Blood |
| 445 | Lifedraw | 30 | Active | Confirmed, SK L30 | Classic Era | none | Lifedraw |
| 492 | Restless Bones | 30 | Active | Confirmed, SK L30 | (untagged) | none | Restless Bones |
| 363 | Wave of Enfeeblement | 30 | Active | Confirmed, SK L30 | (untagged) | none | Wave of Enfeeblement |
| 8640 | Shieldskin | 34 | Active | Confirmed, current level (post Feb-2001 patch) | (untagged) | none | Shieldskin (patch-note text) |
| 8657 | Shieldskin | 34 | Active | Exact duplicate of 8640 | (untagged) | deactivate-duplicate-keep-other-id (8640) | Shieldskin |
| 440 | Animate Dead | 39 | Active | Confirmed, SK L39 | (untagged) | none | Animate Dead |
| 8662 | Cancel Magic | 39 | Active | Exact duplicate of 48 | Classic Era | deactivate-duplicate-keep-other-id (48) | Cancel Magic |
| 48 | Cancel Magic | 39 | Active | Confirmed, SK L39 | Classic Era | none | Cancel Magic |
| 233 | Expulse Undead | 39 | Active | Confirmed, SK L39 | (untagged) | none | Expulse Undead |
| 367 | Heart Flutter | 39 | Active | Confirmed, SK L39 | (untagged) | none | Heart Flutter |
| 61 | Resist Cold | 39 | Active | Incomplete class-grant copy | (untagged) | deactivate-duplicate-keep-other-id (8648) | Resist Cold + raw export cross-check |
| 8648 | Resist Cold | 39 | Active | Confirmed, SK L39 (complete class set) | (untagged) | none | Resist Cold + raw export cross-check |
| 370 | Shadow Vortex | 39 | Active | Confirmed, SK L39 | (untagged) | none | Shadow Vortex |
| 236 | Shieldskin | 39 | Active | Superseded pre-patch level (moved to 34) | (untagged) | deactivate | Shieldskin (patch-note text) |
| 1457 | Shroud of Hate | 39 | Active | Confirmed, SK L39 | (untagged) | none | Shroud of Hate |
| 8660 | Breath of the Dead | 49 | Active | Exact duplicate of 478 | (untagged) | deactivate-duplicate-keep-other-id (478) | Breath of the Dead |
| 478 | Breath of the Dead | 49 | Active | Confirmed, SK L49 | (untagged) | none | Breath of the Dead |
| 117 | Dismiss Undead | 49 | Active | Confirmed, SK L49 | (untagged) | none | Dismiss Undead |
| 452 | Dooming Darkness | 49 | Active | Confirmed, SK L49 | (untagged) | none | Dooming Darkness |
| 127 | Invoke Fear | 49 | Active | Confirmed, SK L49 | Classic Era | none | Invoke Fear |
| 692 | Life Leech | 49 | Active | Confirmed, SK L49 | (untagged) | none | Life Leech |
| 90 | Shadow Sight | 49 | Active | Confirmed, SK L49 | (untagged) | none | Shadow Sight |
| 441 | Summon Dead | 49 | Active | Confirmed, SK L49 | (untagged) | none | Summon Dead |
| 414 | Word of Spirit | 49 | Active | Confirmed, SK L49 | (untagged) | none | Word of Spirit |
| 1458 | Shroud of Pain | 50 | Active | Confirmed, SK L50 | (untagged) | none | Shroud of Pain |
| 8601 | Resistant Discipline | 51 | Active | Confirmed, current duration (post Feb-2001 patch, 5 min) | (untagged) | none | Disciplines (SK table, patch-note column) |
| 8608 | Resistant Discipline | 51 | Active | Pre-patch duration (1 min) | (untagged) | deactivate | Disciplines (SK table, patch-note column) |
| 446 | Siphon Life | 51 | Active | Confirmed, SK L51 | (untagged) | none | Siphon Life |
| 8478 | Summon Corpse | 51 | Active | Confirmed, SK L51 | (untagged) | none | Summon Corpse |
| 442 | Malignant Dead | 52 | Active | Confirmed, SK L52 | (untagged) | none | Malignant Dead |
| 448 | Rest the Dead | 52 | Active | Confirmed, SK L52 | (untagged) | none | Rest the Dead |
| 8621 | Summon Companion | 52 | Active | Confirmed, SK L52, genuine Velious content | Velious Era Inline (SK line) | none | Summon Companion |
| 451 | Boil Blood | 53 | Active | Confirmed, SK L53 | (untagged) | none | Boil Blood |
| 364 | Banshee Aura | 54 | Active | Pre-April-2000 static-value version | (untagged) | deactivate | Banshee Aura (page's own update note) |
| 8572 | Banshee Aura | 54 | Active | Confirmed, current scaling mechanic | (untagged) | none | Banshee Aura (page's own update note) |
| 8609 | Fearless Discipline | 54 | Active | Confirmed, SK L54 | (untagged) | none | Disciplines (SK table) |
| 59 | Panic the Dead | 54 | Active | Confirmed, SK L54 | (untagged) | none | Panic the Dead |
| 1742 | Bobbing Corpse | 55 | Active | Confirmed, SK L55 | (untagged) | none | Bobbing Corpse |
| 662 | Expel Undead | 55 | Active | Incorrect Paladin-level copy | Classic Era (Kunark Era Inline on SK/Pal line) | deactivate-duplicate-keep-other-id (8545) | Expel Undead + raw export cross-check |
| 8545 | Expel Undead | 55 | Active | Confirmed, SK L55 (Kunark-added, valid on Velious server) | Classic Era (Kunark Era Inline on SK/Pal line) | none | Expel Undead + raw export cross-check |
| 1459 | Shroud of Death | 55 | Active | Confirmed, SK L55 | (untagged) | none | Shroud of Death |
| 1376 | Shroud of Undeath | 55 | Active | Confirmed, SK L55 | (untagged) | none | Shroud of Undeath |
| 8636 | Spirit Tap | 55 | Active | Confirmed, current level (post Feb-2001 patch) | (untagged) | none | Spirit Tap (patch-note text) |
| 8618 | Unholy Aura Discipline | 55 | Active | Confirmed (already resolved, ADR-009) | (untagged) | none | Disciplines (SK table); see ADR-009 addendum |
| 7005 | Ichor Guard | 56 | Active | Not found on P99 wiki or fvproject.com; not on SK Disciplines table | unknown | deactivate | Site search (zero results, both sources) |
| 524 | Spirit Tap | 56 | Active | Pre-patch level (moved to 55) | (untagged) | deactivate | Spirit Tap (patch-note text) |
| 393 | Steelskin | 56 | Active | Confirmed, SK L56 | (untagged) | none | Steelskin |
| 8637 | Drain Spirit | 57 | Active | Confirmed, current level (post Feb-2001 patch) | (untagged) | none | Drain Spirit (patch-note text) |
| 454 | Vampiric Curse | 57 | Active | Confirmed, SK L57 | (untagged) | none | Vampiric Curse |
| 495 | Cackling Bones | 58 | Active | Confirmed, SK L58 | (untagged) | none | Cackling Bones |
| 49 | Nullify Magic | 58 | Active | Confirmed, SK L58, genuine Velious content | Classic Era (page); Velious Era Inline (SK line) | none | Nullify Magic |
| 453 | Cascading Darkness | 59 | Active | Confirmed, SK L59 | (untagged) | none | Cascading Darkness |
| 8641 | Diamondskin | 59 | Active | Confirmed, SK L59 (listed as "Shadowknight") | (untagged) | none | Diamondskin |
| 1508 | Asystole | 60 | Active | Confirmed, SK L60 | (untagged) | none | Asystole |
| 1460 | Death Peace | 60 | Active | Confirmed, SK L60 | (untagged) | none | Death Peace |
| 8638 | Drain Soul | 60 | Active | Confirmed, SK L60 (listed as "Shadowknight") | (untagged) | none | Drain Soul |
| 525 | Drain Spirit | 60 | Active | Pre-patch level (moved to 57) | (untagged) | deactivate | Drain Spirit (patch-note text) |
| 8617 | Leechcurse Discipline | 60 | Active | Confirmed, single documented effect | (untagged) | none | Disciplines (SK table) |
| 8604 | Leechcurse Discipline | 60 | Active | Exact duplicate of 8617 | (untagged) | deactivate-duplicate-keep-other-id (8617) | Disciplines (SK table) |
| 8642 | Leechcurse Discipline | 60 | Active | Extra undocumented effect (effectid2) not in wiki description | (untagged) | deactivate | Disciplines (SK table) |

## Recommended next step

Human review of this report, followed by a migration script (per `CODING_STANDARDS.md`)
setting `classes5 = 255` on the 16 ids flagged `deactivate`/`deactivate-duplicate-keep-other-id`
above:

`88, 2821, 225, 8657, 8662, 61, 236, 8660, 8608, 364, 662, 7005, 524, 525, 8604, 8642`

No other columns should change — this audit only concerns activation status, not spell
mechanics (mechanics were already resynced under ADR-019).
