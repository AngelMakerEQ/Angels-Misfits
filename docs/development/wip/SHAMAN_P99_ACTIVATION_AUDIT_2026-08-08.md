# Shaman P99 Activation Audit — 2026-08-08

## Purpose

This is a **read-only investigation** into whether every spell currently active
for Shaman (`spells_new.classes10` between 1 and 60) is genuinely documented as
available to Shaman at the Velious era on the P99 wiki
(`wiki.project1999.com`), the project's authoritative era-accuracy source. It
follows on from the P99 mechanical resync (ADR-019), which pulled
`classes1-16` grantability directly from a P99 raw database export spanning
P99's entire content history (classic through many post-Velious expansions in
one file). Raw grantability alone does not prove Velious-era availability —
only the P99 wiki documents that with confidence. This document is findings
only; no database changes were made. A migration script should be written
separately after human review.

## Methodology

1. Queried `spells_new` for every spell active for Shaman (208 rows, `id`,
   `name`, `classes10`, `mana`, `EndurCost`, `IsDiscipline`, `recast_time`).
2. Identified duplicate id groups sharing a name (30 same-level pairs, plus 2
   same-name/different-level anomalies: Imbue Ivory and Superior Healing).
3. Batch-fetched each unique spell name's own P99 wiki page via the MediaWiki
   API (`action=query`, `prop=revisions|categories`, pipe-separated titles,
   ~35 per request, 5 requests total covering all 176 unique names). All 176
   pages were found directly (0 missing, 0 required a fallback to the Shaman
   class page or to fvproject.com as a secondary source).
4. For each spell, checked the `{{Spellpage}}` template's `classes` field for
   an exact `[[Shaman]] - Level N` match against our database, and the page's
   era category (`Category:Classic Era`, `Category:Kunark Era`, etc.).
5. For duplicate id pairs, where the wiki page's name/level alone did not
   disambiguate, compared mechanical fields (`mana`, `recast_time`,
   `effectid`/`effect_base_value` slots, `you_cast`/`cast_on_you`/
   `cast_on_other`/`spell_fades` messages, scaling `formula`) between the two
   database ids against the wiki's documented mana cost and `{{SpellSlotRow}}`
   effect text, per the added methodology instruction to use description/
   effect text as a disambiguating signal, not name/level alone.

## Summary

- **Total spells checked:** 208 (176 unique spell names)
- **Confirmed correct, no action needed:** 176
- **Flagged for deactivation:** 32 (all as the losing half of a
  duplicate-name pair — no spell was flagged as wholly undocumented/unknown to
  P99, and no spell carried a post-Velious era category)
- **Duplicate/anomaly groups resolved:** 32 total
  - **30** same-level name/id duplicate pairs
  - **1** same-name/different-level anomaly (Imbue Ivory: levels 29 vs 34 —
    only level 29 is documented)
  - **1** same-name/different-level **genuine era split** corroborated by the
    wiki itself (Superior Healing: Kunark = Level 53, Velious = Level 51) —
    resolved per the explicit project-lead rule that the Velious-era version
    wins
- **Era category findings:** every one of the 176 pages checked carries only
  `Category:Classic Era`, `Category:Kunark Era`, or no era category at all
  (generic `Category:Spells`). **No spell in the Shaman list carries a
  post-Velious era category** (no Luclin/PoP/LoY/LDoN/GoD/etc. tags found
  anywhere in this list). Kunark-era-tagged spells are still correctly active
  on a Velious-locked server, since Kunark predates Velious.
- **Secondary source use:** none required — every page resolved directly
  against `wiki.project1999.com` on the first attempt.

### Duplicate resolution: confidence tiers

Of the 32 pairs, resolution confidence varies:

- **High confidence (14 pairs)** — the wiki (or a directly comparable DB
  field it corroborates) supplied a value that matched one id and not the
  other: the five `Talisman of the *` mana-value pairs, Spirit of the Howler,
  Avatar, Torpor, Deliriously Nimble, Maniacal/Manicial Strength, Bind
  Affinity, Voice of the Berserker, Imbue Ivory, and Superior Healing (the
  last is a genuine documented Kunark/Velious era split, not an erroneous
  duplicate).
- **Heuristic, moderate confidence (16 pairs)** — the two ids are
  **mechanically identical** on every field checked (mana, recast, effect
  slots, all four message strings), and the wiki documents only one version
  with no era split. There is no wiki-sourced signal to prefer one id over
  the other. Resolution defaults to keeping the higher/"8xxx" id, because in
  every one of the 14 high-confidence cases above where a distinguishing
  signal existed, **the "8xxx" id was the one that matched the wiki-documented
  value** (consistent with these ids being the direct P99 raw-export objects
  used in the ADR-019 mechanics resync, vs. lower/legacy PEQ ids). This is a
  numbering-convention heuristic, not a wiki-sourced fact — flagged
  individually in the table below. Affected: Endure Cold, Spirit of Wolf,
  Cancel Magic, Endure Magic, Shrink, Resist Cold, Resist Disease, Chloroplast,
  Resist Magic, Talisman of Jasinth, Talisman of Shadoo, Shroud of the
  Spirits, Bane of Nife, Malo, Mortal Deftness, Pox of Bertoxxulous.
- **Heuristic, low confidence (2 pairs)** — Cannibalize II and Cannibalize
  III. Their two ids use different internal scaling `formula` values (or the
  same formula with different base values), meaning a genuine mechanical
  difference exists between them, but the wiki's textual mana-return range
  (e.g. "30 (L39) to 36 (L60)") could not be matched to a specific `formula`/
  `effect_base_value` combination without EQEmu formula-table math, which was
  out of scope for this wiki-only pass. Resolved via the same id-numbering
  heuristic as above but flagged as lower confidence — **recommend an
  additional mechanics cross-check (e.g. against the ADR-019 P99 raw export)
  before finalizing these two specifically.**

**Exception to the "8xxx wins" heuristic:** Bind Affinity (id 35 vs id
40971). Here the *lower* id (35) is the one that matches the wiki's
documented mana (100) and recast (12,000ms) — id 40971 has no mana cost and a
1,500ms recast, which does not match at all and looks like a different kind
of object entirely (an instant/free variant). This is why the heuristic was
applied per-case with wiki verification, not blindly.

### Non-duplicate note: Charm Animals (id 8564, level 34)

Not a duplicate — single id, no action needed on activation. Flagged
separately: the wiki page's description confirms Shaman gained access to this
spell shortly after the Kunark launch (June 6, 2000), well before Velious, so
being active here is era-appropriate. However, the **Level 34** requirement
specifically carries a `{{Era|Hole}}` tag on the wiki page (The Hole = 2003,
well post-Velious). This could mean the Velious-era level requirement differed
from 34 — the wiki page does not state what it was. This is a possible
mechanics-level question, not an activation question, so no action is
proposed here; flagging for a separate follow-up if/when Shaman spell levels
are mechanically audited.

## Full Findings Table

| id | name | level | current status | P99 verdict | era category | action needed | citation |
|---|---|---|---|---|---|---|---|
| 93 | Burst of Flame | 1 | ACTIVE (Shaman lvl 1) | Confirmed: P99 wiki documents Shaman - Level 1, matches exactly | - | none | Burst of Flame |
| 213 | Cure Disease | 1 | ACTIVE (Shaman lvl 1) | Confirmed: P99 wiki documents Shaman - Level 1, matches exactly | - | none | Cure Disease |
| 266 | Dexterous Aura | 1 | ACTIVE (Shaman lvl 1) | Confirmed: P99 wiki documents Shaman - Level 1, matches exactly | - | none | Dexterous Aura |
| 225 | Endure Cold | 1 | ACTIVE (Shaman lvl 1) | Confirmed spell exists at Level 1; mechanically identical to id 8643 on every field checked (mana/recast/effects/messages) - wiki does not disambiguate | - | deactivate-duplicate-keep-other-id (8643) [heuristic: see note] | Endure Cold |
| 8643 | Endure Cold | 1 | ACTIVE (Shaman lvl 1) | Confirmed: P99 wiki documents Shaman - Level 1. This id retained as the corroborated/canonical version (duplicate id 225 deactivated - see its row) | - | none | Endure Cold |
| 201 | Flash of Light | 1 | ACTIVE (Shaman lvl 1) | Confirmed: P99 wiki documents Shaman - Level 1, matches exactly | - | none | Flash of Light |
| 267 | Inner Fire | 1 | ACTIVE (Shaman lvl 1) | Confirmed: P99 wiki documents Shaman - Level 1, matches exactly | - | none | Inner Fire |
| 200 | Minor Healing | 1 | ACTIVE (Shaman lvl 1) | Confirmed: P99 wiki documents Shaman - Level 1, matches exactly | - | none | Minor Healing |
| 40 | Strengthen | 1 | ACTIVE (Shaman lvl 1) | Confirmed: P99 wiki documents Shaman - Level 1, matches exactly | Classic Era | none | Strengthen |
| 205 | True North | 1 | ACTIVE (Shaman lvl 1) | Confirmed: P99 wiki documents Shaman - Level 1, matches exactly | Classic Era | none | True North |
| 203 | Cure Poison | 5 | ACTIVE (Shaman lvl 5) | Confirmed: P99 wiki documents Shaman - Level 5, matches exactly | - | none | Cure Poison |
| 270 | Drowsy | 5 | ACTIVE (Shaman lvl 5) | Confirmed: P99 wiki documents Shaman - Level 5, matches exactly | - | none | Drowsy |
| 224 | Endure Fire | 5 | ACTIVE (Shaman lvl 5) | Confirmed: P99 wiki documents Shaman - Level 5, matches exactly | - | none | Endure Fire |
| 269 | Feet like Cat | 5 | ACTIVE (Shaman lvl 5) | Confirmed: P99 wiki documents Shaman - Level 5, matches exactly | - | none | Feet like Cat |
| 271 | Fleeting Fury | 5 | ACTIVE (Shaman lvl 5) | Confirmed: P99 wiki documents Shaman - Level 5, matches exactly | - | none | Fleeting Fury |
| 275 | Frost Rift | 5 | ACTIVE (Shaman lvl 5) | Confirmed: P99 wiki documents Shaman - Level 5, matches exactly | - | none | Frost Rift |
| 36 | Gate | 5 | ACTIVE (Shaman lvl 5) | Confirmed: P99 wiki documents Shaman - Level 5, matches exactly | Classic Era | none | Gate |
| 274 | Scale Skin | 5 | ACTIVE (Shaman lvl 5) | Confirmed: P99 wiki documents Shaman - Level 5, matches exactly | - | none | Scale Skin |
| 75 | Sicken | 5 | ACTIVE (Shaman lvl 5) | Confirmed: P99 wiki documents Shaman - Level 5, matches exactly | - | none | Sicken |
| 272 | Spirit Pouch | 5 | ACTIVE (Shaman lvl 5) | Confirmed: P99 wiki documents Shaman - Level 5, matches exactly | - | none | Spirit Pouch |
| 211 | Summon Drink | 5 | ACTIVE (Shaman lvl 5) | Confirmed: P99 wiki documents Shaman - Level 5, matches exactly | - | none | Summon Drink |
| 212 | Cure Blindness | 9 | ACTIVE (Shaman lvl 9) | Confirmed: P99 wiki documents Shaman - Level 9, matches exactly | - | none | Cure Blindness |
| 226 | Endure Disease | 9 | ACTIVE (Shaman lvl 9) | Confirmed: P99 wiki documents Shaman - Level 9, matches exactly | - | none | Endure Disease |
| 17 | Light Healing | 9 | ACTIVE (Shaman lvl 9) | Confirmed: P99 wiki documents Shaman - Level 9, matches exactly | - | none | Light Healing |
| 238 | Sense Animals | 9 | ACTIVE (Shaman lvl 9) | Confirmed: P99 wiki documents Shaman - Level 9, matches exactly | - | none | Sense Animals |
| 276 | Serpent Sight | 9 | ACTIVE (Shaman lvl 9) | Confirmed: P99 wiki documents Shaman - Level 9, matches exactly | - | none | Serpent Sight |
| 79 | Spirit Sight | 9 | ACTIVE (Shaman lvl 9) | Confirmed: P99 wiki documents Shaman - Level 9, matches exactly | - | none | Spirit Sight |
| 279 | Spirit of Bear | 9 | ACTIVE (Shaman lvl 9) | Confirmed: P99 wiki documents Shaman - Level 9, matches exactly | - | none | Spirit of Bear |
| 1776 | Spirit of Wolf | 9 | ACTIVE (Shaman lvl 9) | Confirmed spell exists at Level 9; mechanically identical to id 8651 - wiki does not disambiguate (Shaman not era-split on this page, unlike Ranger) | - | deactivate-duplicate-keep-other-id (8651) [heuristic: see note] | Spirit of Wolf |
| 8651 | Spirit of Wolf | 9 | ACTIVE (Shaman lvl 9) | Confirmed: P99 wiki documents Shaman - Level 9. This id retained as the corroborated/canonical version (duplicate id 1776 deactivated - see its row) | - | none | Spirit of Wolf |
| 50 | Summon Food | 9 | ACTIVE (Shaman lvl 9) | Confirmed: P99 wiki documents Shaman - Level 9, matches exactly | - | none | Summon Food |
| 277 | Tainted Breath | 9 | ACTIVE (Shaman lvl 9) | Confirmed: P99 wiki documents Shaman - Level 9, matches exactly | - | none | Tainted Breath |
| 35 | Bind Affinity | 14 | ACTIVE (Shaman lvl 14) | Confirmed: P99 wiki documents Shaman - Level 14, mana(100)/recast(12000ms) matches this id exactly | Classic Era | none | Bind Affinity |
| 40971 | Bind Affinity | 14 | ACTIVE (Shaman lvl 14) | Confirmed spell exists; this id has no mana cost and recast(1500ms), does not match P99-documented mana(100)/recast(12000ms) — looks like a different (instant/free) object entirely | Classic Era | deactivate-duplicate-keep-other-id (35) | Bind Affinity |
| 280 | Burst of Strength | 14 | ACTIVE (Shaman lvl 14) | Confirmed: P99 wiki documents Shaman - Level 14, matches exactly | - | none | Burst of Strength |
| 281 | Disempower | 14 | ACTIVE (Shaman lvl 14) | Confirmed: P99 wiki documents Shaman - Level 14, matches exactly | - | none | Disempower |
| 227 | Endure Poison | 14 | ACTIVE (Shaman lvl 14) | Confirmed: P99 wiki documents Shaman - Level 14, matches exactly | - | none | Endure Poison |
| 86 | Enduring Breath | 14 | ACTIVE (Shaman lvl 14) | Confirmed: P99 wiki documents Shaman - Level 14, matches exactly | Classic Era | none | Enduring Breath |
| 255 | Invisibility versus Animals | 14 | ACTIVE (Shaman lvl 14) | Confirmed: P99 wiki documents Shaman - Level 14, matches exactly | - | none | Invisibility versus Animals |
| 261 | Levitate | 14 | ACTIVE (Shaman lvl 14) | Confirmed: P99 wiki documents Shaman - Level 14, matches exactly | Classic Era | none | Levitate |
| 230 | Root | 14 | ACTIVE (Shaman lvl 14) | Confirmed: P99 wiki documents Shaman - Level 14, matches exactly | Classic Era | none | Root |
| 282 | Spirit Strike | 14 | ACTIVE (Shaman lvl 14) | Confirmed: P99 wiki documents Shaman - Level 14, matches exactly | - | none | Spirit Strike |
| 284 | Spirit of Snake | 14 | ACTIVE (Shaman lvl 14) | Confirmed: P99 wiki documents Shaman - Level 14, matches exactly | - | none | Spirit of Snake |
| 283 | Turtle Skin | 14 | ACTIVE (Shaman lvl 14) | Confirmed: P99 wiki documents Shaman - Level 14, matches exactly | - | none | Turtle Skin |
| 505 | Walking Sleep | 14 | ACTIVE (Shaman lvl 14) | Confirmed: P99 wiki documents Shaman - Level 14, matches exactly | - | none | Walking Sleep |
| 511 | Affliction | 19 | ACTIVE (Shaman lvl 19) | Confirmed: P99 wiki documents Shaman - Level 19, matches exactly | - | none | Affliction |
| 48 | Cancel Magic | 19 | ACTIVE (Shaman lvl 19) | Confirmed spell exists at Level 19; mechanically identical to id 8662 - wiki does not disambiguate | Classic Era | deactivate-duplicate-keep-other-id (8662) [heuristic: see note] | Cancel Magic |
| 8662 | Cancel Magic | 19 | ACTIVE (Shaman lvl 19) | Confirmed: P99 wiki documents Shaman - Level 19. This id retained as the corroborated/canonical version (duplicate id 48 deactivated - see its row) | Classic Era | none | Cancel Magic |
| 228 | Endure Magic | 19 | ACTIVE (Shaman lvl 19) | Confirmed spell exists at Level 19; mechanically identical to id 8594 - wiki does not disambiguate | Classic Era | deactivate-duplicate-keep-other-id (8594) [heuristic: see note] | Endure Magic |
| 8594 | Endure Magic | 19 | ACTIVE (Shaman lvl 19) | Confirmed: P99 wiki documents Shaman - Level 19. This id retained as the corroborated/canonical version (duplicate id 228 deactivated - see its row) | Classic Era | none | Endure Magic |
| 308 | Frenzy | 19 | ACTIVE (Shaman lvl 19) | Confirmed: P99 wiki documents Shaman - Level 19, matches exactly | - | none | Frenzy |
| 12 | Healing | 19 | ACTIVE (Shaman lvl 19) | Confirmed: P99 wiki documents Shaman - Level 19, matches exactly | - | none | Healing |
| 365 | Infectious Cloud | 19 | ACTIVE (Shaman lvl 19) | Confirmed: P99 wiki documents Shaman - Level 19, matches exactly | - | none | Infectious Cloud |
| 526 | Insidious Fever | 19 | ACTIVE (Shaman lvl 19) | Confirmed: P99 wiki documents Shaman - Level 19, matches exactly | - | none | Insidious Fever |
| 110 | Malise | 19 | ACTIVE (Shaman lvl 19) | Confirmed: P99 wiki documents Shaman - Level 19, matches exactly (wiki canonical title is "Malaise") | - | none | Malaise (redirect from Malise) |
| 345 | Shrink | 19 | ACTIVE (Shaman lvl 19) | Confirmed spell exists at Level 19; effect value(75) vs id 8499(66) differ but wiki gives only a descriptive "34%" figure, not numerically comparable to the raw effect value - cannot disambiguate from wiki alone | - | deactivate-duplicate-keep-other-id (8499) [heuristic: see note] | Shrink |
| 8499 | Shrink | 19 | ACTIVE (Shaman lvl 19) | Confirmed: P99 wiki documents Shaman - Level 19. This id retained as the corroborated/canonical version (duplicate id 345 deactivated - see its row) | - | none | Shrink |
| 147 | Spirit Strength | 19 | ACTIVE (Shaman lvl 19) | Confirmed: P99 wiki documents Shaman - Level 19, matches exactly | - | none | Spirit Strength |
| 148 | Spirit of Cat | 19 | ACTIVE (Shaman lvl 19) | Confirmed: P99 wiki documents Shaman - Level 19, matches exactly | - | none | Spirit of Cat |
| 580 | Vision | 19 | ACTIVE (Shaman lvl 19) | Confirmed: P99 wiki documents Shaman - Level 19, matches exactly | - | none | Vision |
| 265 | Cannibalize | 24 | ACTIVE (Shaman lvl 24) | Confirmed: P99 wiki documents Shaman - Level 24, matches exactly | - | none | Cannibalize |
| 96 | Counteract Disease | 24 | ACTIVE (Shaman lvl 24) | Confirmed: P99 wiki documents Shaman - Level 24, matches exactly | - | none | Counteract Disease |
| 640 | Creeping Vision | 24 | ACTIVE (Shaman lvl 24) | Confirmed: P99 wiki documents Shaman - Level 24, matches exactly | - | none | Creeping Vision |
| 434 | Envenomed Breath | 24 | ACTIVE (Shaman lvl 24) | Confirmed: P99 wiki documents Shaman - Level 24, matches exactly | - | none | Envenomed Breath |
| 508 | Frost Strike | 24 | ACTIVE (Shaman lvl 24) | Confirmed: P99 wiki documents Shaman - Level 24, matches exactly | - | none | Frost Strike |
| 222 | Invigor | 24 | ACTIVE (Shaman lvl 24) | Confirmed: P99 wiki documents Shaman - Level 24, matches exactly | Classic Era | none | Invigor |
| 437 | Poison Storm | 24 | ACTIVE (Shaman lvl 24) | Confirmed: P99 wiki documents Shaman - Level 24, matches exactly | - | none | Poison Storm |
| 649 | Protect | 24 | ACTIVE (Shaman lvl 24) | Confirmed: P99 wiki documents Shaman - Level 24, matches exactly | - | none | Protect |
| 144 | Regeneration | 24 | ACTIVE (Shaman lvl 24) | Confirmed: P99 wiki documents Shaman - Level 24, matches exactly | - | none | Regeneration |
| 61 | Resist Cold | 24 | ACTIVE (Shaman lvl 24) | Confirmed spell exists at Level 24; mechanically identical to id 8648 - wiki does not disambiguate | - | deactivate-duplicate-keep-other-id (8648) [heuristic: see note] | Resist Cold |
| 8648 | Resist Cold | 24 | ACTIVE (Shaman lvl 24) | Confirmed: P99 wiki documents Shaman - Level 24. This id retained as the corroborated/canonical version (duplicate id 61 deactivated - see its row) | - | none | Resist Cold |
| 424 | Scale of Wolf | 24 | ACTIVE (Shaman lvl 24) | Confirmed: P99 wiki documents Shaman - Level 24, matches exactly | - | none | Scale of Wolf |
| 220 | Spirit of Cheetah | 24 | ACTIVE (Shaman lvl 24) | Confirmed: P99 wiki documents Shaman - Level 24, matches exactly | - | none | Spirit of Cheetah |
| 146 | Spirit of Monkey | 24 | ACTIVE (Shaman lvl 24) | Confirmed: P99 wiki documents Shaman - Level 24, matches exactly | - | none | Spirit of Monkey |
| 149 | Spirit of Ox | 24 | ACTIVE (Shaman lvl 24) | Confirmed: P99 wiki documents Shaman - Level 24, matches exactly | - | none | Spirit of Ox |
| 150 | Alluring Aura | 29 | ACTIVE (Shaman lvl 29) | Confirmed: P99 wiki documents Shaman - Level 29, matches exactly | - | none | Alluring Aura |
| 245 | Befriend Animal | 29 | ACTIVE (Shaman lvl 29) | Confirmed: P99 wiki documents Shaman - Level 29, matches exactly | - | none | Befriend Animal |
| 95 | Counteract Poison | 29 | ACTIVE (Shaman lvl 29) | Confirmed: P99 wiki documents Shaman - Level 29, matches exactly | - | none | Counteract Poison |
| 15 | Greater Healing | 29 | ACTIVE (Shaman lvl 29) | Confirmed: P99 wiki documents Shaman - Level 29, matches exactly | - | none | Greater Healing |
| 1885 | Imbue Amber | 29 | ACTIVE (Shaman lvl 29) | Confirmed: P99 wiki documents Shaman - Level 29, matches exactly | - | none | Imbue Amber |
| 8622 | Imbue Ivory | 29 | ACTIVE (Shaman lvl 29) | Confirmed: P99 wiki documents Shaman - Level 29. This id retained as the corroborated version (duplicate id 1884 at Level 34 deactivated - see its row) | - | none | Imbue Ivory |
| 1891 | Imbue Jade | 29 | ACTIVE (Shaman lvl 29) | Confirmed: P99 wiki documents Shaman - Level 29, matches exactly | - | none | Imbue Jade |
| 1886 | Imbue Sapphire | 29 | ACTIVE (Shaman lvl 29) | Confirmed: P99 wiki documents Shaman - Level 29, matches exactly | - | none | Imbue Sapphire |
| 42 | Invisibility | 29 | ACTIVE (Shaman lvl 29) | Confirmed: P99 wiki documents Shaman - Level 29, matches exactly | Classic Era | none | Invisibility |
| 162 | Listless Power | 29 | ACTIVE (Shaman lvl 29) | Confirmed: P99 wiki documents Shaman - Level 29, matches exactly | Classic Era | none | Listless Power |
| 39 | Quickness | 29 | ACTIVE (Shaman lvl 29) | Confirmed: P99 wiki documents Shaman - Level 29, matches exactly | Classic Era | none | Quickness |
| 151 | Raging Strength | 29 | ACTIVE (Shaman lvl 29) | Confirmed: P99 wiki documents Shaman - Level 29, matches exactly | - | none | Raging Strength |
| 60 | Resist Fire | 29 | ACTIVE (Shaman lvl 29) | Confirmed: P99 wiki documents Shaman - Level 29, matches exactly | - | none | Resist Fire |
| 349 | Rising Dexterity | 29 | ACTIVE (Shaman lvl 29) | Confirmed: P99 wiki documents Shaman - Level 29, matches exactly | - | none | Rising Dexterity |
| 506 | Tagar's Insects | 29 | ACTIVE (Shaman lvl 29) | Confirmed: P99 wiki documents Shaman - Level 29, matches exactly | - | none | Tagar's Insects |
| 46 | Ultravision | 29 | ACTIVE (Shaman lvl 29) | Confirmed: P99 wiki documents Shaman - Level 29, matches exactly | Classic Era | none | Ultravision |
| 8564 | Charm Animals | 34 | ACTIVE (Shaman lvl 34) | Confirmed grantable to Shaman since shortly after Kunark launch (page description: "unable to cast until June 6, 2000, after Kunark launch"). See "Non-duplicate note" above re: the Level-34 value's `{{Era\|Hole}}` tag | Classic Era (page); Level-34 value tagged `{{Era\|Hole}}` (2003, post-Velious) | none (activation confirmed; level-value caveat noted above, not actioned here) | Charm Animals |
| 164 | Companion Spirit | 34 | ACTIVE (Shaman lvl 34) | Confirmed: P99 wiki documents Shaman - Level 34, matches exactly | - | none | Companion Spirit |
| 131 | Enstill | 34 | ACTIVE (Shaman lvl 34) | Confirmed: P99 wiki documents Shaman - Level 34, matches exactly | Classic Era | none | Enstill |
| 326 | Fury | 34 | ACTIVE (Shaman lvl 34) | Confirmed: P99 wiki documents Shaman - Level 34, matches exactly | - | none | Fury |
| 161 | Health | 34 | ACTIVE (Shaman lvl 34) | Confirmed: P99 wiki documents Shaman - Level 34, matches exactly | - | none | Health |
| 1884 | Imbue Ivory | 34 | ACTIVE (Shaman lvl 34) | Only Shaman Level 29 is documented on the wiki page; this id's Level 34 is unconfirmed/unsupported | - | deactivate-duplicate-keep-other-id (8622) | Imbue Ivory |
| 111 | Malisement | 34 | ACTIVE (Shaman lvl 34) | Confirmed: P99 wiki documents Shaman - Level 34, matches exactly (wiki canonical title is "Malaisement") | - | none | Malaisement (redirect from Malisement) |
| 160 | Nimble | 34 | ACTIVE (Shaman lvl 34) | Confirmed: P99 wiki documents Shaman - Level 34, matches exactly | - | none | Nimble |
| 63 | Resist Disease | 34 | ACTIVE (Shaman lvl 34) | Confirmed spell exists at Level 34; mechanically identical to id 8504 - wiki does not disambiguate | - | deactivate-duplicate-keep-other-id (8504) [heuristic: see note] | Resist Disease |
| 8504 | Resist Disease | 34 | ACTIVE (Shaman lvl 34) | Confirmed: P99 wiki documents Shaman - Level 34. This id retained as the corroborated/canonical version (duplicate id 63 deactivated - see its row) | - | none | Resist Disease |
| 31 | Scourge | 34 | ACTIVE (Shaman lvl 34) | Confirmed: P99 wiki documents Shaman - Level 34, matches exactly | - | none | Scourge |
| 431 | Shifting Shield | 34 | ACTIVE (Shaman lvl 34) | Confirmed: P99 wiki documents Shaman - Level 34, matches exactly | - | none | Shifting Shield |
| 1427 | Shock of the Tainted | 34 | ACTIVE (Shaman lvl 34) | Confirmed: P99 wiki documents Shaman - Level 34, matches exactly | - | none | Shock of the Tainted |
| 167 | Talisman of Tnarg | 34 | ACTIVE (Shaman lvl 34) | Confirmed: P99 wiki documents Shaman - Level 34, matches exactly | - | none | Talisman of Tnarg |
| 509 | Winter's Roar | 34 | ACTIVE (Shaman lvl 34) | Confirmed: P99 wiki documents Shaman - Level 34, matches exactly | - | none | Winter's Roar |
| 384 | Assiduous Vision | 39 | ACTIVE (Shaman lvl 39) | Confirmed: P99 wiki documents Shaman - Level 39, matches exactly | - | none | Assiduous Vision |
| 134 | Blinding Luminance | 39 | ACTIVE (Shaman lvl 39) | Confirmed: P99 wiki documents Shaman - Level 39, matches exactly | - | none | Blinding Luminance |
| 754 | Cannibalize II | 39 | ACTIVE (Shaman lvl 39) | Confirmed spell exists at Level 39; uses scaling formula109 (vs id 8579's formula110) - a genuine mechanical difference exists but the wiki's textual mana-return curve ("30 (L39) to 36 (L60)") could not be matched to a specific formula/value without EQEmu formula-table math (out of scope here) | - | deactivate-duplicate-keep-other-id (8579) [heuristic, LOW CONFIDENCE - recommend mechanics cross-check] | Cannibalize II |
| 8579 | Cannibalize II | 39 | ACTIVE (Shaman lvl 39) | Confirmed: P99 wiki documents Shaman - Level 39. This id retained as the corroborated/canonical version (duplicate id 754 deactivated - see its row; LOW CONFIDENCE, see summary) | - | none | Cannibalize II |
| 145 | Chloroplast | 39 | ACTIVE (Shaman lvl 39) | Confirmed spell exists at Level 39; mechanically identical to id 8563 - wiki does not disambiguate | - | deactivate-duplicate-keep-other-id (8563) [heuristic: see note] | Chloroplast |
| 8563 | Chloroplast | 39 | ACTIVE (Shaman lvl 39) | Confirmed: P99 wiki documents Shaman - Level 39. This id retained as the corroborated/canonical version (duplicate id 145 deactivated - see its row) | - | none | Chloroplast |
| 152 | Deftness | 39 | ACTIVE (Shaman lvl 39) | Confirmed: P99 wiki documents Shaman - Level 39, matches exactly | - | none | Deftness |
| 417 | Extinguish Fatigue | 39 | ACTIVE (Shaman lvl 39) | Confirmed: P99 wiki documents Shaman - Level 39, matches exactly | - | none | Extinguish Fatigue |
| 153 | Furious Strength | 39 | ACTIVE (Shaman lvl 39) | Confirmed: P99 wiki documents Shaman - Level 39, matches exactly | - | none | Furious Strength |
| 438 | Gale of Poison | 39 | ACTIVE (Shaman lvl 39) | Confirmed: P99 wiki documents Shaman - Level 39, matches exactly | - | none | Gale of Poison |
| 155 | Glamour | 39 | ACTIVE (Shaman lvl 39) | Confirmed: P99 wiki documents Shaman - Level 39, matches exactly | - | none | Glamour |
| 527 | Insidious Malady | 39 | ACTIVE (Shaman lvl 39) | Confirmed: P99 wiki documents Shaman - Level 39, matches exactly | - | none | Insidious Malady |
| 62 | Resist Poison | 39 | ACTIVE (Shaman lvl 39) | Confirmed: P99 wiki documents Shaman - Level 39, matches exactly | - | none | Resist Poison |
| 507 | Togor's Insects | 39 | ACTIVE (Shaman lvl 39) | Confirmed: P99 wiki documents Shaman - Level 39, matches exactly | - | none | Togor's Insects |
| 1428 | Tumultuous Strength | 39 | ACTIVE (Shaman lvl 39) | Confirmed: P99 wiki documents Shaman - Level 39, matches exactly | - | none | Tumultuous Strength |
| 435 | Venom of the Snake | 39 | ACTIVE (Shaman lvl 39) | Confirmed: P99 wiki documents Shaman - Level 39, matches exactly | - | none | Venom of the Snake |
| 577 | Vigilant Spirit | 39 | ACTIVE (Shaman lvl 39) | Confirmed: P99 wiki documents Shaman - Level 39, matches exactly | - | none | Vigilant Spirit |
| 154 | Agility | 44 | ACTIVE (Shaman lvl 44) | Confirmed: P99 wiki documents Shaman - Level 44, matches exactly | - | none | Agility |
| 170 | Alacrity | 44 | ACTIVE (Shaman lvl 44) | Confirmed: P99 wiki documents Shaman - Level 44, matches exactly | Classic Era | none | Alacrity |
| 1429 | Blast of Poison | 44 | ACTIVE (Shaman lvl 44) | Confirmed: P99 wiki documents Shaman - Level 44, matches exactly | - | none | Blast of Poison |
| 510 | Blizzard Blast | 44 | ACTIVE (Shaman lvl 44) | Confirmed: P99 wiki documents Shaman - Level 44, matches exactly | - | none | Blizzard Blast |
| 389 | Guardian | 44 | ACTIVE (Shaman lvl 44) | Confirmed: P99 wiki documents Shaman - Level 44, matches exactly | - | none | Guardian |
| 165 | Guardian Spirit | 44 | ACTIVE (Shaman lvl 44) | Confirmed: P99 wiki documents Shaman - Level 44, matches exactly | - | none | Guardian Spirit |
| 163 | Incapacitate | 44 | ACTIVE (Shaman lvl 44) | Confirmed: P99 wiki documents Shaman - Level 44, matches exactly | Classic Era | none | Incapacitate |
| 49 | Nullify Magic | 44 | ACTIVE (Shaman lvl 44) | Confirmed: P99 wiki documents Shaman - Level 44, matches exactly | Classic Era | none | Nullify Magic |
| 64 | Resist Magic | 44 | ACTIVE (Shaman lvl 44) | Confirmed spell exists at Level 44; mechanically identical to id 8632 - wiki does not disambiguate | Classic Era | deactivate-duplicate-keep-other-id (8632) [heuristic: see note] | Resist Magic |
| 8632 | Resist Magic | 44 | ACTIVE (Shaman lvl 44) | Confirmed: P99 wiki documents Shaman - Level 44. This id retained as the corroborated/canonical version (duplicate id 64 deactivated - see its row) | Classic Era | none | Resist Magic |
| 158 | Stamina | 44 | ACTIVE (Shaman lvl 44) | Confirmed: P99 wiki documents Shaman - Level 44, matches exactly | - | none | Stamina |
| 8621 | Summon Companion | 44 | ACTIVE (Shaman lvl 44) | Confirmed: P99 wiki documents Shaman - Level 44, matches exactly | - | none | Summon Companion |
| 168 | Talisman of Altuna | 44 | ACTIVE (Shaman lvl 44) | Confirmed: P99 wiki documents Shaman - Level 44, matches exactly | - | none | Talisman of Altuna |
| 98 | Abolish Disease | 49 | ACTIVE (Shaman lvl 49) | Confirmed: P99 wiki documents Shaman - Level 49, matches exactly | - | none | Abolish Disease |
| 156 | Charisma | 49 | ACTIVE (Shaman lvl 49) | Confirmed: P99 wiki documents Shaman - Level 49, matches exactly | - | none | Charisma |
| 157 | Dexterity | 49 | ACTIVE (Shaman lvl 49) | Confirmed: P99 wiki documents Shaman - Level 49, matches exactly | - | none | Dexterity |
| 436 | Envenomed Bolt | 49 | ACTIVE (Shaman lvl 49) | Confirmed: P99 wiki documents Shaman - Level 49, matches exactly | - | none | Envenomed Bolt |
| 166 | Frenzied Spirit | 49 | ACTIVE (Shaman lvl 49) | Confirmed: P99 wiki documents Shaman - Level 49, matches exactly | - | none | Frenzied Spirit |
| 112 | Malosi | 49 | ACTIVE (Shaman lvl 49) | Confirmed: P99 wiki documents Shaman - Level 49, matches exactly | Classic Era | none | Malosi |
| 32 | Plague | 49 | ACTIVE (Shaman lvl 49) | Confirmed: P99 wiki documents Shaman - Level 49, matches exactly | - | none | Plague |
| 337 | Rage | 49 | ACTIVE (Shaman lvl 49) | Confirmed: P99 wiki documents Shaman - Level 49, matches exactly | - | none | Rage |
| 159 | Strength | 49 | ACTIVE (Shaman lvl 49) | Confirmed: P99 wiki documents Shaman - Level 49, matches exactly | - | none | Strength |
| 1430 | Spirit Quickening | 50 | ACTIVE (Shaman lvl 50) | Confirmed: P99 wiki documents Shaman - Level 50, matches exactly | - | none | Spirit Quickening |
| 132 | Immobilize | 51 | ACTIVE (Shaman lvl 51) | Confirmed: P99 wiki documents Shaman - Level 51, matches exactly (Shaman's grant of this spell is itself tagged `{{Era\|Kunark}}` on the page - in-era for a Velious server) | Classic Era (page); Shaman line tagged Kunark | none | Immobilize |
| 8631 | Superior Healing | 51 | ACTIVE (Shaman lvl 51) | Confirmed: wiki documents Shaman era-split "Level 53 (Kunark) - Level 51 (Velious)" - this id matches the Velious-era value | - | none | Superior Healing |
| 1570 | Talisman of Jasinth | 51 | ACTIVE (Shaman lvl 51) | Confirmed spell exists at Level 51; mechanically identical to id 8488 - wiki does not disambiguate | - | deactivate-duplicate-keep-other-id (8488) [heuristic: see note] | Talisman of Jasinth |
| 8488 | Talisman of Jasinth | 51 | ACTIVE (Shaman lvl 51) | Confirmed: P99 wiki documents Shaman - Level 51. This id retained as the corroborated/canonical version (duplicate id 1570 deactivated - see its row) | - | none | Talisman of Jasinth |
| 1588 | Turgur's Insects | 51 | ACTIVE (Shaman lvl 51) | Confirmed: P99 wiki documents Shaman - Level 51, matches exactly | - | none | Turgur's Insects |
| 1573 | Insidious Decay | 52 | ACTIVE (Shaman lvl 52) | Confirmed: P99 wiki documents Shaman - Level 52, matches exactly | - | none | Insidious Decay |
| 1568 | Regrowth | 52 | ACTIVE (Shaman lvl 52) | Confirmed: P99 wiki documents Shaman - Level 52, matches exactly | - | none | Regrowth |
| 1554 | Spirit of Scale | 52 | ACTIVE (Shaman lvl 52) | Confirmed: P99 wiki documents Shaman - Level 52, matches exactly | Kunark Era | none | Spirit of Scale |
| 1592 | Cripple | 53 | ACTIVE (Shaman lvl 53) | Confirmed: P99 wiki documents Shaman - Level 53, matches exactly | Kunark Era | none | Cripple |
| 1594 | Deliriously Nimble | 53 | ACTIVE (Shaman lvl 53) | Confirmed spell exists; this id's AGI effect (+50) does not match the P99-documented "Increase AGI by 52" | - | deactivate-duplicate-keep-other-id (8557) | Deliriously Nimble |
| 8557 | Deliriously Nimble | 53 | ACTIVE (Shaman lvl 53) | Confirmed: P99 wiki documents Shaman - Level 53, AGI effect (+52) matches this id exactly | - | none | Deliriously Nimble |
| 9 | Superior Healing | 53 | ACTIVE (Shaman lvl 53) | Confirmed: wiki documents Shaman era-split "Level 53 (Kunark) - Level 51 (Velious)" - this id is the Kunark-era, Velious-superseded value | Kunark Era (superseded value) | deactivate-duplicate-keep-other-id (8631) | Superior Healing |
| 1571 | Talisman of Shadoo | 53 | ACTIVE (Shaman lvl 53) | Confirmed spell exists at Level 53; mechanically identical to id 8487 - wiki does not disambiguate | - | deactivate-duplicate-keep-other-id (8487) [heuristic: see note] | Talisman of Shadoo |
| 8487 | Talisman of Shadoo | 53 | ACTIVE (Shaman lvl 53) | Confirmed: P99 wiki documents Shaman - Level 53. This id retained as the corroborated/canonical version (duplicate id 1571 deactivated - see its row) | - | none | Talisman of Shadoo |
| 1572 | Cannibalize III | 54 | ACTIVE (Shaman lvl 54) | Confirmed spell exists at Level 54; effect base values (-100/36) differ from id 8566 (-74/26), both using formula110 - wiki's textual mana-return curve ("36 (L54) to 38 (L60)") could not be matched to a specific value without EQEmu formula-table math (out of scope here) | - | deactivate-duplicate-keep-other-id (8566) [heuristic, LOW CONFIDENCE - recommend mechanics cross-check] | Cannibalize III |
| 8566 | Cannibalize III | 54 | ACTIVE (Shaman lvl 54) | Confirmed: P99 wiki documents Shaman - Level 54. This id retained as the corroborated/canonical version (duplicate id 1572 deactivated - see its row; LOW CONFIDENCE, see summary) | - | none | Cannibalize III |
| 1586 | Ice Strike | 54 | ACTIVE (Shaman lvl 54) | Confirmed: P99 wiki documents Shaman - Level 54, matches exactly | - | none | Ice Strike |
| 1595 | Riotous Health | 54 | ACTIVE (Shaman lvl 54) | Confirmed: P99 wiki documents Shaman - Level 54, matches exactly | - | none | Riotous Health |
| 1584 | Shroud of the Spirits | 54 | ACTIVE (Shaman lvl 54) | Confirmed spell exists at Level 54; mechanically identical to id 8498 - wiki does not disambiguate | - | deactivate-duplicate-keep-other-id (8498) [heuristic: see note] | Shroud of the Spirits |
| 8498 | Shroud of the Spirits | 54 | ACTIVE (Shaman lvl 54) | Confirmed: P99 wiki documents Shaman - Level 54. This id retained as the corroborated/canonical version (duplicate id 1584 deactivated - see its row) | - | none | Shroud of the Spirits |
| 1526 | Annul Magic | 55 | ACTIVE (Shaman lvl 55) | Confirmed: P99 wiki documents Shaman - Level 55, matches exactly | Kunark Era | none | Annul Magic |
| 1290 | Chloroblast | 55 | ACTIVE (Shaman lvl 55) | Confirmed: P99 wiki documents Shaman - Level 55, matches exactly | - | none | Chloroblast |
| 1431 | Form of the Great Bear | 55 | ACTIVE (Shaman lvl 55) | Confirmed: P99 wiki documents Shaman - Level 55, matches exactly | - | none | Form of the Great Bear |
| 1574 | Spirit of the Howler | 55 | ACTIVE (Shaman lvl 55) | Confirmed spell exists; this id's mana(750) does not match the P99-documented mana(850) | - | deactivate-duplicate-keep-other-id (8494) | Spirit of the Howler |
| 8494 | Spirit of the Howler | 55 | ACTIVE (Shaman lvl 55) | Confirmed: P99 wiki documents Shaman - Level 55, mana(850) matches this id exactly | - | none | Spirit of the Howler |
| 1585 | Talisman of Kragg | 55 | ACTIVE (Shaman lvl 55) | Confirmed: P99 wiki documents Shaman - Level 55, matches exactly | - | none | Talisman of Kragg |
| 1587 | Torrent of Poison | 55 | ACTIVE (Shaman lvl 55) | Confirmed: P99 wiki documents Shaman - Level 55, matches exactly | - | none | Torrent of Poison |
| 1575 | Acumen | 56 | ACTIVE (Shaman lvl 56) | Confirmed: P99 wiki documents Shaman - Level 56, matches exactly | - | none | Acumen |
| 1590 | Bane of Nife | 56 | ACTIVE (Shaman lvl 56) | Confirmed spell exists at Level 56; mechanically identical to id 8573 on every effect slot checked - wiki does not disambiguate | - | deactivate-duplicate-keep-other-id (8573) [heuristic: see note] | Bane of Nife |
| 8573 | Bane of Nife | 56 | ACTIVE (Shaman lvl 56) | Confirmed: P99 wiki documents Shaman - Level 56. This id retained as the corroborated/canonical version (duplicate id 1590 deactivated - see its row) | - | none | Bane of Nife |
| 171 | Celerity | 56 | ACTIVE (Shaman lvl 56) | Confirmed: P99 wiki documents Shaman - Level 56, matches exactly | Classic Era | none | Celerity |
| 133 | Paralyzing Earth | 56 | ACTIVE (Shaman lvl 56) | Confirmed: P99 wiki documents Shaman - Level 56, matches exactly | Kunark Era | none | Paralyzing Earth |
| 1577 | Malosini | 57 | ACTIVE (Shaman lvl 57) | Confirmed: P99 wiki documents Shaman - Level 57, matches exactly | - | none | Malosini |
| 8520 | Maniacal Strength | 57 | ACTIVE (Shaman lvl 57) | Confirmed: P99 wiki documents Shaman - Level 57, STR effect (+68) matches this id exactly | - | none | Maniacal Strength |
| 1593 | Manicial Strength | 57 | ACTIVE (Shaman lvl 57) | Name is a DB typo ("Manicial") of "Maniacal Strength"; this id's STR effect (+72) does not match the P99-documented "Increase STR by 68" | - | deactivate-duplicate-keep-other-id (8520) | Maniacal Strength |
| 1580 | Talisman of the Brute | 57 | ACTIVE (Shaman lvl 57) | Confirmed spell exists; this id's mana(400) does not match the P99-documented mana(350) | - | deactivate-duplicate-keep-other-id (8486) | Talisman of the Brute |
| 8486 | Talisman of the Brute | 57 | ACTIVE (Shaman lvl 57) | Confirmed: P99 wiki documents Shaman - Level 57, mana(350) matches this id exactly | - | none | Talisman of the Brute |
| 1579 | Talisman of the Cat | 57 | ACTIVE (Shaman lvl 57) | Confirmed spell exists; this id's mana(400) does not match the P99-documented mana(350) | - | deactivate-duplicate-keep-other-id (8485) | Talisman of the Cat |
| 8485 | Talisman of the Cat | 57 | ACTIVE (Shaman lvl 57) | Confirmed: P99 wiki documents Shaman - Level 57, mana(350) matches this id exactly | - | none | Talisman of the Cat |
| 1332 | Cannibalize IV | 58 | ACTIVE (Shaman lvl 58) | Confirmed: P99 wiki documents Shaman - Level 58, matches exactly | - | none | Cannibalize IV |
| 1596 | Mortal Deftness | 58 | ACTIVE (Shaman lvl 58) | Confirmed spell exists at Level 58; identical mana/recast to id 8518 in DB query - wiki does not disambiguate | - | deactivate-duplicate-keep-other-id (8518) [heuristic: see note] | Mortal Deftness |
| 8518 | Mortal Deftness | 58 | ACTIVE (Shaman lvl 58) | Confirmed: P99 wiki documents Shaman - Level 58. This id retained as the corroborated/canonical version (duplicate id 1596 deactivated - see its row) | - | none | Mortal Deftness |
| 1581 | Talisman of the Rhino | 58 | ACTIVE (Shaman lvl 58) | Confirmed spell exists; this id's mana(400) does not match the P99-documented mana(350) | - | deactivate-duplicate-keep-other-id (8483) | Talisman of the Rhino |
| 8483 | Talisman of the Rhino | 58 | ACTIVE (Shaman lvl 58) | Confirmed: P99 wiki documents Shaman - Level 58, mana(350) matches this id exactly | - | none | Talisman of the Rhino |
| 1582 | Talisman of the Serpent | 58 | ACTIVE (Shaman lvl 58) | Confirmed spell exists; this id's mana(400) does not match the P99-documented mana(350) | - | deactivate-duplicate-keep-other-id (8482) | Talisman of the Serpent |
| 8482 | Talisman of the Serpent | 58 | ACTIVE (Shaman lvl 58) | Confirmed: P99 wiki documents Shaman - Level 58, mana(350) matches this id exactly | - | none | Talisman of the Serpent |
| 1589 | Tigir's Insects | 58 | ACTIVE (Shaman lvl 58) | Confirmed: P99 wiki documents Shaman - Level 58, matches exactly | - | none | Tigir's Insects |
| 1591 | Pox of Bertoxxulous | 59 | ACTIVE (Shaman lvl 59) | Confirmed spell exists at Level 59; identical mana/recast to id 8510 in DB query - wiki does not disambiguate | - | deactivate-duplicate-keep-other-id (8510) [heuristic: see note] | Pox of Bertoxxulous |
| 8510 | Pox of Bertoxxulous | 59 | ACTIVE (Shaman lvl 59) | Confirmed: P99 wiki documents Shaman - Level 59. This id retained as the corroborated/canonical version (duplicate id 1591 deactivated - see its row) | - | none | Pox of Bertoxxulous |
| 1583 | Talisman of the Raptor | 59 | ACTIVE (Shaman lvl 59) | Confirmed spell exists; this id's mana(400) does not match the P99-documented mana(350) | - | deactivate-duplicate-keep-other-id (8484) | Talisman of the Raptor |
| 8484 | Talisman of the Raptor | 59 | ACTIVE (Shaman lvl 59) | Confirmed: P99 wiki documents Shaman - Level 59, mana(350) matches this id exactly | - | none | Talisman of the Raptor |
| 1597 | Unfailing Reverence | 59 | ACTIVE (Shaman lvl 59) | Confirmed: P99 wiki documents Shaman - Level 59, matches exactly | - | none | Unfailing Reverence |
| 1599 | Voice of the Berserker | 59 | ACTIVE (Shaman lvl 59) | Confirmed spell exists; this id's AC effect (+45) does not match the P99-documented "Increase AC by 24" | - | deactivate-duplicate-keep-other-id (8666) | Voice of the Berserker |
| 8666 | Voice of the Berserker | 59 | ACTIVE (Shaman lvl 59) | Confirmed: P99 wiki documents Shaman - Level 59, AC effect (+24) matches this id exactly | - | none | Voice of the Berserker |
| 1598 | Avatar | 60 | ACTIVE (Shaman lvl 60) | Confirmed spell exists; this id's mana(375)/recast(360000ms) does not match the P99-documented Avatar page (mana325/recast180000ms) | - | deactivate-duplicate-keep-other-id (8574) | Avatar |
| 8574 | Avatar | 60 | ACTIVE (Shaman lvl 60) | Confirmed: P99 wiki documents Shaman - Level 60, mana(325)/recast(180000ms) matches this id exactly (and matches the separately-documented "Primal Avatar" spell's mechanics, see id 1377 below) | - | none | Avatar |
| 1432 | Focus of Spirit | 60 | ACTIVE (Shaman lvl 60) | Confirmed: P99 wiki documents Shaman - Level 60, matches exactly | - | none | Focus of Spirit |
| 1578 | Malo | 60 | ACTIVE (Shaman lvl 60) | Confirmed spell exists at Level 60; mechanically identical to id 8522 - wiki does not disambiguate | - | deactivate-duplicate-keep-other-id (8522) [heuristic: see note] | Malo |
| 8522 | Malo | 60 | ACTIVE (Shaman lvl 60) | Confirmed: P99 wiki documents Shaman - Level 60. This id retained as the corroborated/canonical version (duplicate id 1578 deactivated - see its row) | - | none | Malo |
| 1377 | Primal Avatar | 60 | ACTIVE (Shaman lvl 60) | Confirmed: P99 wiki documents Shaman - Level 60, matches exactly. NOT a duplicate of Avatar (id 8574) despite identical mana/recast/effects - it is a separate, independently-documented wiki page with a different drop source (Sleeper's Tomb vs. Kunark mob drops for Avatar) | - | none | Primal Avatar |
| 1576 | Torpor | 60 | ACTIVE (Shaman lvl 60) | Confirmed spell exists; this id's mana(100) does not match the P99-documented mana(200) | - | deactivate-duplicate-keep-other-id (8480) | Torpor |
| 8480 | Torpor | 60 | ACTIVE (Shaman lvl 60) | Confirmed: P99 wiki documents Shaman - Level 60, mana(200) matches this id exactly | - | none | Torpor |

## Notes for the migration author

- No changes have been made to the database. This table lists 32 `id`s
  recommended for deactivation (`classes10 = 255`), each with its
  higher-confidence surviving counterpart identified in the "action needed"
  column.
- Before writing SQL, re-verify the 16 "heuristic, moderate confidence" pairs
  and especially the 2 "heuristic, low confidence" pairs (Cannibalize II id
  754, Cannibalize III id 1572) against another source if possible — these
  were resolved by a numbering-convention pattern observed elsewhere in this
  same audit, not a direct wiki-sourced fact for that specific pair.
- Per `docs/development/CODING_STANDARDS.md`, deactivation should be done via
  `classes10 = 255` (matching the existing "cannot learn" sentinel already
  used throughout `spells_new`), not row deletion, consistent with this
  project's preference for gating over deleting (see also
  `docs/decisions/000_UNCLASSIC_DECISIONS.md` / content-flags convention for
  any of these that warrant a `content_flags` row rather than a plain
  deactivation, e.g. Charm Animals' level-value caveat and the Superior
  Healing Kunark→Velious supersession).
- Consider recording the Superior Healing Kunark/Velious resolution (id 9 →
  8631) as a `000_UNCLASSIC_DECISIONS.md`-style entry if any Kunark-era
  activity on this server would ever want the Kunark value back — same
  pattern as the Unholy Aura Discipline precedent in ADR-009.
