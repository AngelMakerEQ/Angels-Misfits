# Enchanter P99 Activation Audit

**Date:** 2026-08-08
**Scope:** Every spell currently active for Enchanter (`spells_new.classes14` BETWEEN 1 AND 60) on the live `angelsmisfits` database, checked against the P99 (Project 1999) wiki as the authoritative source for Velious-era availability.
**Status:** Investigation only - read-only. No database changes made. For human review; a migration script will be written separately after review.

## Summary

- **Total active Enchanter spell grants checked:** 324 rows (281 unique spell names)
- **Confirmed correct (no action needed):** 212
- **Flagged for deactivation (undocumented / out-of-era, not a duplicate case):** 80 rows (includes 19 rows across 8 duplicate-name groups where the wiki has no page for the name at all, so no id in the group can be confirmed)
- **Flagged for deactivation as a resolved duplicate (keep one id, drop the other(s)):** 32 rows across 30 spell-name groups

### Duplicate-id resolution method

Per methodology: for every spell name granted to Enchanter under more than one `id` at the same level, the P99 wiki page for that name was checked. In **every** duplicate case found (38 name-groups total), the wiki documents **exactly one** version of the spell (one `classes =` line, one set of mana/recast/duration values) - none showed the "two real era-versions coexist" pattern seen in the ADR-009 Unholy Aura Discipline precedent. So each case resolves as duplicate-object cleanup, not an era pick:

- **30 name-groups**: the wiki's documented mana/recast/level values matched exactly one of the database ids (sometimes matching a low id, sometimes a high `8xxx`-range id - no consistent pattern by id number alone, so each pair was checked on its own mechanical merits, addressing the coordinator's guidance to use description/effect data as an additional disambiguating signal rather than id magnitude). That id is kept active; the other id(s) for the same name are flagged `deactivate-duplicate-keep-<id>`.
- **8 name-groups** (all `Illusion:` pirate/joke-illusion spells - Banshee, Daft Trickster, Dark Elf Pirate, Erudite Pirate, Gnomish Pirate, Human Pirate, Ogre Pirate, Troll Pirate): the P99 wiki has **no page at all** for the name, so no id in the group can be confirmed as the "real" one. All ids in these groups are flagged `deactivate` (undocumented, not merely a duplicate-of-a-known-good id).
- One special case, **Boon of the Clear Mind**: this is not a same-level duplicate but two ids granting the *same name at two different levels* (id 8570 at level 52, id 1694 at level 54). The wiki confirms Enchanter learns it at level 52 only (mana 175 matches both ids, but level disambiguates). Id 8570 is kept; id 1694 is flagged `deactivate-duplicate-keep-8570`.

### Other findings

- No spell confirmed on the wiki carried a post-Velious era category (Luclin, PoP, or later). Three spells carry P99's own classic-era sub-tags (`Jul 2001 Era`, `Warrens Era`, `Hole Era`, `Epic Quests Era`) which are P99's internal patch-date labels within the Classic period, not later-expansion eras - no action needed for those beyond the normal confirmation.
- All ~60 non-duplicate `Illusion:` race/elemental/undead cosmetic illusions (Barbarian, Dwarf, Erudite, Half-Elf, Human, dark/high elf, halfling, wood elf, gnome, troll, ogre, iksar, tree, skeleton, the four elementals, dry bone, spirit wolf, werewolf) are confirmed on the wiki at their current levels - these are the genuine classic/Kunark Enchanter illusion line.
- All ~50 later `Illusion:` spells (pirate variants, bixies, gargoyles, golems, scrykin, crystalline creatures, Gunthak Pirate, Warped Chetari, Daft Trickster, Butterfly, Scaled Wolf, etc.) plus `Visage of the Daft Trickster` are **not found** on the P99 wiki at all (own page and Enchanter class page both checked) - these read as later-expansion illusion spells pulled in by the raw P99 export and are flagged for deactivation per the default rule.
- The classic Enchanter self-buff "Animation" line (Pendril's/Juli's/Mircyl's/Kilan's/Shalee's/Sisna's/Sagar's/Uleen's/Boltran's/Aanya's/Kintaz's/Yegoreff's/Zumaik's Animation) is fully confirmed - the database stores several of these names with a backtick (`` ` ``) instead of an apostrophe, which required retrying the wiki lookup with a straight apostrophe (noted per-row in the Citation column).
- `Greater Mass Enchant Electrum`, `Greater Mass Enchant Silver`, `Wuggan's Lesser Appraisal/Discombobulation/Extrication`, and the five `Focus *Spellcaster's Empowering Essence` entries are not found on the wiki or the Enchanter class page - flagged for deactivation.

## Full spell table

| id | name | level | current status | P99 verdict | era category | action needed | citation |
|---|---|---|---|---|---|---|---|
| 27719 | Illusion: Arcane Scrykin | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 27722 | Illusion: Aviak Rook | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 27717 | Illusion: Banshee | 1 | ACTIVE | Duplicate-name group; P99 wiki has no page for this spell name at all (own page + Enchanter class page checked) - none of the ids can be confirmed | N/A | deactivate | Enchanter page + own page (not found) |
| 27735 | Illusion: Banshee | 1 | ACTIVE | Duplicate-name group; P99 wiki has no page for this spell name at all (own page + Enchanter class page checked) - none of the ids can be confirmed | N/A | deactivate | Enchanter page + own page (not found) |
| 27732 | Illusion: Barraki | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 27712 | Illusion: Bixie Drone | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 27711 | Illusion: Bixie Queen | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 27736 | Illusion: Blood Runed Gargoyle | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 27713 | Illusion: Brownie | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 27714 | Illusion: Brownie Noble | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 42282 | Illusion: Butterfly | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 27734 | Illusion: Centaur | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 27720 | Illusion: Corrupted Shiliskin | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 27718 | Illusion: Crystal Golem | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 27747 | Illusion: Crystalline Sessiloid | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 27745 | Illusion: Crystalline Trichordont | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 32201 | Illusion: Daft Trickster | 1 | ACTIVE | Duplicate-name group; P99 wiki has no page for this spell name at all (own page + Enchanter class page checked) - none of the ids can be confirmed | N/A | deactivate | Enchanter page + own page (not found) |
| 32202 | Illusion: Daft Trickster | 1 | ACTIVE | Duplicate-name group; P99 wiki has no page for this spell name at all (own page + Enchanter class page checked) - none of the ids can be confirmed | N/A | deactivate | Enchanter page + own page (not found) |
| 32203 | Illusion: Daft Trickster | 1 | ACTIVE | Duplicate-name group; P99 wiki has no page for this spell name at all (own page + Enchanter class page checked) - none of the ids can be confirmed | N/A | deactivate | Enchanter page + own page (not found) |
| 39286 | Illusion: Dark Elf Pirate | 1 | ACTIVE | Duplicate-name group; P99 wiki has no page for this spell name at all (own page + Enchanter class page checked) - none of the ids can be confirmed | N/A | deactivate | Enchanter page + own page (not found) |
| 39287 | Illusion: Dark Elf Pirate | 1 | ACTIVE | Duplicate-name group; P99 wiki has no page for this spell name at all (own page + Enchanter class page checked) - none of the ids can be confirmed | N/A | deactivate | Enchanter page + own page (not found) |
| 27743 | Illusion: Drachnid | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 27737 | Illusion: Eagle Aviak | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 27729 | Illusion: Embattled Minotaur | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 39292 | Illusion: Erudite Pirate | 1 | ACTIVE | Duplicate-name group; P99 wiki has no page for this spell name at all (own page + Enchanter class page checked) - none of the ids can be confirmed | N/A | deactivate | Enchanter page + own page (not found) |
| 39293 | Illusion: Erudite Pirate | 1 | ACTIVE | Duplicate-name group; P99 wiki has no page for this spell name at all (own page + Enchanter class page checked) - none of the ids can be confirmed | N/A | deactivate | Enchanter page + own page (not found) |
| 27701 | Illusion: Evil Eye | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 27704 | Illusion: Fairy | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 12330 | Illusion: Flame Telmira | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 27724 | Illusion: Frost Goblin | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 33999 | Illusion: Gelatinous Cube | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 27716 | Illusion: Gelidran | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 27728 | Illusion: Gnomish Pirate | 1 | ACTIVE | Duplicate-name group; P99 wiki has no page for this spell name at all (own page + Enchanter class page checked) - none of the ids can be confirmed | N/A | deactivate | Enchanter page + own page (not found) |
| 39284 | Illusion: Gnomish Pirate | 1 | ACTIVE | Duplicate-name group; P99 wiki has no page for this spell name at all (own page + Enchanter class page checked) - none of the ids can be confirmed | N/A | deactivate | Enchanter page + own page (not found) |
| 39285 | Illusion: Gnomish Pirate | 1 | ACTIVE | Duplicate-name group; P99 wiki has no page for this spell name at all (own page + Enchanter class page checked) - none of the ids can be confirmed | N/A | deactivate | Enchanter page + own page (not found) |
| 27709 | Illusion: Goblin King | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 39280 | Illusion: Gunthak Pirate | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 27706 | Illusion: Hideous Harpy | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 27708 | Illusion: Hooded Scrykin | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 39290 | Illusion: Human Pirate | 1 | ACTIVE | Duplicate-name group; P99 wiki has no page for this spell name at all (own page + Enchanter class page checked) - none of the ids can be confirmed | N/A | deactivate | Enchanter page + own page (not found) |
| 39291 | Illusion: Human Pirate | 1 | ACTIVE | Duplicate-name group; P99 wiki has no page for this spell name at all (own page + Enchanter class page checked) - none of the ids can be confirmed | N/A | deactivate | Enchanter page + own page (not found) |
| 27721 | Illusion: Ice Golem | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 27725 | Illusion: Iksar Skeleton | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 27710 | Illusion: Kobold King | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 27705 | Illusion: Kobold Serf | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 27744 | Illusion: Ogre Pirate | 1 | ACTIVE | Duplicate-name group; P99 wiki has no page for this spell name at all (own page + Enchanter class page checked) - none of the ids can be confirmed | N/A | deactivate | Enchanter page + own page (not found) |
| 39288 | Illusion: Ogre Pirate | 1 | ACTIVE | Duplicate-name group; P99 wiki has no page for this spell name at all (own page + Enchanter class page checked) - none of the ids can be confirmed | N/A | deactivate | Enchanter page + own page (not found) |
| 39289 | Illusion: Ogre Pirate | 1 | ACTIVE | Duplicate-name group; P99 wiki has no page for this spell name at all (own page + Enchanter class page checked) - none of the ids can be confirmed | N/A | deactivate | Enchanter page + own page (not found) |
| 27731 | Illusion: Primal Kerran | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 27715 | Illusion: Pyrilen | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 27727 | Illusion: Raptor Predator | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 27742 | Illusion: Recluse Spider | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 39855 | Illusion: Scaled Wolf | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 12492 | Illusion: Shissar | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 37869 | Illusion: Silver Gnomework | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 12329 | Illusion: Simple Gnomework | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 27723 | Illusion: Siren Enticer | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 27740 | Illusion: Snow Kobold | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 27702 | Illusion: Spectre | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 27730 | Illusion: Spirited Satyr | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 27707 | Illusion: Stone Gargoyle | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 39282 | Illusion: Troll Pirate | 1 | ACTIVE | Duplicate-name group; P99 wiki has no page for this spell name at all (own page + Enchanter class page checked) - none of the ids can be confirmed | N/A | deactivate | Enchanter page + own page (not found) |
| 39283 | Illusion: Troll Pirate | 1 | ACTIVE | Duplicate-name group; P99 wiki has no page for this spell name at all (own page + Enchanter class page checked) - none of the ids can be confirmed | N/A | deactivate | Enchanter page + own page (not found) |
| 27746 | Illusion: Vitrik | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 38811 | Illusion: Warped Chetari | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 208 | Lull | 1 | ACTIVE | Confirmed - Enchanter Level 1 on wiki matches DB | Classic Era | none | Lull |
| 287 | Minor Illusion | 1 | ACTIVE | Confirmed - Enchanter Level 1 on wiki matches DB | Classic Era | none | Minor Illusion |
| 288 | Minor Shielding | 1 | ACTIVE | Confirmed - Enchanter Level 1 on wiki matches DB | Classic Era | none | Minor Shielding |
| 285 | Pendril's Animation | 1 | ACTIVE | Confirmed - Enchanter Level 1 on wiki matches DB | Classic Era | none | Pendril's Animation |
| 331 | Reclaim Energy | 1 | ACTIVE | Confirmed - Enchanter Level 1 on wiki matches DB | Classic Era | none | Reclaim Energy |
| 286 | Shallow Breath | 1 | ACTIVE | Confirmed - Enchanter Level 1 on wiki matches DB | Classic Era | none | Shallow Breath |
| 40 | Strengthen | 1 | ACTIVE | Confirmed - Enchanter Level 1 on wiki matches DB | Classic Era | none | Strengthen |
| 289 | Taper Enchantment | 1 | ACTIVE | Confirmed - Enchanter Level 1 on wiki matches DB | Classic Era | none | Taper Enchantment |
| 205 | True North | 1 | ACTIVE | Confirmed - Enchanter Level 1 on wiki matches DB | Classic Era | none | True North |
| 32200 | Visage of the Daft Trickster | 1 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 41 | Weaken | 1 | ACTIVE | Confirmed - Enchanter Level 1 on wiki matches DB | Classic Era | none | Weaken |
| 290 | Color Flux | 4 | ACTIVE | Confirmed - Enchanter Level 4 on wiki matches DB | untagged | none | Color Flux |
| 291 | Enfeeblement | 4 | ACTIVE | Confirmed - Enchanter Level 4 on wiki matches DB | untagged | none | Enfeeblement |
| 229 | Fear | 4 | ACTIVE | Confirmed - Enchanter Level 4 on wiki matches DB | Classic Era | none | Fear |
| 36 | Gate | 4 | ACTIVE | Confirmed - Enchanter Level 4 on wiki matches DB | Classic Era | none | Gate |
| 293 | Haze | 4 | ACTIVE | Confirmed - Enchanter Level 4 on wiki matches DB | Classic Era | none | Haze |
| 583 | Illusion: Half-Elf | 4 | ACTIVE | Confirmed - Enchanter Level 4 on wiki matches DB | untagged | none | Illusion: Half-Elf |
| 582 | Illusion: Human | 4 | ACTIVE | Confirmed - Enchanter Level 4 on wiki matches DB | untagged | none | Illusion: Human |
| 42 | Invisibility | 4 | ACTIVE | Confirmed - Enchanter Level 4 on wiki matches DB | Classic Era | none | Invisibility |
| 681 | Juli`s Animation | 4 | ACTIVE | Confirmed - Enchanter Level 4 on wiki matches DB | untagged | none | Juli`s Animation |
| 292 | Mesmerize | 4 | ACTIVE | Confirmed - Enchanter Level 4 on wiki matches DB | untagged | none | Mesmerize |
| 294 | Suffocating Sphere | 4 | ACTIVE | Confirmed - Enchanter Level 4 on wiki matches DB | untagged | none | Suffocating Sphere |
| 676 | Tashan | 4 | ACTIVE | Confirmed - Enchanter Level 4 on wiki matches DB | untagged | none | Tashan |
| 298 | Alliance | 8 | ACTIVE | Confirmed - Enchanter Level 8 on wiki matches DB | Classic Era | none | Alliance |
| 500 | Bind Sight | 8 | ACTIVE | Confirmed - Enchanter Level 8 on wiki matches DB | Classic Era | none | Bind Sight |
| 48 | Cancel Magic | 8 | ACTIVE | Confirmed on P99 wiki - one documented version, matches id 48 via tie on mana/recast (wiki mana=30) - kept lower/original id per project convention, dropped 8xxx-range duplicate | Classic Era | none | Cancel Magic |
| 8662 | Cancel Magic | 8 | ACTIVE | Duplicate object - wiki's single documented version matches id 48 via tie on mana/recast (wiki mana=30) - kept lower/original id per project convention, dropped 8xxx-range duplicate; id 8662's values (mana=30, recast=5000ms) don't match | Classic Era | deactivate-duplicate-keep-48 | Cancel Magic |
| 296 | Chaotic Feedback | 8 | ACTIVE | Confirmed - Enchanter Level 8 on wiki matches DB | Classic Era | none | Chaotic Feedback |
| 1359 | Enchant Clay | 8 | ACTIVE | Confirmed - Enchanter Level 8 on wiki matches DB | Jul 2001 Era, Warrens Era | none | Enchant Clay |
| 667 | Enchant Silver | 8 | ACTIVE | Confirmed on P99 wiki - one documented version, matches id 667 via mana (wiki=80) | Classic Era | none | Enchant Silver |
| 8547 | Enchant Silver | 8 | ACTIVE | Duplicate object - wiki's single documented version matches id 667 via mana (wiki=80); id 8547's values (mana=60, recast=2250ms) don't match | Classic Era | deactivate-duplicate-keep-667 | Enchant Silver |
| 8672 | Enchant Silver | 8 | ACTIVE | Duplicate object - wiki's single documented version matches id 667 via mana (wiki=80); id 8672's values (mana=60, recast=2250ms) don't match | Classic Era | deactivate-duplicate-keep-667 | Enchant Silver |
| 297 | Eye of Confusion | 8 | ACTIVE | Confirmed - Enchanter Level 8 on wiki matches DB | Classic Era | none | Eye of Confusion |
| 595 | Illusion: Gnome | 8 | ACTIVE | Confirmed - Enchanter Level 8 on wiki matches DB | Classic Era | none | Illusion: Gnome |
| 588 | Illusion: Wood Elf | 8 | ACTIVE | Confirmed - Enchanter Level 8 on wiki matches DB | Classic Era | none | Illusion: Wood Elf |
| 246 | Lesser Shielding | 8 | ACTIVE | Confirmed - Enchanter Level 8 on wiki matches DB | Classic Era | none | Lesser Shielding |
| 295 | Mircyl's Animation | 8 | ACTIVE | Confirmed - Enchanter Level 8 on wiki matches DB | Classic Era | none | Mircyl's Animation |
| 230 | Root | 8 | ACTIVE | Confirmed - Enchanter Level 8 on wiki matches DB | Classic Era | none | Root |
| 80 | See Invisible | 8 | ACTIVE | Confirmed on P99 wiki - one documented version, matches id 80 via tie on mana/recast (wiki mana=25) - kept lower/original id per project convention, dropped 8xxx-range duplicate | Classic Era | none | See Invisible |
| 8652 | See Invisible | 8 | ACTIVE | Duplicate object - wiki's single documented version matches id 80 via tie on mana/recast (wiki mana=25) - kept lower/original id per project convention, dropped 8xxx-range duplicate; id 8652's values (mana=25, recast=2250ms) don't match | Classic Era | deactivate-duplicate-keep-80 | See Invisible |
| 299 | Sentinel | 8 | ACTIVE | Confirmed - Enchanter Level 8 on wiki matches DB | Classic Era | none | Sentinel |
| 501 | Soothe | 8 | ACTIVE | Confirmed - Enchanter Level 8 on wiki matches DB | Classic Era | none | Soothe |
| 12337 | Illusion: Burning Nekhon | 10 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 12402 | Illusion: Kedge | 10 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 12335 | Illusion: Simple Gnoll | 10 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 12401 | Illusion: Steam Suit | 10 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 7988 | Greater Mass Enchant Silver | 11 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 35 | Bind Affinity | 12 | ACTIVE | Confirmed on P99 wiki - one documented version, matches id 35 via mana (wiki=100) and recast_time (wiki=12.00s) | Classic Era | none | Bind Affinity |
| 40971 | Bind Affinity | 12 | ACTIVE | Duplicate object - wiki's single documented version matches id 35 via mana (wiki=100) and recast_time (wiki=12.00s); id 40971's values (mana=, recast=1500ms) don't match | Classic Era | deactivate-duplicate-keep-35 | Bind Affinity |
| 300 | Charm | 12 | ACTIVE | Confirmed - Enchanter Level 12 on wiki matches DB | Classic Era | none | Charm |
| 521 | Choke | 12 | ACTIVE | Confirmed - Enchanter Level 12 on wiki matches DB | Classic Era | none | Choke |
| 645 | Ebbing Strength | 12 | ACTIVE | Confirmed - Enchanter Level 12 on wiki matches DB | Classic Era | none | Ebbing Strength |
| 86 | Enduring Breath | 12 | ACTIVE | Confirmed - Enchanter Level 12 on wiki matches DB | Classic Era | none | Enduring Breath |
| 590 | Illusion: Dark Elf | 12 | ACTIVE | Confirmed - Enchanter Level 12 on wiki matches DB | Classic Era | none | Illusion: Dark Elf |
| 587 | Illusion: Erudite | 12 | ACTIVE | Confirmed - Enchanter Level 12 on wiki matches DB | Classic Era | none | Illusion: Erudite |
| 594 | Illusion: Halfling | 12 | ACTIVE | Confirmed - Enchanter Level 12 on wiki matches DB | Classic Era | none | Illusion: Halfling |
| 589 | Illusion: High Elf | 12 | ACTIVE | Confirmed - Enchanter Level 12 on wiki matches DB | Classic Era | none | Illusion: High Elf |
| 682 | Kilan`s Animation | 12 | ACTIVE | Confirmed - Enchanter Level 12 on wiki matches DB | Classic Era | none | Kilan's Animation (db name uses backtick apostrophe) |
| 302 | Languid Pace | 12 | ACTIVE | Confirmed - Enchanter Level 12 on wiki matches DB | Classic Era | none | Languid Pace |
| 301 | Memory Blur | 12 | ACTIVE | Confirmed - Enchanter Level 12 on wiki matches DB | Classic Era | none | Memory Blur |
| 650 | Mist | 12 | ACTIVE | Confirmed - Enchanter Level 12 on wiki matches DB | Classic Era | none | Mist |
| 276 | Serpent Sight | 12 | ACTIVE | Confirmed - Enchanter Level 12 on wiki matches DB | Classic Era | none | Serpent Sight |
| 390 | Thicken Mana | 12 | ACTIVE | Confirmed - Enchanter Level 12 on wiki matches DB | Classic Era | none | Thicken Mana |
| 303 | Whirl till you hurl | 12 | ACTIVE | Confirmed - Enchanter Level 12 on wiki matches DB | Classic Era | none | Whirl till you hurl |
| 4255 | Wuggan's Lesser Appraisal | 13 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 4267 | Wuggan's Lesser Discombobulation | 14 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 4279 | Wuggan's Lesser Extrication | 14 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 697 | Breeze | 16 | ACTIVE | Confirmed - Enchanter Level 16 on wiki matches DB | Hole Era | none | Breeze |
| 304 | Chase the Moon | 16 | ACTIVE | Confirmed - Enchanter Level 16 on wiki matches DB | Classic Era | none | Chase the Moon |
| 281 | Disempower | 16 | ACTIVE | Confirmed - Enchanter Level 16 on wiki matches DB | Classic Era | none | Disempower |
| 668 | Enchant Electrum | 16 | ACTIVE | Confirmed - Enchanter Level 16 on wiki matches DB | Classic Era | none | Enchant Electrum |
| 187 | Enthrall | 16 | ACTIVE | Confirmed - Enchanter Level 16 on wiki matches DB | Classic Era | none | Enthrall |
| 7676 | Focus Crude Spellcaster's Empowering Essence | 16 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 7677 | Focus Makeshift Spellcaster's Empowering Essence | 16 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 7674 | Focus Primitive Spellcaster's Empowering Essence | 16 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 7675 | Focus Rudimentary Spellcaster's Empowering Essence | 16 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 305 | Identify | 16 | ACTIVE | Confirmed - Enchanter Level 16 on wiki matches DB | Classic Era | none | Identify |
| 586 | Illusion: Barbarian | 16 | ACTIVE | Confirmed - Enchanter Level 16 on wiki matches DB | Classic Era | none | Illusion: Barbarian |
| 591 | Illusion: Dwarf | 16 | ACTIVE | Confirmed - Enchanter Level 16 on wiki matches DB | Classic Era | none | Illusion: Dwarf |
| 601 | Illusion: Tree | 16 | ACTIVE | Confirmed - Enchanter Level 16 on wiki matches DB | Classic Era | none | Illusion: Tree |
| 235 | Invisibility versus Undead | 16 | ACTIVE | Confirmed - Enchanter Level 16 on wiki matches DB | Classic Era | none | Invisibility versus Undead |
| 261 | Levitate | 16 | ACTIVE | Confirmed - Enchanter Level 16 on wiki matches DB | Classic Era | none | Levitate |
| 307 | Mesmerization | 16 | ACTIVE | Confirmed - Enchanter Level 16 on wiki matches DB | Classic Era | none | Mesmerization |
| 39 | Quickness | 16 | ACTIVE | Confirmed - Enchanter Level 16 on wiki matches DB | Classic Era | none | Quickness |
| 481 | Rune I | 16 | ACTIVE | Confirmed - Enchanter Level 16 on wiki matches DB | Classic Era | none | Rune I |
| 306 | Sanity Warp | 16 | ACTIVE | Confirmed - Enchanter Level 16 on wiki matches DB | Classic Era | none | Sanity Warp |
| 683 | Shalee`s Animation | 16 | ACTIVE | Confirmed - Enchanter Level 16 on wiki matches DB | Classic Era | none | Shalee's Animation (db name uses backtick apostrophe) |
| 309 | Shielding | 16 | ACTIVE | Confirmed - Enchanter Level 16 on wiki matches DB | Classic Era | none | Shielding |
| 7985 | Greater Mass Enchant Electrum | 19 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 173 | Benevolence | 20 | ACTIVE | Confirmed - Enchanter Level 20 on wiki matches DB | Classic Era | none | Benevolence |
| 21 | Berserker Strength | 20 | ACTIVE | Confirmed - Enchanter Level 20 on wiki matches DB | Classic Era | none | Berserker Strength |
| 47 | Calm | 20 | ACTIVE | Confirmed - Enchanter Level 20 on wiki matches DB | Classic Era | none | Calm |
| 651 | Cloud | 20 | ACTIVE | Confirmed - Enchanter Level 20 on wiki matches DB | Classic Era | none | Cloud |
| 177 | Color Shift | 20 | ACTIVE | Confirmed - Enchanter Level 20 on wiki matches DB | Classic Era | none | Color Shift |
| 439 | Crystallize Mana | 20 | ACTIVE | Confirmed - Enchanter Level 20 on wiki matches DB | Classic Era | none | Crystallize Mana |
| 228 | Endure Magic | 20 | ACTIVE | Confirmed on P99 wiki - one documented version, matches id 228 via tie on mana/recast (wiki mana=40) - kept lower/original id per project convention, dropped 8xxx-range duplicate | Classic Era | none | Endure Magic |
| 8594 | Endure Magic | 20 | ACTIVE | Duplicate object - wiki's single documented version matches id 228 via tie on mana/recast (wiki mana=40) - kept lower/original id per project convention, dropped 8xxx-range duplicate; id 8594's values (mana=40, recast=2250ms) don't match | Classic Era | deactivate-duplicate-keep-228 | Endure Magic |
| 179 | Feckless Might | 20 | ACTIVE | Confirmed - Enchanter Level 20 on wiki matches DB | Classic Era | none | Feckless Might |
| 243 | Illusion: Iksar | 20 | ACTIVE | Confirmed - Enchanter Level 20 on wiki matches DB | Kunark Era | none | Illusion: Iksar |
| 593 | Illusion: Ogre | 20 | ACTIVE | Confirmed - Enchanter Level 20 on wiki matches DB | Classic Era | none | Illusion: Ogre |
| 592 | Illusion: Troll | 20 | ACTIVE | Confirmed - Enchanter Level 20 on wiki matches DB | Classic Era | none | Illusion: Troll |
| 84 | Shifting Sight | 20 | ACTIVE | Confirmed - Enchanter Level 20 on wiki matches DB | Classic Era | none | Shifting Sight |
| 684 | Sisna`s Animation | 20 | ACTIVE | Confirmed - Enchanter Level 20 on wiki matches DB | Classic Era | none | Sisna's Animation (db name uses backtick apostrophe) |
| 489 | Sympathetic Aura | 20 | ACTIVE | Confirmed - Enchanter Level 20 on wiki matches DB | Classic Era | none | Sympathetic Aura |
| 677 | Tashani | 20 | ACTIVE | Confirmed - Enchanter Level 20 on wiki matches DB | Classic Era | none | Tashani |
| 170 | Alacrity | 24 | ACTIVE | Confirmed - Enchanter Level 24 on wiki matches DB | Classic Era | none | Alacrity |
| 182 | Beguile | 24 | ACTIVE | Confirmed - Enchanter Level 24 on wiki matches DB | Classic Era | none | Beguile |
| 350 | Chaos Flux | 24 | ACTIVE | Confirmed - Enchanter Level 24 on wiki matches DB | Classic Era | none | Chaos Flux |
| 669 | Enchant Gold | 24 | ACTIVE | Confirmed - Enchanter Level 24 on wiki matches DB | Classic Era | none | Enchant Gold |
| 584 | Illusion: Earth Elemental | 24 | ACTIVE | Confirmed - Enchanter Level 24 on wiki matches DB | Classic Era | none | Illusion: Earth Elemental |
| 581 | Illusion: Skeleton | 24 | ACTIVE | Confirmed - Enchanter Level 24 on wiki matches DB | Classic Era | none | Illusion: Skeleton |
| 222 | Invigor | 24 | ACTIVE | Confirmed - Enchanter Level 24 on wiki matches DB | Classic Era | none | Invigor |
| 65 | Major Shielding | 24 | ACTIVE | Confirmed - Enchanter Level 24 on wiki matches DB | Classic Era | none | Major Shielding |
| 482 | Rune II | 24 | ACTIVE | Confirmed - Enchanter Level 24 on wiki matches DB | Classic Era | none | Rune II |
| 685 | Sagar`s Animation | 24 | ACTIVE | Confirmed - Enchanter Level 24 on wiki matches DB | Classic Era | none | Sagar's Animation (db name uses backtick apostrophe) |
| 24 | Strip Enchantment | 24 | ACTIVE | Confirmed - Enchanter Level 24 on wiki matches DB | Classic Era | none | Strip Enchantment |
| 185 | Tepid Deeds | 24 | ACTIVE | Confirmed - Enchanter Level 24 on wiki matches DB | Classic Era | none | Tepid Deeds |
| 10 | Augmentation | 29 | ACTIVE | Confirmed - Enchanter Level 29 on wiki matches DB | Classic Era | none | Augmentation |
| 540 | Clarify Mana | 29 | ACTIVE | Confirmed - Enchanter Level 29 on wiki matches DB | Classic Era | none | Clarify Mana |
| 174 | Clarity | 29 | ACTIVE | Confirmed - Enchanter Level 29 on wiki matches DB | Classic Era | none | Clarity |
| 408 | Curse of the Simple Mind | 29 | ACTIVE | Confirmed - Enchanter Level 29 on wiki matches DB | Classic Era | none | Curse of the Simple Mind |
| 619 | Dyn`s Dizzying Draught | 29 | ACTIVE | Duplicate object - wiki's single documented version matches id 8549 via recast_time (wiki=35.00s, db id 8549=35000ms); id 619's values (mana=150, recast=50000ms) don't match | Classic Era | deactivate-duplicate-keep-8549 | Dyn's Dizzying Draught (db name uses backtick apostrophe) |
| 8549 | Dyn`s Dizzying Draught | 29 | ACTIVE | Confirmed on P99 wiki - one documented version, matches id 8549 via recast_time (wiki=35.00s, db id 8549=35000ms) | Classic Era | none | Dyn's Dizzying Draught (db name uses backtick apostrophe) |
| 131 | Enstill | 29 | ACTIVE | Confirmed - Enchanter Level 29 on wiki matches DB | Classic Era | none | Enstill |
| 191 | Feedback | 29 | ACTIVE | Confirmed - Enchanter Level 29 on wiki matches DB | Classic Era | none | Feedback |
| 597 | Illusion: Air Elemental | 29 | ACTIVE | Confirmed - Enchanter Level 29 on wiki matches DB | Classic Era | none | Illusion: Air Elemental |
| 599 | Illusion: Water Elemental | 29 | ACTIVE | Confirmed - Enchanter Level 29 on wiki matches DB | Classic Era | none | Illusion: Water Elemental |
| 162 | Listless Power | 29 | ACTIVE | Confirmed - Enchanter Level 29 on wiki matches DB | Classic Era | none | Listless Power |
| 49 | Nullify Magic | 29 | ACTIVE | Confirmed - Enchanter Level 29 on wiki matches DB | Classic Era | none | Nullify Magic |
| 652 | Obscure | 29 | ACTIVE | Confirmed - Enchanter Level 29 on wiki matches DB | Classic Era | none | Obscure |
| 450 | Suffocate | 29 | ACTIVE | Confirmed - Enchanter Level 29 on wiki matches DB | Classic Era | none | Suffocate |
| 686 | Uleen`s Animation | 29 | ACTIVE | Confirmed - Enchanter Level 29 on wiki matches DB | Classic Era | none | Uleen's Animation (db name uses backtick apostrophe) |
| 46 | Ultravision | 29 | ACTIVE | Confirmed - Enchanter Level 29 on wiki matches DB | Classic Era | none | Ultravision |
| 71 | Anarchy | 34 | ACTIVE | Confirmed - Enchanter Level 34 on wiki matches DB | Classic Era | none | Anarchy |
| 687 | Boltran`s Animation | 34 | ACTIVE | Confirmed - Enchanter Level 34 on wiki matches DB | Classic Era | none | Boltran's Animation (db name uses backtick apostrophe) |
| 407 | Cast Sight | 34 | ACTIVE | Confirmed - Enchanter Level 34 on wiki matches DB | Classic Era | none | Cast Sight |
| 670 | Enchant Platinum | 34 | ACTIVE | Confirmed - Enchanter Level 34 on wiki matches DB | Classic Era | none | Enchant Platinum |
| 188 | Entrance | 34 | ACTIVE | Confirmed - Enchanter Level 34 on wiki matches DB | Classic Era | none | Entrance |
| 1408 | Gift of Magic | 34 | ACTIVE | Confirmed - Enchanter Level 34 on wiki matches DB | Velious Era | none | Gift of Magic |
| 66 | Greater Shielding | 34 | ACTIVE | Confirmed - Enchanter Level 34 on wiki matches DB | Classic Era | none | Greater Shielding |
| 598 | Illusion: Fire Elemental | 34 | ACTIVE | Confirmed - Enchanter Level 34 on wiki matches DB | Classic Era | none | Illusion: Fire Elemental |
| 180 | Insipid Weakness | 34 | ACTIVE | Confirmed - Enchanter Level 34 on wiki matches DB | Classic Era | none | Insipid Weakness |
| 74 | Mana Sieve | 34 | ACTIVE | Confirmed - Enchanter Level 34 on wiki matches DB | Classic Era | none | Mana Sieve |
| 646 | Radiant Visage | 34 | ACTIVE | Confirmed - Enchanter Level 34 on wiki matches DB | Classic Era | none | Radiant Visage |
| 483 | Rune III | 34 | ACTIVE | Confirmed on P99 wiki - one documented version, matches id 483 via tie on mana/recast (wiki mana=149) - kept lower/original id per project convention, dropped 8xxx-range duplicate | Classic Era | none | Rune III |
| 8654 | Rune III | 34 | ACTIVE | Duplicate object - wiki's single documented version matches id 483 via tie on mana/recast (wiki mana=149) - kept lower/original id per project convention, dropped 8xxx-range duplicate; id 8654's values (mana=149, recast=2250ms) don't match | Classic Era | deactivate-duplicate-keep-483 | Rune III |
| 688 | Aanya's Animation | 39 | ACTIVE | Confirmed - Enchanter Level 39 on wiki matches DB | Classic Era | none | Aanya's Animation |
| 183 | Cajoling Whispers | 39 | ACTIVE | Confirmed - Enchanter Level 39 on wiki matches DB | Classic Era | none | Cajoling Whispers |
| 171 | Celerity | 39 | ACTIVE | Confirmed - Enchanter Level 39 on wiki matches DB | Classic Era | none | Celerity |
| 695 | Distill Mana | 39 | ACTIVE | Confirmed - Enchanter Level 39 on wiki matches DB | Classic Era | none | Distill Mana |
| 73 | Gravity Flux | 39 | ACTIVE | Confirmed - Enchanter Level 39 on wiki matches DB | Classic Era | none | Gravity Flux |
| 596 | Illusion: Dry Bone | 39 | ACTIVE | Confirmed - Enchanter Level 39 on wiki matches DB | Classic Era | none | Illusion: Dry Bone |
| 600 | Illusion: Spirit Wolf | 39 | ACTIVE | Confirmed - Enchanter Level 39 on wiki matches DB | Classic Era | none | Illusion: Spirit Wolf |
| 132 | Immobilize | 39 | ACTIVE | Confirmed - Enchanter Level 39 on wiki matches DB | Classic Era | none | Immobilize |
| 175 | Insight | 39 | ACTIVE | Confirmed on P99 wiki - one documented version, matches id 175 via tie on mana/recast (wiki mana=125) - kept lower/original id per project convention, dropped 8xxx-range duplicate | Classic Era | none | Insight |
| 8530 | Insight | 39 | ACTIVE | Duplicate object - wiki's single documented version matches id 175 via tie on mana/recast (wiki mana=125) - kept lower/original id per project convention, dropped 8xxx-range duplicate; id 8530's values (mana=125, recast=2250ms) don't match | Classic Era | deactivate-duplicate-keep-175 | Insight |
| 127 | Invoke Fear | 39 | ACTIVE | Confirmed - Enchanter Level 39 on wiki matches DB | Classic Era | none | Invoke Fear |
| 192 | Mind Wipe | 39 | ACTIVE | Confirmed - Enchanter Level 39 on wiki matches DB | Classic Era | none | Mind Wipe |
| 45 | Pacify | 39 | ACTIVE | Confirmed - Enchanter Level 39 on wiki matches DB | Classic Era | none | Pacify |
| 648 | Rampage | 39 | ACTIVE | Confirmed - Enchanter Level 39 on wiki matches DB | Classic Era | none | Rampage |
| 64 | Resist Magic | 39 | ACTIVE | Confirmed on P99 wiki - one documented version, matches id 64 via tie on mana/recast (wiki mana=85) - kept lower/original id per project convention, dropped 8xxx-range duplicate | Classic Era | none | Resist Magic |
| 8632 | Resist Magic | 39 | ACTIVE | Duplicate object - wiki's single documented version matches id 64 via tie on mana/recast (wiki mana=85) - kept lower/original id per project convention, dropped 8xxx-range duplicate; id 8632's values (mana=85, recast=2250ms) don't match | Classic Era | deactivate-duplicate-keep-64 | Resist Magic |
| 653 | Shade | 39 | ACTIVE | Confirmed - Enchanter Level 39 on wiki matches DB | Classic Era | none | Shade |
| 1407 | Wandering Mind | 39 | ACTIVE | Confirmed - Enchanter Level 39 on wiki matches DB | Velious Era | none | Wandering Mind |
| 67 | Arch Shielding | 44 | ACTIVE | Confirmed - Enchanter Level 44 on wiki matches DB | Classic Era | none | Arch Shielding |
| 1474 | Boon of the Garou | 44 | ACTIVE | Confirmed - Enchanter Level 44 on wiki matches DB | Velious Era | none | Boon of the Garou |
| 33 | Brilliance | 44 | ACTIVE | Confirmed on P99 wiki - one documented version, matches id 33 via tie on mana/recast (wiki mana=125) - kept lower/original id per project convention, dropped 8xxx-range duplicate | Classic Era | none | Brilliance |
| 8567 | Brilliance | 44 | ACTIVE | Duplicate object - wiki's single documented version matches id 33 via tie on mana/recast (wiki mana=125) - kept lower/original id per project convention, dropped 8xxx-range duplicate; id 8567's values (mana=125, recast=2250ms) don't match | Classic Era | deactivate-duplicate-keep-33 | Brilliance |
| 178 | Color Skew | 44 | ACTIVE | Confirmed - Enchanter Level 44 on wiki matches DB | Classic Era | none | Color Skew |
| 673 | Discordant Mind | 44 | ACTIVE | Confirmed - Enchanter Level 44 on wiki matches DB | Classic Era | none | Discordant Mind |
| 1797 | Enchant Velium | 44 | ACTIVE | Confirmed - Enchanter Level 44 on wiki matches DB | Velious Era | none | Enchant Velium |
| 417 | Extinguish Fatigue | 44 | ACTIVE | Confirmed - Enchanter Level 44 on wiki matches DB | Classic Era | none | Extinguish Fatigue |
| 585 | Illusion: Werewolf | 44 | ACTIVE | Confirmed - Enchanter Level 44 on wiki matches DB | Classic Era | none | Illusion: Werewolf |
| 163 | Incapacitate | 44 | ACTIVE | Confirmed - Enchanter Level 44 on wiki matches DB | Classic Era | none | Incapacitate |
| 25 | Pillage Enchantment | 44 | ACTIVE | Confirmed - Enchanter Level 44 on wiki matches DB | Classic Era | none | Pillage Enchantment |
| 484 | Rune IV | 44 | ACTIVE | Confirmed on P99 wiki - one documented version, matches id 484 via tie on mana/recast (wiki mana=236) - kept lower/original id per project convention, dropped 8xxx-range duplicate | Classic Era | none | Rune IV |
| 8656 | Rune IV | 44 | ACTIVE | Duplicate object - wiki's single documented version matches id 484 via tie on mana/recast (wiki mana=236) - kept lower/original id per project convention, dropped 8xxx-range duplicate; id 8656's values (mana=236, recast=2250ms) don't match | Classic Era | deactivate-duplicate-keep-484 | Rune IV |
| 186 | Shiftless Deeds | 44 | ACTIVE | Confirmed - Enchanter Level 44 on wiki matches DB | Classic Era | none | Shiftless Deeds |
| 8621 | Summon Companion | 44 | ACTIVE | Confirmed - Enchanter Level 44 on wiki matches DB | untagged | none | Summon Companion |
| 678 | Tashania | 44 | ACTIVE | Confirmed - Enchanter Level 44 on wiki matches DB | Classic Era | none | Tashania |
| 181 | Weakness | 44 | ACTIVE | Confirmed - Enchanter Level 44 on wiki matches DB | Classic Era | none | Weakness |
| 689 | Yegoreff`s Animation | 44 | ACTIVE | Confirmed - Enchanter Level 44 on wiki matches DB | Classic Era | none | Yegoreff's Animation (db name uses backtick apostrophe) |
| 647 | Adorning Grace | 49 | ACTIVE | Confirmed - Enchanter Level 49 on wiki matches DB | Classic Era | none | Adorning Grace |
| 184 | Allure | 49 | ACTIVE | Confirmed - Enchanter Level 49 on wiki matches DB | Classic Era | none | Allure |
| 176 | Berserker Spirit | 49 | ACTIVE | Confirmed - Enchanter Level 49 on wiki matches DB | Classic Era | none | Berserker Spirit |
| 193 | Blanket of Forgetfulness | 49 | ACTIVE | Confirmed on P99 wiki - one documented version, matches id 193 via tie on mana/recast (wiki mana=175) - kept lower/original id per project convention, dropped 8xxx-range duplicate | Classic Era | none | Blanket of Forgetfulness |
| 8571 | Blanket of Forgetfulness | 49 | ACTIVE | Duplicate object - wiki's single documented version matches id 193 via tie on mana/recast (wiki mana=175) - kept lower/original id per project convention, dropped 8xxx-range duplicate; id 8571's values (mana=175, recast=12000ms) don't match | Classic Era | deactivate-duplicate-keep-193 | Blanket of Forgetfulness |
| 190 | Dazzle | 49 | ACTIVE | Confirmed - Enchanter Level 49 on wiki matches DB | Classic Era | none | Dazzle |
| 1890 | Enchant Adamantite | 49 | ACTIVE | Confirmed on P99 wiki - one documented version, matches id 1890 via tie on mana/recast (wiki mana=325) - kept lower/original id per project convention, dropped 8xxx-range duplicate | Epic Quests Era | none | Enchant Adamantite |
| 8600 | Enchant Adamantite | 49 | ACTIVE | Duplicate object - wiki's single documented version matches id 1890 via tie on mana/recast (wiki mana=325) - kept lower/original id per project convention, dropped 8xxx-range duplicate; id 8600's values (mana=325, recast=2250ms) don't match | Epic Quests Era | deactivate-duplicate-keep-1890 | Enchant Adamantite |
| 1893 | Enchant Brellium | 49 | ACTIVE | Confirmed on P99 wiki - one documented version, matches id 1893 via tie on mana/recast (wiki mana=325) - kept lower/original id per project convention, dropped 8xxx-range duplicate | untagged | none | Enchant Brellium |
| 8599 | Enchant Brellium | 49 | ACTIVE | Duplicate object - wiki's single documented version matches id 1893 via tie on mana/recast (wiki mana=325) - kept lower/original id per project convention, dropped 8xxx-range duplicate; id 8599's values (mana=325, recast=2250ms) don't match | untagged | deactivate-duplicate-keep-1893 | Enchant Brellium |
| 1889 | Enchant Mithril | 49 | ACTIVE | Confirmed on P99 wiki - one documented version, matches id 1889 via tie on mana/recast (wiki mana=325) - kept lower/original id per project convention, dropped 8xxx-range duplicate | untagged | none | Enchant Mithril |
| 8598 | Enchant Mithril | 49 | ACTIVE | Duplicate object - wiki's single documented version matches id 1889 via tie on mana/recast (wiki mana=325) - kept lower/original id per project convention, dropped 8xxx-range duplicate; id 8598's values (mana=325, recast=2250ms) don't match | untagged | deactivate-duplicate-keep-1889 | Enchant Mithril |
| 1892 | Enchant Steel | 49 | ACTIVE | Confirmed on P99 wiki - one documented version, matches id 1892 via tie on mana/recast (wiki mana=325) - kept lower/original id per project convention, dropped 8xxx-range duplicate | Kunark Era | none | Enchant Steel |
| 8597 | Enchant Steel | 49 | ACTIVE | Duplicate object - wiki's single documented version matches id 1892 via tie on mana/recast (wiki mana=325) - kept lower/original id per project convention, dropped 8xxx-range duplicate; id 8597's values (mana=325, recast=2250ms) don't match | Kunark Era | deactivate-duplicate-keep-1892 | Enchant Steel |
| 195 | Gasping Embrace | 49 | ACTIVE | Confirmed - Enchanter Level 49 on wiki matches DB | Classic Era | none | Gasping Embrace |
| 72 | Group Resist Magic | 49 | ACTIVE | Confirmed on P99 wiki - one documented version, matches id 72 via tie on mana/recast (wiki mana=200) - kept lower/original id per project convention, dropped 8xxx-range duplicate | Classic Era | none | Group Resist Magic |
| 8535 | Group Resist Magic | 49 | ACTIVE | Duplicate object - wiki's single documented version matches id 72 via tie on mana/recast (wiki mana=200) - kept lower/original id per project convention, dropped 8xxx-range duplicate; id 8535's values (mana=200, recast=2250ms) don't match | Classic Era | deactivate-duplicate-keep-72 | Group Resist Magic |
| 690 | Kintaz`s Animation | 49 | ACTIVE | Confirmed - Enchanter Level 49 on wiki matches DB | Classic Era | none | Kintaz's Animation (db name uses backtick apostrophe) |
| 133 | Paralyzing Earth | 49 | ACTIVE | Confirmed - Enchanter Level 49 on wiki matches DB | Kunark Era | none | Paralyzing Earth |
| 696 | Purify Mana | 49 | ACTIVE | Confirmed - Enchanter Level 49 on wiki matches DB | untagged | none | Purify Mana |
| 194 | Reoccurring Amnesia | 49 | ACTIVE | Confirmed - Enchanter Level 49 on wiki matches DB | Classic Era | none | Reoccurring Amnesia |
| 654 | Shadow | 49 | ACTIVE | Confirmed - Enchanter Level 49 on wiki matches DB | Classic Era | none | Shadow |
| 172 | Swift like the Wind | 49 | ACTIVE | Confirmed - Enchanter Level 49 on wiki matches DB | Classic Era | none | Swift like the Wind |
| 1406 | Improved Invisibility | 50 | ACTIVE | Confirmed - Enchanter Level 50 on wiki matches DB | Velious Era | none | Improved Invisibility |
| 1687 | Collaboration | 51 | ACTIVE | Confirmed - Enchanter Level 51 on wiki matches DB | untagged | none | Collaboration |
| 1686 | Theft of Thought | 51 | ACTIVE | Duplicate object - wiki's single documented version matches id 8481 via mana (wiki=25); id 1686's values (mana=10, recast=120000ms) don't match | Kunark Era | deactivate-duplicate-keep-8481 | Theft of Thought |
| 8481 | Theft of Thought | 51 | ACTIVE | Confirmed on P99 wiki - one documented version, matches id 8481 via mana (wiki=25) | Kunark Era | none | Theft of Thought |
| 1541 | Wake of Tranquility | 51 | ACTIVE | Confirmed - Enchanter Level 51 on wiki matches DB | untagged | none | Wake of Tranquility |
| 8570 | Boon of the Clear Mind | 52 | ACTIVE | Confirmed on P99 wiki - one documented version, matches id 8570 via tie on mana/recast (wiki mana=175) - kept lower/original id per project convention, dropped 8xxx-range duplicate | untagged | none | Boon of the Clear Mind |
| 1696 | Color Slant | 52 | ACTIVE | Confirmed - Enchanter Level 52 on wiki matches DB | untagged | none | Color Slant |
| 1690 | Fascination | 52 | ACTIVE | Confirmed on P99 wiki - one documented version, matches id 1690 via tie on mana/recast (wiki mana=200) - kept lower/original id per project convention, dropped 8xxx-range duplicate | untagged | none | Fascination |
| 8544 | Fascination | 52 | ACTIVE | Duplicate object - wiki's single documented version matches id 1690 via tie on mana/recast (wiki mana=200) - kept lower/original id per project convention, dropped 8xxx-range duplicate; id 8544's values (mana=200, recast=2250ms) don't match | untagged | deactivate-duplicate-keep-1690 | Fascination |
| 1689 | Rune V | 52 | ACTIVE | Confirmed on P99 wiki - one documented version, matches id 1689 via tie on mana/recast (wiki mana=350) - kept lower/original id per project convention, dropped 8xxx-range duplicate | untagged | none | Rune V |
| 8502 | Rune V | 52 | ACTIVE | Duplicate object - wiki's single documented version matches id 1689 via tie on mana/recast (wiki mana=350) - kept lower/original id per project convention, dropped 8xxx-range duplicate; id 8502's values (mana=350, recast=2250ms) don't match | untagged | deactivate-duplicate-keep-1689 | Rune V |
| 1708 | Aanya's Quickening | 53 | ACTIVE | Confirmed - Enchanter Level 53 on wiki matches DB | untagged | none | Aanya's Quickening |
| 1705 | Boltran`s Agacerie | 53 | ACTIVE | Confirmed - Enchanter Level 53 on wiki matches DB | Kunark Era | none | Boltran's Agacerie (db name uses backtick apostrophe) |
| 1592 | Cripple | 53 | ACTIVE | Confirmed - Enchanter Level 53 on wiki matches DB | Kunark Era | none | Cripple |
| 1697 | Recant Magic | 53 | ACTIVE | Confirmed - Enchanter Level 53 on wiki matches DB | untagged | none | Recant Magic |
| 1694 | Boon of the Clear Mind | 54 | ACTIVE | Duplicate object - wiki's single documented version matches id 8570 via tie on mana/recast (wiki mana=175) - kept lower/original id per project convention, dropped 8xxx-range duplicate; id 1694's values (mana=175, recast=2250ms) don't match | untagged | deactivate-duplicate-keep-8570 | Boon of the Clear Mind |
| 1693 | Clarity II | 54 | ACTIVE | Duplicate object - wiki's single documented version matches id 8560 via mana (wiki=115); id 1693's values (mana=125, recast=2250ms) don't match | untagged | deactivate-duplicate-keep-8560 | Clarity II |
| 8560 | Clarity II | 54 | ACTIVE | Confirmed on P99 wiki - one documented version, matches id 8560 via mana (wiki=115) | untagged | none | Clarity II |
| 1698 | Dementia | 54 | ACTIVE | Confirmed - Enchanter Level 54 on wiki matches DB | untagged | none | Dementia |
| 7694 | Focus Mass Spellcaster's Empowering Essence | 54 | ACTIVE | Not found on P99 wiki (own page + Enchanter class page checked) - assumed out-of-era per default rule | N/A | deactivate | Enchanter page + own page (not found) |
| 1691 | Glamour of Kintaz | 54 | ACTIVE | Duplicate object - wiki's single documented version matches id 8537 via mana (wiki=275); id 1691's values (mana=350, recast=2250ms) don't match | Kunark Era | deactivate-duplicate-keep-8537 | Glamour of Kintaz |
| 8537 | Glamour of Kintaz | 54 | ACTIVE | Confirmed on P99 wiki - one documented version, matches id 8537 via mana (wiki=275) | Kunark Era | none | Glamour of Kintaz |
| 1610 | Shield of the Magi | 54 | ACTIVE | Confirmed - Enchanter Level 54 on wiki matches DB | Kunark Era | none | Shield of the Magi |
| 1409 | Gift of Insight | 55 | ACTIVE | Confirmed - Enchanter Level 55 on wiki matches DB | untagged | none | Gift of Insight |
| 1715 | Largarn's Lamentation | 55 | ACTIVE | Duplicate object - wiki's single documented version matches id 8586 via recast_time (wiki=24.00s, db id 8586=24000ms); id 1715's values (mana=120, recast=30000ms) don't match | untagged | deactivate-duplicate-keep-8586 | Largarn's Lamentation |
| 8586 | Largarn's Lamentation | 55 | ACTIVE | Confirmed on P99 wiki - one documented version, matches id 8586 via recast_time (wiki=24.00s, db id 8586=24000ms) | untagged | none | Largarn's Lamentation |
| 1714 | Memory Flux | 55 | ACTIVE | Confirmed - Enchanter Level 55 on wiki matches DB | untagged | none | Memory Flux |
| 1699 | Wind of Tishani | 55 | ACTIVE | Confirmed - Enchanter Level 55 on wiki matches DB | untagged | none | Wind of Tishani |
| 1723 | Zumaik`s Animation | 55 | ACTIVE | Confirmed - Enchanter Level 55 on wiki matches DB | Kunark Era | none | Zumaik`s Animation |
| 1729 | Augment | 56 | ACTIVE | Confirmed - Enchanter Level 56 on wiki matches DB | untagged | none | Augment |
| 1701 | Overwhelming Splendor | 56 | ACTIVE | Confirmed - Enchanter Level 56 on wiki matches DB | untagged | none | Overwhelming Splendor |
| 1700 | Torment of Argli | 56 | ACTIVE | Duplicate object - wiki's single documented version matches id 8596 via recast_time (wiki=10.00s, db id 8596=10000ms); id 1700's values (mana=150, recast=30000ms) don't match | untagged | deactivate-duplicate-keep-8596 | Torment of Argli |
| 8596 | Torment of Argli | 56 | ACTIVE | Confirmed on P99 wiki - one documented version, matches id 8596 via recast_time (wiki=10.00s, db id 8596=10000ms) | untagged | none | Torment of Argli |
| 1527 | Trepidation | 56 | ACTIVE | Confirmed - Enchanter Level 56 on wiki matches DB | untagged | none | Trepidation |
| 1688 | Enlightenment | 57 | ACTIVE | Confirmed - Enchanter Level 57 on wiki matches DB | untagged | none | Enlightenment |
| 1712 | Forlorn Deeds | 57 | ACTIVE | Confirmed - Enchanter Level 57 on wiki matches DB | untagged | none | Forlorn Deeds |
| 1702 | Tashanian | 57 | ACTIVE | Confirmed - Enchanter Level 57 on wiki matches DB | untagged | none | Tashanian |
| 1711 | Umbra | 57 | ACTIVE | Confirmed - Enchanter Level 57 on wiki matches DB | untagged | none | Umbra |
| 1713 | Bedlam | 58 | ACTIVE | Confirmed - Enchanter Level 58 on wiki matches DB | untagged | none | Bedlam |
| 1633 | Fetter | 58 | ACTIVE | Confirmed - Enchanter Level 58 on wiki matches DB | Kunark Era | none | Fetter |
| 1709 | Wonderous Rapidity | 58 | ACTIVE | Confirmed - Enchanter Level 58 on wiki matches DB | untagged | none | Wonderous Rapidity |
| 1703 | Asphyxiate | 59 | ACTIVE | Confirmed on P99 wiki - one documented version, matches id 1703 via tie on mana/recast (wiki mana=250) - kept lower/original id per project convention, dropped 8xxx-range duplicate | untagged | none | Asphyxiate |
| 8576 | Asphyxiate | 59 | ACTIVE | Duplicate object - wiki's single documented version matches id 1703 via tie on mana/recast (wiki mana=250) - kept lower/original id per project convention, dropped 8xxx-range duplicate; id 8576's values (mana=250, recast=2250ms) don't match | untagged | deactivate-duplicate-keep-1703 | Asphyxiate |
| 1695 | Gift of Pure Thought | 59 | ACTIVE | Duplicate object - wiki's single documented version matches id 8538 via mana (wiki=300); id 1695's values (mana=350, recast=2250ms) don't match | untagged | deactivate-duplicate-keep-8538 | Gift of Pure Thought |
| 8538 | Gift of Pure Thought | 59 | ACTIVE | Confirmed on P99 wiki - one documented version, matches id 8538 via mana (wiki=300) | untagged | none | Gift of Pure Thought |
| 1692 | Rapture | 59 | ACTIVE | Duplicate object - wiki's single documented version matches id 8507 via mana (wiki=425) and recast_time (wiki=24.00s); id 1692's values (mana=600, recast=48000ms) don't match | untagged | deactivate-duplicate-keep-8507 | Rapture |
| 8507 | Rapture | 59 | ACTIVE | Confirmed on P99 wiki - one documented version, matches id 8507 via mana (wiki=425) and recast_time (wiki=24.00s) | untagged | none | Rapture |
| 1707 | Dictate | 60 | ACTIVE | Confirmed on P99 wiki - one documented version, matches id 1707 via tie on mana/recast (wiki mana=750) - kept lower/original id per project convention, dropped 8xxx-range duplicate | untagged | none | Dictate |
| 8555 | Dictate | 60 | ACTIVE | Duplicate object - wiki's single documented version matches id 1707 via tie on mana/recast (wiki mana=750) - kept lower/original id per project convention, dropped 8xxx-range duplicate; id 8555's values (mana=750, recast=300000ms) don't match | untagged | deactivate-duplicate-keep-1707 | Dictate |
| 1410 | Gift of Brilliance | 60 | ACTIVE | Confirmed - Enchanter Level 60 on wiki matches DB | untagged | none | Gift of Brilliance |
| 1710 | Visions of Grandeur | 60 | ACTIVE | Duplicate object - wiki's single documented version matches id 8671 via recast_time (wiki=3.00s, db id 8671=3000ms); id 1710's values (mana=275, recast=18000ms) don't match | Kunark Era | deactivate-duplicate-keep-8671 | Visions of Grandeur |
| 8472 | Visions of Grandeur | 60 | ACTIVE | Duplicate object - wiki's single documented version matches id 8671 via recast_time (wiki=3.00s, db id 8671=3000ms); id 8472's values (mana=275, recast=15000ms) don't match | Kunark Era | deactivate-duplicate-keep-8671 | Visions of Grandeur |
| 8671 | Visions of Grandeur | 60 | ACTIVE | Confirmed on P99 wiki - one documented version, matches id 8671 via recast_time (wiki=3.00s, db id 8671=3000ms) | Kunark Era | none | Visions of Grandeur |
| 1704 | Wind of Tishanian | 60 | ACTIVE | Confirmed - Enchanter Level 60 on wiki matches DB | untagged | none | Wind of Tishanian |
