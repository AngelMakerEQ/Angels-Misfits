# Wizard P99 Activation Audit -- 2026-08-08

**Status:** Investigation complete, read-only. Findings for human review; no database changes made. A migration script will be written separately after review.

**Scope:** Every spell currently active for Wizard in `spells_new` (`classes12 BETWEEN 1 AND 60`), verified against the P99 (Project 1999) wiki per the methodology in the task brief (spell's own page first, Wizard class page as corroboration, fvproject.com as a secondary/lower-confidence source, deactivate-by-default if undocumented anywhere).

## Summary

- **Total active Wizard spell rows checked:** 209 (209 rows / 185 distinct spell names)
- **Confirmed correct, no action needed:** 176
- **Flagged for deactivation (not duplicates):** 2
- **Duplicate/wrong-level pairs resolved (rows flagged `deactivate-duplicate-keep-other-id`):** 24 rows across 23 duplicate groups (22 same-name/same-level pairs + 1 same-name/different-level pair, 'Great Divide Portal')
- **Borderline era, flagged for human judgment (not auto-deactivated):** 7 (all "Chardok Revamp Era" -- see note below)
- **Secondary-source reliance:** none required for any spell -- the P99 wiki (primary source) was reachable and had page content for every spell name except "Harvest of Druzzil" (id 3338), which is also absent from the secondary source (fvproject.com, checked, 404) and the Wizard class page.

### How the duplicate/erroneous pairs were resolved

For **9 of the 22 same-level duplicate pairs**, the database rows differed mechanically (mismatched `resisttype`, `mana`, or `recast_time` between the two ids), and the P99 wiki's documented mana/recast/resist value matched exactly one of the two ids -- that id was kept and the mismatched id flagged for deactivation as a mechanically-wrong/erroneous duplicate object (Rend, Pillar of Lightning, Voltaic Draugh/Draught, Draught of Jiva, Lure of Lightning, Invert Gravity, Sunstrike, Winds of Gelid, Bind Affinity).

**Observed pattern:** in 8 of those 9 resolved cases, the higher/"8xxx"-numbered id was the one that matched the wiki (the low id carried the mechanical error, most often a resist-type mismatch e.g. Cold instead of Magic). Bind Affinity was the exception (low id 35 was correct; id 40971 -- a near-zero-cost, fast-recast object -- did not match the wiki at all).

For the remaining **13 duplicate pairs/groups**, the two (or three, for Shieldskin) ids are byte-identical across every field checked (mana, recast, resisttype, cast messages) and the wiki does not distinguish between spell ids -- there is no field-level signal to determine which specific id is "correct." Given the 8/9 pattern above, these were defaulted to keeping the **lower id** for consistency with the project's established tie-break convention from ADR-009 (Harmful Touch precedent kept the correctly-configured id, not a fixed high/low rule) -- **this default is a low-confidence inference, not a verified fact, and is called out per-row below.** The Shieldskin 3-way duplicate (236 / 8640 / 8657) is a special case: all three are identical, so which of the *two* 8xxx ids to drop (8640 or 8657) is a fully arbitrary tie-break -- flagged for explicit human review.

### Deactivation candidates (non-duplicate)

- **id 372 -- Blast of Cold** (level 1): Wiki page 'Blast of Cold': classes field explicitly states 'This spell is cast by NPCs only.' No player class (including Wizard) is listed. Not scribable/learnable content.
- **id 3338 -- Harvest of Druzzil** (level 55): Not found on P99 wiki under "Harvest of Druzzil" or "Harvest of Druzzil's Wrath"; wiki opensearch for "Harvest of" returned zero hits; not found on fvproject.com (404 on direct title fetch, search hits were false positives from unrelated pages); not listed on the Wizard class page (which lists "Harvest" but not "Harvest of Druzzil"). Per methodology default, treated as should-be-deactivated.

### Borderline era: "Chardok Revamp Era" (not auto-deactivated -- needs a human call)

7 spells are tagged `Chardok Revamp Era` on the P99 wiki. Per the wiki's own category description, this is "the end of the Velious Era" -- "one final major patch before the release of Shadows of Luclin" that altered Chardok, Temple of Droga, Mines of Nurga, and Frontier Mountains. It is chronologically **pre-Luclin**, so it does not meet the task brief's explicit auto-deactivate trigger ("a spell tagged with a post-Velious era category"), but it is also **not** the original Velious-launch content -- it is a distinct, later sub-patch within the Velious era's lifespan. Whether this server's "Velious-locked" definition includes this end-of-expansion patch is a project-lead call, not one this audit makes unilaterally:

- id 2026 -- Great Divide Gate (level 34)
- id 2028 -- Cobalt Scar Gate (level 39)
- id 2027 -- Wakening Lands Gate (level 39)
- id 2025 -- Translocate: Cobalt Scar (level 49)
- id 2023 -- Translocate: Great Divide (level 49)
- id 2022 -- Translocate: Iceclad (level 49)
- id 2024 -- Translocate: Wakening Lands (level 49)

### Other era note: "Harvest" (Hole Era) -- checked and confirmed in scope

`Harvest` (id 1744, level 34) is tagged `Hole Era`. This was investigated before flagging: per Category:Hole Era on the P99 wiki, this category covers the patch that added The Hole and Veeshan's Peak, occurring *between* Kunark and Velious, plus "subsequent patches through the release of the Velious expansion" -- i.e. pre-Velious/inter-expansion content, in scope. No action needed.

## Full findings table

| id | name | level | current status | P99 verdict | era category | action needed | citation |
|---|---|---|---|---|---|---|---|
| 372 | Blast of Cold | 1 | active | NOT FOUND / NOT CONFIRMED -- Wiki page 'Blast of Cold': classes field explicitly states 'This spell is cast by NPCs only.' No player class (including Wizard) is listed. Not scribable/learnable content. | n/a (NPC-only page, no era category) | deactivate | Blast of Cold |
| 54 | Frost Bolt | 1 | active | CONFIRMED | Classic Era | none | Frost Bolt |
| 288 | Minor Shielding | 1 | active | CONFIRMED | Classic Era | none | Minor Shielding |
| 374 | Numbing Cold | 1 | active | CONFIRMED | Classic Era | none | Numbing Cold |
| 8447 | Shock of Frost | 1 | active | CONFIRMED | Classic Era | none | Shock of Frost |
| 373 | Sphere of Light | 1 | active | CONFIRMED | Classic Era | none | Sphere of Light |
| 205 | True North | 1 | active | CONFIRMED | Classic Era | none | True North |
| 375 | Fade | 4 | active | CONFIRMED | Classic Era | none | Fade |
| 36 | Gate | 4 | active | CONFIRMED | Classic Era | none | Gate |
| 51 | Glimpse | 4 | active | CONFIRMED | Classic Era | none | Glimpse |
| 377 | Icestrike | 4 | active | CONFIRMED | Classic Era | none | Icestrike |
| 378 | O'Keils Radiation | 4 | active | CONFIRMED | Classic Era | none | O'Keils Radiation |
| 230 | Root | 4 | active | CONFIRMED | Classic Era | none | Root |
| 80 | See Invisible | 4 | active | CONFIRMED | Classic Era | none | See Invisible |
| 8652 | See Invisible | 4 | active | DUPLICATE/ERRONEOUS - deactivate -- Identical mana/recast/resisttype/messages to id 80; no field-level signal to distinguish. Defaulted to lower id (no-evidence tie-break; see report note on the 8xxx pattern). | Classic Era | deactivate-duplicate-keep-other-id (80) | See Invisible |
| 376 | Shock of Fire | 4 | active | CONFIRMED | Classic Era | none | Shock of Fire |
| 380 | Column of Frost | 8 | active | CONFIRMED | Classic Era | none | Column of Frost |
| 323 | Eye of Zomm | 8 | active | CONFIRMED | Classic Era | none | Eye of Zomm |
| 379 | Fingers of Fire | 8 | active | CONFIRMED | Classic Era | none | Fingers of Fire |
| 477 | Fire Bolt | 8 | active | CONFIRMED | Classic Era | none | Fire Bolt |
| 246 | Lesser Shielding | 8 | active | CONFIRMED | Classic Era | none | Lesser Shielding |
| 232 | Sense Summoned | 8 | active | CONFIRMED | Classic Era | none | Sense Summoned |
| 354 | Shadow Step | 8 | active | CONFIRMED | Classic Era | none | Shadow Step |
| 656 | Shock of Ice | 8 | active | CONFIRMED | Classic Era | none | Shock of Ice |
| 35 | Bind Affinity | 12 | active | CONFIRMED | Classic Era | none | Bind Affinity |
| 40971 | Bind Affinity | 12 | active | DUPLICATE/ERRONEOUS - deactivate -- Wiki: mana 100, recast 12.00 (12000ms) -- matches id 35 exactly. Id 40971 (mana blank/0, recast 1500ms) does not match wiki at all; mechanically a different, erroneous object. | Classic Era | deactivate-duplicate-keep-other-id (35) | Bind Affinity |
| 48 | Cancel Magic | 12 | active | CONFIRMED | Classic Era | none | Cancel Magic |
| 8662 | Cancel Magic | 12 | active | DUPLICATE/ERRONEOUS - deactivate -- Identical mana/recast to id 48; targettype differs (5 vs 6) in DB but wiki text does not disambiguate by targettype. Defaulted to lower id (no-evidence tie-break). | Classic Era | deactivate-duplicate-keep-other-id (48) | Cancel Magic |
| 85 | Firestorm | 12 | active | CONFIRMED | Classic Era | none | Firestorm |
| 382 | Frost Spiral of Al'Kabor | 12 | active | CONFIRMED | Classic Era | none | Frost Spiral of Al'Kabor |
| 529 | Gaze | 12 | active | CONFIRMED | Classic Era | none | Gaze |
| 234 | Halo of Light | 12 | active | CONFIRMED | Classic Era | none | Halo of Light |
| 381 | Resistant Skin | 12 | active | CONFIRMED | Classic Era | none | Resistant Skin |
| 383 | Shock of Lightning | 12 | active | CONFIRMED | Classic Era | none | Shock of Lightning |
| 500 | Bind Sight | 16 | active | CONFIRMED | Classic Era | none | Bind Sight |
| 657 | Flame Shock | 16 | active | CONFIRMED | Classic Era | none | Flame Shock |
| 679 | Heat Sight | 16 | active | CONFIRMED | Classic Era | none | Heat Sight |
| 305 | Identify | 16 | active | CONFIRMED | Classic Era | none | Identify |
| 42 | Invisibility | 16 | active | CONFIRMED | Classic Era | none | Invisibility |
| 38 | Lightning Bolt | 16 | active | CONFIRMED | Classic Era | none | Lightning Bolt |
| 386 | Pillar of Fire | 16 | active | CONFIRMED | Classic Era | none | Pillar of Fire |
| 385 | Project Lightning | 16 | active | CONFIRMED | Classic Era | none | Project Lightning |
| 309 | Shielding | 16 | active | CONFIRMED | Classic Era | none | Shielding |
| 236 | Shieldskin | 16 | active | CONFIRMED | Classic Era | none | Shieldskin |
| 8640 | Shieldskin | 16 | active | DUPLICATE/ERRONEOUS - deactivate -- All three ids identical mana/recast/resisttype/messages. No field-level signal to distinguish among the three. Defaulted to lowest id; choice between the two 8xxx ids (8640 vs 8657) is an arbitrary tie-break -- flag for human review. | Classic Era | deactivate-duplicate-keep-other-id (236) | Shieldskin |
| 8657 | Shieldskin | 16 | active | DUPLICATE/ERRONEOUS - deactivate -- All three ids identical mana/recast/resisttype/messages. No field-level signal to distinguish among the three. Defaulted to lowest id; choice between the two 8xxx ids (8640 vs 8657) is an arbitrary tie-break -- flag for human review. | Classic Era | deactivate-duplicate-keep-other-id (236) | Shieldskin |
| 108 | Elemental Shield | 20 | active | CONFIRMED | Classic Era | none | Elemental Shield |
| 131 | Enstill | 20 | active | CONFIRMED | Classic Era | none | Enstill |
| 543 | Fay Gate | 20 | active | CONFIRMED | Classic Era | none | Fay Gate |
| 458 | Fire Spiral of Al'Kabor | 20 | active | CONFIRMED | Classic Era | none | Fire Spiral of Al'Kabor |
| 22 | Force Shock | 20 | active | CONFIRMED | Classic Era | none | Force Shock |
| 542 | North Gate | 20 | active | CONFIRMED | Classic Era | none | North Gate |
| 578 | Sight | 20 | active | CONFIRMED | Classic Era | none | Sight |
| 503 | Tishan's Clash | 20 | active | CONFIRMED | Classic Era | none | Tishan's Clash |
| 541 | Tox Gate | 20 | active | CONFIRMED | Classic Era | none | Tox Gate |
| 461 | Cast Force | 24 | active | CONFIRMED | Classic Era | none | Cast Force |
| 546 | Cazic Gate | 24 | active | CONFIRMED | Classic Era | none | Cazic Gate |
| 462 | Column of Lightning | 24 | active | CONFIRMED | Classic Era | none | Column of Lightning |
| 1325 | Combine Gate | 24 | active | CONFIRMED | Kunark Era | none | Combine Gate |
| 544 | Common Gate | 24 | active | CONFIRMED | Classic Era | none | Common Gate |
| 464 | Frost Shock | 24 | active | CONFIRMED | Classic Era | none | Frost Shock |
| 387 | Leatherskin | 24 | active | CONFIRMED | Classic Era | none | Leatherskin |
| 261 | Levitate | 24 | active | CONFIRMED | Classic Era | none | Levitate |
| 467 | Lightning Storm | 24 | active | CONFIRMED | Classic Era | none | Lightning Storm |
| 65 | Major Shielding | 24 | active | CONFIRMED | Classic Era | none | Major Shielding |
| 545 | Nek Gate | 24 | active | CONFIRMED | Classic Era | none | Nek Gate |
| 547 | Ro Gate | 24 | active | CONFIRMED | Classic Era | none | Ro Gate |
| 548 | West Gate | 24 | active | CONFIRMED | Classic Era | none | West Gate |
| 636 | Bonds of Force | 29 | active | CONFIRMED | Classic Era | none | Bonds of Force |
| 468 | Energy Storm | 29 | active | CONFIRMED | Classic Era | none | Energy Storm |
| 602 | Evacuate: North | 29 | active | CONFIRMED | Classic Era | none | Evacuate: North |
| 563 | Fay Portal | 29 | active | CONFIRMED | Classic Era | none | Fay Portal |
| 1899 | Imbue Fire Opal | 29 | active | CONFIRMED | Classic Era | none | Imbue Fire Opal |
| 465 | Inferno Shock | 29 | active | CONFIRMED | Classic Era | none | Inferno Shock |
| 579 | Magnify | 29 | active | CONFIRMED | Classic Era | none | Magnify |
| 562 | North Portal | 29 | active | CONFIRMED | Classic Era | none | North Portal |
| 459 | Shock Spiral of Al'Kabor | 29 | active | CONFIRMED | Classic Era | none | Shock Spiral of Al'Kabor |
| 470 | Thunder Strike | 29 | active | CONFIRMED | Classic Era | none | Thunder Strike |
| 561 | Tox Portal | 29 | active | CONFIRMED | Classic Era | none | Tox Portal |
| 528 | Yonder | 29 | active | CONFIRMED | Classic Era | none | Yonder |
| 565 | Cazic Portal | 34 | active | CONFIRMED | Classic Era | none | Cazic Portal |
| 463 | Circle of Force | 34 | active | CONFIRMED | Classic Era | none | Circle of Force |
| 1516 | Combine Portal | 34 | active | CONFIRMED | Kunark Era | none | Combine Portal |
| 603 | Evacuate: Fay | 34 | active | CONFIRMED | Classic Era | none | Evacuate: Fay |
| 2026 | Great Divide Gate | 34 | active | CONFIRMED - borderline era, see note -- Wiki tags this page "Chardok Revamp Era". Per Category:Chardok Revamp Era on P99 wiki: "At the end of the Velious Era the original EverQuest developers released one final major patch before the release of Shadows of Luclin. This patch altered the zones Chardok, Temple of Droga, Mines of Nurga, and Frontier Mountains." Chronologically pre-Luclin, but a distinct, late sub-era patch, not part of the original Velious-launch content. NOT auto-deactivated (this is not a later-expansion tag like Luclin/PoP), but flagged for explicit human judgment on whether this server's "Velious-locked" definition includes this end-of-expansion patch. | Chardok Revamp Era | review-borderline-era | Great Divide Gate |
| 66 | Greater Shielding | 34 | active | CONFIRMED | Classic Era | none | Greater Shielding |
| 1744 | Harvest | 34 | active | CONFIRMED -- Wiki tags this page "Hole Era". Per Category:Hole Era on P99 wiki, this category covers "a major patch which added...The Hole and Veeshan's Peak" occurring "between the release of Kunark and Velious", through "subsequent patches through the release of the Velious expansion" -- i.e. pre-Velious/inter-expansion content, in scope. (Verified before flagging -- initial assumption that "Hole" implied later post-Velious content was wrong; checked the category page definition directly.) | Hole Era | none | Harvest |
| 658 | Ice Shock | 34 | active | CONFIRMED | Classic Era | none | Ice Shock |
| 1417 | Iceclad Gate | 34 | active | CONFIRMED | Velious Era | none | Iceclad Gate |
| 1418 | Iceclad Portal | 34 | active | CONFIRMED | Velious Era | none | Iceclad Portal |
| 469 | Lava Storm | 34 | active | CONFIRMED | Classic Era | none | Lava Storm |
| 564 | Nek Portal | 34 | active | CONFIRMED | Classic Era | none | Nek Portal |
| 49 | Nullify Magic | 34 | active | CONFIRMED | Classic Era | none | Nullify Magic |
| 1419 | O'Keils Flickering Flame | 34 | active | CONFIRMED | Velious Era | none | O'Keils Flickering Flame |
| 393 | Steelskin | 34 | active | CONFIRMED | Classic Era | none | Steelskin |
| 471 | Thunderclap | 34 | active | CONFIRMED | Classic Era | none | Thunderclap |
| 539 | Chill Sight | 39 | active | CONFIRMED | Classic Era | none | Chill Sight |
| 2028 | Cobalt Scar Gate | 39 | active | CONFIRMED - borderline era, see note -- Wiki tags this page "Chardok Revamp Era". Per Category:Chardok Revamp Era on P99 wiki: "At the end of the Velious Era the original EverQuest developers released one final major patch before the release of Shadows of Luclin. This patch altered the zones Chardok, Temple of Droga, Mines of Nurga, and Frontier Mountains." Chronologically pre-Luclin, but a distinct, late sub-era patch, not part of the original Velious-launch content. NOT auto-deactivated (this is not a later-expansion tag like Luclin/PoP), but flagged for explicit human judgment on whether this server's "Velious-locked" definition includes this end-of-expansion patch. | Chardok Revamp Era | review-borderline-era | Cobalt Scar Gate |
| 566 | Common Portal | 39 | active | CONFIRMED | Classic Era | none | Common Portal |
| 752 | Concussion | 39 | active | CONFIRMED | Kunark Era | none | Concussion |
| 604 | Evacuate: Ro | 39 | active | CONFIRMED | Classic Era | none | Evacuate: Ro |
| 460 | Force Spiral of Al'Kabor | 39 | active | CONFIRMED | Classic Era | none | Force Spiral of Al'Kabor |
| 8620 | Great Divide Portal | 39 | active | CONFIRMED | Velious Era | none | Great Divide Portal |
| 132 | Immobilize | 39 | active | CONFIRMED | Classic Era | none | Immobilize |
| 1420 | Invisibility to Undead | 39 | active | CONFIRMED | Velious Era | none | Invisibility to Undead |
| 466 | Lightning Shock | 39 | active | CONFIRMED | Classic Era | none | Lightning Shock |
| 1739 | Markar's Relocation | 39 | active | CONFIRMED | Kunark Era | none | Markar's Relocation |
| 567 | Ro Portal | 39 | active | CONFIRMED | Classic Era | none | Ro Portal |
| 84 | Shifting Sight | 39 | active | CONFIRMED | Classic Era | none | Shifting Sight |
| 1738 | Tishan's Relocation | 39 | active | CONFIRMED | Kunark Era | none | Tishan's Relocation |
| 1339 | Translocate: Combine | 39 | active | CONFIRMED | Velious Era | none | Translocate: Combine |
| 1336 | Translocate: Fay | 39 | active | CONFIRMED | Velious Era | none | Translocate: Fay |
| 1338 | Translocate: North | 39 | active | CONFIRMED | Velious Era | none | Translocate: North |
| 1337 | Translocate: Tox | 39 | active | CONFIRMED | Velious Era | none | Translocate: Tox |
| 2027 | Wakening Lands Gate | 39 | active | CONFIRMED - borderline era, see note -- Wiki tags this page "Chardok Revamp Era". Per Category:Chardok Revamp Era on P99 wiki: "At the end of the Velious Era the original EverQuest developers released one final major patch before the release of Shadows of Luclin. This patch altered the zones Chardok, Temple of Droga, Mines of Nurga, and Frontier Mountains." Chronologically pre-Luclin, but a distinct, late sub-era patch, not part of the original Velious-launch content. NOT auto-deactivated (this is not a later-expansion tag like Luclin/PoP), but flagged for explicit human judgment on whether this server's "Velious-locked" definition includes this end-of-expansion patch. | Chardok Revamp Era | review-borderline-era | Wakening Lands Gate |
| 568 | West Portal | 39 | active | CONFIRMED | Classic Era | none | West Portal |
| 67 | Arch Shielding | 44 | active | CONFIRMED | Classic Era | none | Arch Shielding |
| 1425 | Cobalt Scar Portal | 44 | active | CONFIRMED | Velious Era | none | Cobalt Scar Portal |
| 659 | Conflagration | 44 | active | CONFIRMED | Classic Era | none | Conflagration |
| 394 | Diamondskin | 44 | active | CONFIRMED | Classic Era | none | Diamondskin |
| 8641 | Diamondskin | 44 | active | DUPLICATE/ERRONEOUS - deactivate -- Identical mana/recast/resisttype/messages to id 394; no field-level signal to distinguish. Defaulted to lower id (no-evidence tie-break). | Classic Era | deactivate-duplicate-keep-other-id (394) | Diamondskin |
| 109 | Elemental Armor | 44 | active | CONFIRMED | Classic Era | none | Elemental Armor |
| 1421 | Enticement of Flame | 44 | active | CONFIRMED | Velious Era | none | Enticement of Flame |
| 605 | Evacuate: Nek | 44 | active | CONFIRMED | Classic Era | none | Evacuate: Nek |
| 23 | Force Strike | 44 | active | CONFIRMED | Classic Era | none | Force Strike |
| 660 | Frost Storm | 44 | active | CONFIRMED | Classic Era | none | Frost Storm |
| 73 | Gravity Flux | 44 | active | CONFIRMED | Classic Era | none | Gravity Flux |
| 1423 | Great Divide Portal | 44 | active | DUPLICATE/ERRONEOUS - deactivate -- Wiki (Great Divide Portal, Velious Era): Wizard - Level 39. Matches id 8620. Id 1423 sits at level 44 in our DB -- duplicate-at-wrong-level (same pattern as ADR-009's precedent); id 8620 is the wiki-correct level. | Velious Era | deactivate-duplicate-keep-other-id (8620) | Great Divide Portal |
| 1375 | Translocate: Cazic | 44 | active | CONFIRMED | Velious Era | none | Translocate: Cazic |
| 1372 | Translocate: Common | 44 | active | CONFIRMED | Velious Era | none | Translocate: Common |
| 1371 | Translocate: Nek | 44 | active | CONFIRMED | Velious Era | none | Translocate: Nek |
| 1373 | Translocate: Ro | 44 | active | CONFIRMED | Velious Era | none | Translocate: Ro |
| 1374 | Translocate: West | 44 | active | CONFIRMED | Velious Era | none | Translocate: West |
| 1399 | Wakening Lands Portal | 44 | active | CONFIRMED | Velious Era | none | Wakening Lands Portal |
| 666 | Alter Plane: Hate | 46 | active | CONFIRMED | Classic Era | none | Alter Plane: Hate |
| 674 | Alter Plane: Sky | 46 | active | CONFIRMED | Classic Era | none | Alter Plane: Sky |
| 8655 | Alter Plane: Sky | 46 | active | DUPLICATE/ERRONEOUS - deactivate -- Identical mana/recast/messages to id 674; no field-level signal to distinguish. Defaulted to lower id (no-evidence tie-break). | Classic Era | deactivate-duplicate-keep-other-id (674) | Alter Plane: Sky |
| 606 | Evacuate: West | 49 | active | CONFIRMED | Classic Era | none | Evacuate: West |
| 732 | Ice Comet | 49 | active | CONFIRMED | Classic Era | none | Ice Comet |
| 612 | Markar's Clash | 49 | active | CONFIRMED | Classic Era | none | Markar's Clash |
| 133 | Paralyzing Earth | 49 | active | CONFIRMED | Kunark Era | none | Paralyzing Earth |
| 755 | Rend | 49 | active | DUPLICATE/ERRONEOUS - deactivate -- Wiki: resist = Magic (0). Id 8505 has resisttype=1 (Magic), matching. Id 755 has resisttype=3 (Cold), mismatched -- mechanically wrong. | Classic Era | deactivate-duplicate-keep-other-id (8505) | Rend |
| 8505 | Rend | 49 | active | CONFIRMED | Classic Era | none | Rend |
| 733 | Supernova | 49 | active | CONFIRMED | Classic Era | none | Supernova |
| 2025 | Translocate: Cobalt Scar | 49 | active | CONFIRMED - borderline era, see note -- Wiki tags this page "Chardok Revamp Era". Per Category:Chardok Revamp Era on P99 wiki: "At the end of the Velious Era the original EverQuest developers released one final major patch before the release of Shadows of Luclin. This patch altered the zones Chardok, Temple of Droga, Mines of Nurga, and Frontier Mountains." Chronologically pre-Luclin, but a distinct, late sub-era patch, not part of the original Velious-launch content. NOT auto-deactivated (this is not a later-expansion tag like Luclin/PoP), but flagged for explicit human judgment on whether this server's "Velious-locked" definition includes this end-of-expansion patch. | Chardok Revamp Era | review-borderline-era | Translocate: Cobalt Scar |
| 2023 | Translocate: Great Divide | 49 | active | CONFIRMED - borderline era, see note -- Wiki tags this page "Chardok Revamp Era". Per Category:Chardok Revamp Era on P99 wiki: "At the end of the Velious Era the original EverQuest developers released one final major patch before the release of Shadows of Luclin. This patch altered the zones Chardok, Temple of Droga, Mines of Nurga, and Frontier Mountains." Chronologically pre-Luclin, but a distinct, late sub-era patch, not part of the original Velious-launch content. NOT auto-deactivated (this is not a later-expansion tag like Luclin/PoP), but flagged for explicit human judgment on whether this server's "Velious-locked" definition includes this end-of-expansion patch. | Chardok Revamp Era | review-borderline-era | Translocate: Great Divide |
| 2022 | Translocate: Iceclad | 49 | active | CONFIRMED - borderline era, see note -- Wiki tags this page "Chardok Revamp Era". Per Category:Chardok Revamp Era on P99 wiki: "At the end of the Velious Era the original EverQuest developers released one final major patch before the release of Shadows of Luclin. This patch altered the zones Chardok, Temple of Droga, Mines of Nurga, and Frontier Mountains." Chronologically pre-Luclin, but a distinct, late sub-era patch, not part of the original Velious-launch content. NOT auto-deactivated (this is not a later-expansion tag like Luclin/PoP), but flagged for explicit human judgment on whether this server's "Velious-locked" definition includes this end-of-expansion patch. | Chardok Revamp Era | review-borderline-era | Translocate: Iceclad |
| 2024 | Translocate: Wakening Lands | 49 | active | CONFIRMED - borderline era, see note -- Wiki tags this page "Chardok Revamp Era". Per Category:Chardok Revamp Era on P99 wiki: "At the end of the Velious Era the original EverQuest developers released one final major patch before the release of Shadows of Luclin. This patch altered the zones Chardok, Temple of Droga, Mines of Nurga, and Frontier Mountains." Chronologically pre-Luclin, but a distinct, late sub-era patch, not part of the original Velious-launch content. NOT auto-deactivated (this is not a later-expansion tag like Luclin/PoP), but flagged for explicit human judgment on whether this server's "Velious-locked" definition includes this end-of-expansion patch. | Chardok Revamp Era | review-borderline-era | Translocate: Wakening Lands |
| 731 | Wrath of Al'Kabor | 49 | active | CONFIRMED | Classic Era | none | Wrath of Al'Kabor |
| 1422 | Translocate | 50 | active | CONFIRMED | Velious Era | none | Translocate |
| 1631 | Atol's Spectral Shackles | 51 | active | CONFIRMED | Kunark Era | none | Atol's Spectral Shackles |
| 1637 | Draught of Fire | 51 | active | CONFIRMED | Kunark Era | none | Draught of Fire |
| 1646 | Pillar of Frost | 51 | active | CONFIRMED | Kunark Era | none | Pillar of Frost |
| 8512 | Pillar of Frost | 51 | active | DUPLICATE/ERRONEOUS - deactivate -- Identical mana/recast/resisttype (Cold, matches wiki)/messages between both ids; no field-level signal to distinguish. Defaulted to lower id (no-evidence tie-break). | Kunark Era | deactivate-duplicate-keep-other-id (1646) | Pillar of Frost |
| 1634 | Tishan's Discord | 51 | active | CONFIRMED | Kunark Era | none | Tishan's Discord |
| 1627 | Abscond | 52 | active | CONFIRMED | Kunark Era | none | Abscond |
| 1642 | Lure of Frost | 52 | active | CONFIRMED | Kunark Era | none | Lure of Frost |
| 1609 | Manaskin | 52 | active | CONFIRMED | Kunark Era | none | Manaskin |
| 8521 | Manaskin | 52 | active | DUPLICATE/ERRONEOUS - deactivate -- Identical mana/recast/resisttype/messages to id 1609; no field-level signal to distinguish. Defaulted to lower id (no-evidence tie-break). | Kunark Era | deactivate-duplicate-keep-other-id (1609) | Manaskin |
| 1649 | Tears of Druzzil | 52 | active | CONFIRMED | Kunark Era | none | Tears of Druzzil |
| 1334 | Translocate: Group | 52 | active | CONFIRMED | Velious Era | none | Translocate: Group |
| 1526 | Annul Magic | 53 | active | CONFIRMED | Kunark Era | none | Annul Magic |
| 1650 | Inferno of Al'Kabor | 53 | active | CONFIRMED | Kunark Era | none | Inferno of Al'Kabor |
| 1653 | Jyll's Static Pulse | 53 | active | CONFIRMED | Kunark Era | none | Jyll's Static Pulse |
| 1645 | Pillar of Lightning | 54 | active | DUPLICATE/ERRONEOUS - deactivate -- Wiki: resist = Magic (0). Id 8511 has resisttype=1 (Magic), matching. Id 1645 has resisttype=2 (Fire), mismatched -- mechanically wrong. | Kunark Era | deactivate-duplicate-keep-other-id (8511) | Pillar of Lightning |
| 8511 | Pillar of Lightning | 54 | active | CONFIRMED | Kunark Era | none | Pillar of Lightning |
| 1610 | Shield of the Magi | 54 | active | CONFIRMED | Kunark Era | none | Shield of the Magi |
| 1656 | Thunderbold | 54 | active | CONFIRMED | Kunark Era | none | Thunderbold |
| 1639 | Voltaic Draugh | 54 | active | DUPLICATE/ERRONEOUS - deactivate -- Wiki (Voltaic Draught page): resist = Magic (0). Id 8467 has resisttype=1 (Magic), matching. Id 1639 has resisttype=3 (Cold), mismatched -- mechanically wrong. | Kunark Era | deactivate-duplicate-keep-other-id (8467) | Voltaic Draught (P99 page title; in-game scribed name is 'Voltaic Draugh' per page note) |
| 8467 | Voltaic Draugh | 54 | active | CONFIRMED | Kunark Era | none | Voltaic Draught (P99 page title; in-game scribed name is 'Voltaic Draugh' per page note) |
| 1643 | Draught of Jiva | 55 | active | DUPLICATE/ERRONEOUS - deactivate -- Wiki: resist = Magic (0). Id 8550 has resisttype=1 (Magic), matching. Id 1643 has resisttype=3 (Cold), mismatched -- mechanically wrong. | Kunark Era | deactivate-duplicate-keep-other-id (8550) | Draught of Jiva |
| 8550 | Draught of Jiva | 55 | active | CONFIRMED | Kunark Era | none | Draught of Jiva |
| 3338 | Harvest of Druzzil | 55 | active | NOT FOUND / NOT CONFIRMED -- Not found on P99 wiki under "Harvest of Druzzil" or "Harvest of Druzzil's Wrath"; wiki opensearch for "Harvest of" returned zero hits; not found on fvproject.com (404 on direct title fetch, search hits were false positives from unrelated pages); not listed on the Wizard class page (which lists "Harvest" but not "Harvest of Druzzil"). Per methodology default, treated as should-be-deactivated. | n/a (no page found) | deactivate | not found on P99 wiki (plain title + "...Wrath" variant + search), not found on fvproject.com (404), not listed on Wizard class page (only "Harvest" listed) |
| 1406 | Improved Invisibility | 55 | active | CONFIRMED | Velious Era | none | Improved Invisibility |
| 1638 | Lure of Flame | 55 | active | CONFIRMED | Kunark Era | none | Lure of Flame |
| 1632 | Plainsight | 55 | active | CONFIRMED | Kunark Era | none | Plainsight |
| 1648 | Tears of Solusek | 55 | active | CONFIRMED | Kunark Era | none | Tears of Solusek |
| 1654 | Jyll's Zephyr of Ice | 56 | active | CONFIRMED | Kunark Era | none | Jyll's Zephyr of Ice |
| 8527 | Jyll's Zephyr of Ice | 56 | active | DUPLICATE/ERRONEOUS - deactivate -- Identical mana/recast/resisttype (Cold, matches wiki)/messages between both ids; no field-level signal to distinguish. Defaulted to lower id (no-evidence tie-break). | Kunark Era | deactivate-duplicate-keep-other-id (1654) | Jyll's Zephyr of Ice |
| 1635 | Markar's Discord | 56 | active | CONFIRMED | Kunark Era | none | Markar's Discord |
| 1651 | Retribution of Al'Kabor | 56 | active | CONFIRMED | Kunark Era | none | Retribution of Al'Kabor |
| 8503 | Retribution of Al'Kabor | 56 | active | DUPLICATE/ERRONEOUS - deactivate -- Identical mana/recast/resisttype (Cold, matches wiki)/messages between both ids; no field-level signal to distinguish. Defaulted to lower id (no-evidence tie-break). | Kunark Era | deactivate-duplicate-keep-other-id (1651) | Retribution of Al'Kabor |
| 1641 | Draught of Ice | 57 | active | CONFIRMED | Kunark Era | none | Draught of Ice |
| 8551 | Draught of Ice | 57 | active | DUPLICATE/ERRONEOUS - deactivate -- Identical mana/recast/resisttype (Cold, matches wiki)/messages between both ids; no field-level signal to distinguish. Defaulted to lower id (no-evidence tie-break). | Kunark Era | deactivate-duplicate-keep-other-id (1641) | Draught of Ice |
| 1628 | Evacuate | 57 | active | CONFIRMED | Kunark Era | none | Evacuate |
| 1720 | Eye of Tallon | 57 | active | CONFIRMED | Kunark Era | none | Eye of Tallon |
| 1644 | Pillar of Flame | 57 | active | CONFIRMED | Kunark Era | none | Pillar of Flame |
| 8513 | Pillar of Flame | 57 | active | DUPLICATE/ERRONEOUS - deactivate -- Identical mana/recast/resisttype (Fire, matches wiki)/messages between both ids; no field-level signal to distinguish. Defaulted to lower id (no-evidence tie-break). | Kunark Era | deactivate-duplicate-keep-other-id (1644) | Pillar of Flame |
| 1633 | Fetter | 58 | active | CONFIRMED | Kunark Era | none | Fetter |
| 1640 | Lure of Lightning | 58 | active | DUPLICATE/ERRONEOUS - deactivate -- Wiki: resist = Magic (-300). Id 8523 has resisttype=1 (Magic), matching. Id 1640 has resisttype=3 (Cold), mismatched -- mechanically wrong. | Kunark Era | deactivate-duplicate-keep-other-id (8523) | Lure of Lightning |
| 8523 | Lure of Lightning | 58 | active | CONFIRMED | Kunark Era | none | Lure of Lightning |
| 1728 | Manasink | 58 | active | CONFIRMED | Kunark Era | none | Manasink |
| 1647 | Tears of Prexus | 58 | active | CONFIRMED | Kunark Era | none | Spell:Tears of Prexus (namespaced; plain title is an item disambig page) |
| 1722 | Flaming Sword of Xuzl | 59 | active | CONFIRMED | Kunark Era | none | Flaming Sword of Xuzl |
| 1636 | Invert Gravity | 59 | active | DUPLICATE/ERRONEOUS - deactivate -- Wiki: mana 500, recast 12.00 (12000ms), resist Magic (0). Id 8529 matches exactly. Id 1636 has recast=10000ms (mismatched), though same resisttype. | Kunark Era | deactivate-duplicate-keep-other-id (8529) | Invert Gravity |
| 8529 | Invert Gravity | 59 | active | CONFIRMED | Kunark Era | none | Invert Gravity |
| 1655 | Jyll's Wave of Heat | 59 | active | CONFIRMED | Kunark Era | none | Jyll's Wave of Heat |
| 8528 | Jyll's Wave of Heat | 59 | active | DUPLICATE/ERRONEOUS - deactivate -- Identical mana/recast/resisttype (Fire, matches wiki)/messages between both ids; no field-level signal to distinguish. Defaulted to lower id (no-evidence tie-break). | Kunark Era | deactivate-duplicate-keep-other-id (1655) | Jyll's Wave of Heat |
| 1652 | Vengeance of Al'Kabor | 59 | active | CONFIRMED | Kunark Era | none | Vengeance of Al'Kabor |
| 8475 | Vengeance of Al'Kabor | 59 | active | DUPLICATE/ERRONEOUS - deactivate -- Identical mana/recast/resisttype (Magic, matches wiki)/messages between both ids; no field-level signal to distinguish. Defaulted to lower id (no-evidence tie-break). | Kunark Era | deactivate-duplicate-keep-other-id (1652) | Vengeance of Al'Kabor |
| 1724 | Disintegrate | 60 | active | CONFIRMED | Kunark Era | none | Disintegrate |
| 1311 | Hsagra's Wrath | 60 | active | CONFIRMED | Velious Era | none | Hsagra's Wrath |
| 1426 | Ice Spear of Solist | 60 | active | CONFIRMED | Velious Era | none | Ice Spear of Solist |
| 1769 | Lure of Ice | 60 | active | CONFIRMED | Kunark Era | none | Lure of Ice |
| 1310 | Porlos' Fury | 60 | active | CONFIRMED | Velious Era | none | Porlos' Fury |
| 1658 | Sunstrike | 60 | active | DUPLICATE/ERRONEOUS - deactivate -- Wiki: mana 450, recast 2.25, resist Fire (-10). Id 8466 matches exactly (mana 450). Id 1658 has mana=500 (mismatched). | Kunark Era | deactivate-duplicate-keep-other-id (8466) | Sunstrike |
| 8466 | Sunstrike | 60 | active | CONFIRMED | Kunark Era | none | Sunstrike |
| 1657 | Winds of Gelid | 60 | active | DUPLICATE/ERRONEOUS - deactivate -- Wiki: mana 875, recast 12.00, resist Cold (-10). Id 8464 matches exactly (mana 875). Id 1657 has mana=1000 (mismatched). | Kunark Era | deactivate-duplicate-keep-other-id (8464) | Winds of Gelid |
| 8464 | Winds of Gelid | 60 | active | CONFIRMED | Kunark Era | none | Winds of Gelid |
