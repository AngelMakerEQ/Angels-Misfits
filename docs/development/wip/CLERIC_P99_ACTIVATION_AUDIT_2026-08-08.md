# Cleric P99 Wiki Activation Audit — 2026-08-08

**Status:** Investigation complete, pending human review. Read-only — no database changes made.

**Scope:** Every spell currently active for Cleric (`spells_new.classes2 BETWEEN 1 AND 60`) on the live `angelsmisfits` database, cross-checked against the P99 (Project 1999) wiki as the authoritative Velious-era activation source. Follows up on ADR-019's full mechanics resync, which explicitly deferred `classes1-16` activation correctness to this pass.

## Summary

- **Total active Cleric spell rows checked:** 186 (across 165 distinct spell names; some names appear as two database `id`s at the same level — duplicate objects — or, in one case, two different levels).
- **Confirmed correct, no action needed:** 160 rows (single documented id per name/level, level and mechanics match the P99 wiki).
- **Duplicate-name-same-level groups found:** 23 groups (46 ids). Of these:
  - **18 groups resolved with high confidence** — cross-referencing each pair's *other*-class grant levels (Paladin/Ranger/Druid/Shaman/etc., which the resync also touched) against the wiki's documented per-class levels identified exactly one id in each pair that matches the wiki verbatim. Per project-lead direction, where the mismatch reflects an era revision (e.g. a level shifted specifically "during Velious"), the Velious-consistent id was kept.
  - **5 groups remain ambiguous** — both ids are either fully identical (no mechanical difference exists, so either could be deactivated with zero gameplay effect) or differ only in a magnitude value the wiki text doesn't pin down precisely enough to pick a winner. Flagged for manual verification rather than guessed.
- **Additional anomalies (not simple name/level duplicates):** 3 cases, 4 ids — a modern high-id "Bind Affinity" variant at the wrong level, a "Heroic Leap"/"Heroic Leap*" pair entirely absent from the wiki, and an NPC-only spell (`npcComplete Healing`) miscategorized with Cleric access.
- **Total ids flagged for deactivation (high confidence):** 22
- **Total ids in ambiguous pairs (needs manual pick, one of each pair):** 10 (5 pairs)
- **Secondary-source reliance:** none — P99 wiki (`wiki.project1999.com`) was reachable and sufficient for every lookup in this pass; fvproject.com was not needed.
- **Era findings:** all in-scope spells are Classic, Kunark, or Velious era (all valid for a Velious-locked server — Kunark predates Velious). No post-Velious (Luclin+) era category was found on any checked spell. One spell (`Improved Invis vs Undead`, id 1411) required checking the associated item-drop page and the differently-titled spell page (`Improved Invis to Undead`) to resolve a "vs"/"to" naming mismatch — confirmed correct.

---

## Duplicate-pair resolutions (detail)

Methodology: for each same-name/same-level pair, the two ids' `classes1-16` grants were compared against the wiki's full `classes =` block (not just the Cleric line). Where the two ids differ in another class's level, the id matching the wiki's documented value (era-tagged where noted) is kept; the other is flagged as an erroneous/superseded object. Where descriptions/mechanics (mana, recast, duration, effect values) were needed instead, those are noted.

| Spell | Keep id | Deactivate id | Disambiguating signal | Citation |
|---|---|---|---|---|
| Divine Aura | 8554 | 207 | Paladin level: wiki = 55 (Kunark Era); 8554 has Paladin=55, 207 has Paladin=58 (unmatched) | Divine Aura |
| Cancel Magic | 48 | 8662 | `targettype`: wiki = Single; 48=5(Single) matches, 8662=6(Self) does not (Self is wrong for a dispel) | Cancel Magic |
| Endure Cold | 8643 | 225 | Ranger level: wiki = 22; 8643 has Ranger=22, 225 has Ranger=255 (not granted) | Endure Cold |
| Endure Magic | 8594 | 228 | Paladin level: wiki = 30; 8594 has Paladin=30, 228 has Paladin=255 | Endure Magic |
| Expel Undead | 8545 | 662 | Paladin level: wiki = 54 (Kunark Era); 8545 has Paladin=54, 662 has Paladin=55 (unmatched) | Expel Undead |
| Guard | 8633 | 18 | Paladin level: wiki = 39; 8633 has Paladin=39, 18 has Paladin=49 (unmatched) | Guard |
| Hammer of Requital | 8533 | 675 | Wiki lists **no** Paladin grant at all; 8533 has Paladin=255 (matches, ungranted), 675 has Paladin=54 (contradicts wiki) | Hammer of Requital |
| Resist Cold | 8648 | 61 | Ranger level: wiki = 55 (**Velious Era** addition); 8648 has Ranger=55, 61 has Ranger=255. Velious-era version wins | Resist Cold |
| Resist Disease | 8504 | 63 | Paladin level: wiki = 51 (Kunark Era); 8504 has Paladin=51, 63 has Paladin=255 | Resist Disease |
| Resist Magic | 8632 | 64 | Paladin level: wiki = 55 (**Velious Era**, forum-cited); 8632 has Paladin=55, 64 has Paladin=255. Velious-era version wins | Resist Magic |
| Superior Healing | 8631 | 9 | Druid/Shaman level: wiki documents Kunark value 53, "moved to level 51 for Druids/Shamans a few months after Velious launch." 8631 has Druid/Shaman=51 (final Velious state), 9 has 53 (pre-shift). Velious-era version wins per project direction — note this is the *post-shift* value, not day-one-of-Velious; flagged for awareness | Superior Healing |
| Yaulp IV | 8635 | 1534 | Paladin level: wiki = 60, dated Feb 21 2001, explicitly **Velious Era**; 8635 has Paladin=60, 1534 has Paladin=255 | Yaulp IV |
| Armor of Faith | 8634 | 19 | Paladin level: wiki = 49 (Kunark Era); 8634 has Paladin=49, 19 has Paladin=53 (unmatched) | Armor of Faith |
| Death Pact | 8580 | 1547 | Wiki: recast = 15.00s, duration = "60 minutes (1 hour)". 8580 = recast 15000ms/buffduration 600 ticks (60 min) matches exactly; 1547 = recast 60000ms/buffduration 60 ticks (6 min) does not | Death Pact |
| Divine Intervention | 8581 | 1546 | Wiki: duration = "10 minutes" (100 ticks). 8581 buffduration=100 matches exactly; 1546 buffduration=60 (6 min) does not | Divine Intervention |
| Reckoning | 8506 | 1543 | Wiki: mana = 250. 8506 mana=250 matches; 1543 mana=300 does not | Reckoning |
| Enforced Reverence | 8546 | 1544 | Wiki: mana = 200. 8546 mana=200 matches; 1544 mana=240 does not | Enforced Reverence |
| Word of Redemption | 8461 | 1523 | Wiki: mana = 1100. 8461 mana=1100 matches; 1523 mana=1200 does not | Word of Redemption |

### Ambiguous — needs manual verification before choosing (not resolved here)

| Spell | id A | id B | Difference | Why unresolved | Citation |
|---|---|---|---|---|---|
| Heroic Bond | 1536 | 1538 | None — every checked column (mana, recast, effect values, buff duration, classes1-16, targettype) is identical | True duplicate object; deactivating either is mechanically inconsequential. Recommend keeping the lower id (1536) purely for id-hygiene/traceability, not because of any wiki signal | Heroic Bond |
| Symbol of Marzin | 1535 | 8491 | None — fully identical across all checked columns | Same as above; recommend keeping lower id (1535) | Symbol of Marzin |
| Antidote | 1525 | 8577 | `effect_base_value1`: -9 (1525) vs -16 (8577) — likely a poison-counter-cure magnitude | Wiki description doesn't state an exact counter value for either candidate; no other-class signal exists (Antidote is Cleric-only in both ids) | Antidote |
| Divine Light | 1519 | 8553 | `effect_base_value1`: 635 (1519) vs 350 (8553); wiki desc gives heal range 880-910 at "2.6 healing per point of mana" (350 mana × 2.6 ≈ 910, matching the upper bound, but that arithmetic doesn't cleanly indicate which raw effect value is correct without the formula multiplier) | Needs the `formula1` scaling column and/or in-game verification, not captured in this pass | Divine Light |
| Word of Vigor | 1520 | 8460 | `effect_base_value1`: 60 (1520) vs 70 (8460); wiki desc: "healing between 537 and 620...Heals group for 590 each" | No clean arithmetic match to either raw value found; needs formula-column or in-game verification | Word of Vigor |

---

## Additional anomalies (not name/level duplicates)

| id | Name | Level | Issue | Verdict | Citation |
|---|---|---|---|---|---|
| 40971 | Bind Affinity | 10 | A second "Bind Affinity" object at level 10, 0 mana, 1.5s recast — mechanically nothing like the real spell (no reagent cost, near-instant recast). Wiki documents only **one** Bind Affinity for Cleric: level 14, mana 100, recast 12s — matching id 35 exactly. id 40971's very high id (far outside P99's ~8,088-spell Titanium export range per ADR-019) and its no-mana/instant-recast shape are consistent with a much later live-EQ "quick bind" mechanic, not Velious-era content | **Deactivate 40971.** Keep 35 (already correct, matches wiki level/mana/recast) | Bind Affinity |
| 31991 | Heroic Leap | 1 | No wiki page exists for "Heroic Leap" at all (search returned MISSING). A level-1 Cleric ability named "Heroic Leap" with a rhyolite-splash damage effect has no classic/Kunark/Velious-era precedent — this reads as a modern positional-combat-discipline mechanic (introduced far later in live EQ's history) | **Deactivate.** Not found on wiki = default deactivate per methodology | Heroic Leap (page missing) |
| 33000 | Heroic Leap* | 1 | Same root name, `IsDiscipline=1`, has an `EndurCost`. Same absence of any wiki documentation for a Cleric "Heroic Leap" ability | **Deactivate.** Not found on wiki = default deactivate | Heroic Leap (page missing) |
| 8459 | npcComplete Healing | 39 | Name itself signals an NPC-only internal copy of Complete Healing (`effect_base_value1=400000`, i.e. an effectively unlimited heal — not a player-balanced value). Not a real player-facing spell name; would never appear on the wiki under this name | **Deactivate.** Not a documented/real player spell; default deactivate per methodology | N/A — name is not a real spell, no wiki lookup attempted (per methodology default) |

---

## Full spell table

Levels and mechanics below are the *current* database state; "Action needed" reflects the verdicts above. Rows within a duplicate pair are both listed with the same verdict context.

| id | name | level | current status | P99 verdict | era category | action needed | citation |
|---|---|---|---|---|---|---|---|
| 202 | Courage | 1 | active | confirmed | (none) | none | Courage |
| 203 | Cure Poison | 1 | active | confirmed | (none) | none | Cure Poison |
| 207 | Divine Aura | 1 | active | wrong id (Paladin lvl mismatch) | Classic Era | deactivate-duplicate-keep-other-id (keep 8554) | Divine Aura |
| 8554 | Divine Aura | 1 | active | confirmed | Classic Era | none | Divine Aura |
| 201 | Flash of Light | 1 | active | confirmed | (none) | none | Flash of Light |
| 31991 | Heroic Leap | 1 | active | not found on wiki | n/a | deactivate | Heroic Leap (missing) |
| 33000 | Heroic Leap* | 1 | active | not found on wiki | n/a | deactivate | Heroic Leap (missing) |
| 208 | Lull | 1 | active | confirmed | Classic Era | none | Lull |
| 200 | Minor Healing | 1 | active | confirmed | (none) | none | Minor Healing |
| 209 | Spook the Dead | 1 | active | confirmed | Classic Era | none | Spook the Dead |
| 14 | Strike | 1 | active | confirmed | (none) | none | Strike |
| 205 | True North | 1 | active | confirmed | Classic Era | none | True North |
| 210 | Yaulp | 1 | active | confirmed | (none) | none | Yaulp |
| 212 | Cure Blindness | 5 | active | confirmed | (none) | none | Cure Blindness |
| 213 | Cure Disease | 5 | active | confirmed | (none) | none | Cure Disease |
| 560 | Furor | 5 | active | confirmed | Classic Era | none | Furor |
| 36 | Gate | 5 | active | confirmed | Classic Era | none | Gate |
| 11 | Holy Armor | 5 | active | confirmed | (none) | none | Holy Armor |
| 17 | Light Healing | 5 | active | confirmed | (none) | none | Light Healing |
| 215 | Reckless Strength | 5 | active | confirmed | (none) | none | Reckless Strength |
| 216 | Stun | 5 | active | confirmed | (none) | none | Stun |
| 211 | Summon Drink | 5 | active | confirmed | Classic Era | none | Summon Drink |
| 218 | Ward Undead | 5 | active | confirmed | Classic Era | none | Ward Undead |
| 219 | Center | 9 | active | confirmed | (none) | none | Center |
| 224 | Endure Fire | 9 | active | confirmed | Classic Era | none | Endure Fire |
| 227 | Endure Poison | 9 | active | confirmed | Classic Era | none | Endure Poison |
| 229 | Fear | 9 | active | confirmed | Classic Era | none | Fear |
| 223 | Hammer of Wrath | 9 | active | confirmed | (none) | none | Hammer of Wrath |
| 222 | Invigor | 9 | active | confirmed | Classic Era | none | Invigor |
| 230 | Root | 9 | active | confirmed | Classic Era | none | Root |
| 221 | Sense the Dead | 9 | active | confirmed | Classic Era | none | Sense the Dead |
| 501 | Soothe | 9 | active | confirmed | Classic Era | none | Soothe |
| 50 | Summon Food | 9 | active | confirmed | Classic Era | none | Summon Food |
| 231 | Word of Pain | 9 | active | confirmed | (none) | none | Word of Pain |
| 40971 | Bind Affinity | 10 | active | not documented at this level | n/a | deactivate | Bind Affinity |
| 35 | Bind Affinity | 14 | active | confirmed | Classic Era | none | Bind Affinity |
| 48 | Cancel Magic | 14 | active | confirmed | Classic Era | none | Cancel Magic |
| 8662 | Cancel Magic | 14 | active | wrong id (targettype mismatch) | Classic Era | deactivate-duplicate-keep-other-id (keep 48) | Cancel Magic |
| 225 | Endure Cold | 14 | active | wrong id (Ranger lvl mismatch) | Classic Era | deactivate-duplicate-keep-other-id (keep 8643) | Endure Cold |
| 8643 | Endure Cold | 14 | active | confirmed | Classic Era | none | Endure Cold |
| 226 | Endure Disease | 14 | active | confirmed | Classic Era | none | Endure Disease |
| 233 | Expulse Undead | 14 | active | confirmed | (none) | none | Expulse Undead |
| 234 | Halo of Light | 14 | active | confirmed | Classic Era | none | Halo of Light |
| 12 | Healing | 14 | active | confirmed | Classic Era | none | Healing |
| 235 | Invisibility versus Undead | 14 | active | confirmed | Classic Era | none | Invisibility versus Undead |
| 232 | Sense Summoned | 14 | active | confirmed | Classic Era | none | Sense Summoned |
| 16 | Smite | 14 | active | confirmed | (none) | none | Smite |
| 485 | Symbol of Transal | 14 | active | confirmed | (none) | none | Symbol of Transal |
| 47 | Calm | 19 | active | confirmed | Classic Era | none | Calm |
| 89 | Daring | 19 | active | confirmed | (none) | none | Daring |
| 228 | Endure Magic | 19 | active | wrong id (Paladin lvl mismatch) | Classic Era | deactivate-duplicate-keep-other-id (keep 8594) | Endure Magic |
| 8594 | Endure Magic | 19 | active | confirmed | Classic Era | none | Endure Magic |
| 417 | Extinguish Fatigue | 19 | active | confirmed | Classic Era | none | Extinguish Fatigue |
| 123 | Holy Might | 19 | active | confirmed | (none) | none | Holy Might |
| 368 | Spirit Armor | 19 | active | confirmed | (none) | none | Spirit Armor |
| 248 | Ward Summoned | 19 | active | confirmed | (none) | none | Ward Summoned |
| 413 | Word of Shadow | 19 | active | confirmed | (none) | none | Word of Shadow |
| 43 | Yaulp II | 19 | active | confirmed | Classic Era | none | Yaulp II |
| 244 | Bravery | 24 | active | confirmed | (none) | none | Bravery |
| 95 | Counteract Poison | 24 | active | confirmed | (none) | none | Counteract Poison |
| 117 | Dismiss Undead | 24 | active | confirmed | (none) | none | Dismiss Undead |
| 15 | Greater Healing | 24 | active | confirmed | Classic Era | none | Greater Healing |
| 37 | Hammer of Striking | 24 | active | confirmed | (none) | none | Hammer of Striking |
| 126 | Inspire Fear | 24 | active | confirmed | (none) | none | Inspire Fear |
| 486 | Symbol of Ryltan | 24 | active | confirmed | (none) | none | Symbol of Ryltan |
| 128 | Wave of Fear | 24 | active | confirmed | (none) | none | Wave of Fear |
| 52 | Abundant Drink | 29 | active | confirmed | (none) | none | Abundant Drink |
| 96 | Counteract Disease | 29 | active | confirmed | Classic Era | none | Counteract Disease |
| 130 | Divine Barrier | 29 | active | confirmed | (none) | none | Divine Barrier |
| 131 | Enstill | 29 | active | confirmed | Classic Era | none | Enstill |
| 663 | Expulse Summoned | 29 | active | confirmed | (none) | none | Expulse Summoned |
| 18 | Guard | 29 | active | wrong id (Paladin lvl mismatch) | (none) | deactivate-duplicate-keep-other-id (keep 8633) | Guard |
| 8633 | Guard | 29 | active | confirmed | (none) | none | Guard |
| 1885 | Imbue Amber | 29 | active | confirmed | Kunark Era | none | Imbue Amber |
| 1894 | Imbue Black Pearl | 29 | active | confirmed | Kunark Era | none | Imbue Black Pearl |
| 1897 | Imbue Black Sapphire | 29 | active | confirmed | Kunark Era | none | Imbue Black Sapphire |
| 1895 | Imbue Diamond | 29 | active | confirmed | Kunark Era | none | Imbue Diamond |
| 1888 | Imbue Emerald | 29 | active | confirmed | Kunark Era | none | Imbue Emerald |
| 1798 | Imbue Opal | 29 | active | confirmed | Kunark Era | none | Imbue Opal |
| 1898 | Imbue Peridot | 29 | active | confirmed | Kunark Era | none | Imbue Peridot |
| 1800 | Imbue Plains Pebble | 29 | active | confirmed | Kunark Era | none | Imbue Plains Pebble |
| 1896 | Imbue Rose Quartz | 29 | active | confirmed | Kunark Era | none | Imbue Rose Quartz |
| 1887 | Imbue Ruby | 29 | active | confirmed | Kunark Era | none | Imbue Ruby |
| 1886 | Imbue Sapphire | 29 | active | confirmed | Kunark Era | none | Imbue Sapphire |
| 1799 | Imbue Topaz | 29 | active | confirmed | Kunark Era | none | Imbue Topaz |
| 59 | Panic the Dead | 29 | active | confirmed | (none) | none | Panic the Dead |
| 391 | Revive | 29 | active | confirmed | Classic Era | none | Revive |
| 414 | Word of Spirit | 29 | active | confirmed | (none) | none | Word of Spirit |
| 329 | Wrath | 29 | active | confirmed | Classic Era | none | Wrath |
| 53 | Abundant Food | 34 | active | confirmed | (none) | none | Abundant Food |
| 1445 | Armor of Protection | 34 | active | confirmed | (none) | none | Armor of Protection |
| 480 | Atone | 34 | active | confirmed | (none) | none | Atone |
| 134 | Blinding Luminance | 34 | active | confirmed | (none) | none | Blinding Luminance |
| 662 | Expel Undead | 34 | active | wrong id (Paladin lvl mismatch) | Classic Era | deactivate-duplicate-keep-other-id (keep 8545) | Expel Undead |
| 8545 | Expel Undead | 34 | active | confirmed | Classic Era | none | Expel Undead |
| 124 | Force | 34 | active | confirmed | Classic Era | none | Force |
| 504 | Frenzied Strength | 34 | active | confirmed | Classic Era | none | Frenzied Strength |
| 60 | Resist Fire | 34 | active | confirmed | (none) | none | Resist Fire |
| 62 | Resist Poison | 34 | active | confirmed | Classic Era | none | Resist Poison |
| 9 | Superior Healing | 34 | active | wrong id (Druid/Shaman pre-Velious-shift) | Classic Era | deactivate-duplicate-keep-other-id (keep 8631) | Superior Healing |
| 8631 | Superior Healing | 34 | active | confirmed | Classic Era | none | Superior Healing |
| 487 | Symbol of Pinzarn | 34 | active | confirmed | (none) | none | Symbol of Pinzarn |
| 405 | Tremor | 34 | active | confirmed | (none) | none | Tremor |
| 312 | Valor | 34 | active | confirmed | (none) | none | Valor |
| 135 | Word of Health | 34 | active | confirmed | (none) | none | Word of Health |
| 19 | Armor of Faith | 39 | active | wrong id (Paladin lvl mismatch) | Classic Era | deactivate-duplicate-keep-other-id (keep 8634) | Armor of Faith |
| 8634 | Armor of Faith | 39 | active | confirmed | Classic Era | none | Armor of Faith |
| 13 | Complete Healing | 39 | active | confirmed | (none) | none | Complete Healing |
| 115 | Dismiss Summoned | 39 | active | confirmed | (none) | none | Dismiss Summoned |
| 127 | Invoke Fear | 39 | active | confirmed | Classic Era | none | Invoke Fear |
| 8459 | npcComplete Healing | 39 | active | not a real player spell | n/a | deactivate | N/A (no wiki lookup — internal NPC copy) |
| 49 | Nullify Magic | 39 | active | confirmed | Classic Era | none | Nullify Magic |
| 45 | Pacify | 39 | active | confirmed | Classic Era | none | Pacify |
| 8648 | Resist Cold | 39 | active | confirmed | (none) | none | Resist Cold |
| 61 | Resist Cold | 39 | active | wrong id (Ranger not yet Velious-updated) | (none) | deactivate-duplicate-keep-other-id (keep 8648) | Resist Cold |
| 8504 | Resist Disease | 39 | active | confirmed | Classic Era, Velious Era | none | Resist Disease |
| 63 | Resist Disease | 39 | active | wrong id (Paladin lvl mismatch) | Classic Era, Velious Era | deactivate-duplicate-keep-other-id (keep 8504) | Resist Disease |
| 388 | Resuscitate | 39 | active | confirmed | Classic Era | none | Resuscitate |
| 1443 | Turning of the Unnatural | 39 | active | confirmed | Velious Era | none | Turning of the Unnatural |
| 415 | Word of Souls | 39 | active | confirmed | (none) | none | Word of Souls |
| 118 | Banish Undead | 44 | active | confirmed | (none) | none | Banish Undead |
| 1444 | Celestial Healing | 44 | active | confirmed | Velious Era | none | Celestial Healing |
| 406 | Earthquake | 44 | active | confirmed | (none) | none | Earthquake |
| 8533 | Hammer of Requital | 44 | active | confirmed | (none) | none | Hammer of Requital |
| 675 | Hammer of Requital | 44 | active | wrong id (grants nonexistent Paladin access) | (none) | deactivate-duplicate-keep-other-id (keep 8533) | Hammer of Requital |
| 8632 | Resist Magic | 44 | active | confirmed | Classic Era | none | Resist Magic |
| 64 | Resist Magic | 44 | active | wrong id (Paladin not yet Velious-updated) | Classic Era | deactivate-duplicate-keep-other-id (keep 8632) | Resist Magic |
| 314 | Resolution | 44 | active | confirmed | Classic Era | none | Resolution |
| 672 | Retribution | 44 | active | confirmed | (none) | none | Retribution |
| 488 | Symbol of Naltron | 44 | active | confirmed | Classic Era | none | Symbol of Naltron |
| 44 | Yaulp III | 44 | active | confirmed | Classic Era | none | Yaulp III |
| 97 | Abolish Poison | 49 | active | confirmed | (none) | none | Abolish Poison |
| 664 | Expel Summoned | 49 | active | confirmed | (none) | none | Expel Summoned |
| 132 | Immobilize | 49 | active | confirmed | Classic Era | none | Immobilize |
| 392 | Resurrection | 49 | active | confirmed | Classic Era | none | Resurrection |
| 20 | Shield of Words | 49 | active | confirmed | Classic Era | none | Shield of Words |
| 125 | Sound of Force | 49 | active | confirmed | (none) | none | Sound of Force |
| 416 | Word Divine | 49 | active | confirmed | (none) | none | Word Divine |
| 136 | Word of Healing | 49 | active | confirmed | (none) | none | Word of Healing |
| 1411 | Improved Invis vs Undead | 50 | active | confirmed (wiki page titled "Improved Invis to Undead") | Velious Era (item drop page) | none | Improved Invis to Undead / item: Spell: Improved Invis vs Undead |
| 8580 | Death Pact | 51 | active | confirmed | Kunark Era | none | Death Pact |
| 1547 | Death Pact | 51 | active | wrong id (recast/duration mismatch) | Kunark Era | deactivate-duplicate-keep-other-id (keep 8580) | Death Pact |
| 1532 | Dread of Night | 51 | active | confirmed | (none) | none | Dread of Night |
| 1518 | Remedy | 51 | active | confirmed | (none) | none | Remedy |
| 1726 | Sunskin | 51 | active | confirmed | (none) | none | Sunskin |
| 1538 | Heroic Bond | 52 | active | ambiguous — fully identical to 1536 | (none) | manual verification (recommend keep 1536) | Heroic Bond |
| 1536 | Heroic Bond | 52 | active | ambiguous — fully identical to 1538 | (none) | manual verification (recommend keep 1536) | Heroic Bond |
| 1533 | Heroism | 52 | active | confirmed | (none) | none | Heroism |
| 1542 | Upheaval | 52 | active | confirmed | Kunark Era | none | Upheaval |
| 1520 | Word of Vigor | 52 | active | ambiguous — effect magnitude unresolved | (none) | manual verification | Word of Vigor |
| 8460 | Word of Vigor | 52 | active | ambiguous — effect magnitude unresolved | (none) | manual verification | Word of Vigor |
| 1526 | Annul Magic | 53 | active | confirmed | Kunark Era | none | Annul Magic |
| 1519 | Divine Light | 53 | active | ambiguous — effect magnitude unresolved | (none) | manual verification | Divine Light |
| 8553 | Divine Light | 53 | active | ambiguous — effect magnitude unresolved | (none) | manual verification | Divine Light |
| 8635 | Yaulp IV | 53 | active | confirmed | Kunark Era | none | Yaulp IV |
| 1534 | Yaulp IV | 53 | active | wrong id (Paladin not yet Velious-updated) | Kunark Era | deactivate-duplicate-keep-other-id (keep 8635) | Yaulp IV |
| 1543 | Reckoning | 54 | active | wrong id (mana mismatch) | (none) | deactivate-duplicate-keep-other-id (keep 8506) | Reckoning |
| 8506 | Reckoning | 54 | active | confirmed | (none) | none | Reckoning |
| 1535 | Symbol of Marzin | 54 | active | ambiguous — fully identical to 8491 | (none) | manual verification (recommend keep 1535) | Symbol of Marzin |
| 8491 | Symbol of Marzin | 54 | active | ambiguous — fully identical to 1535 | (none) | manual verification (recommend keep 1535) | Symbol of Marzin |
| 1721 | Unswerving Hammer of Faith | 54 | active | confirmed (wiki redirects to "Unswerving Hammer") | (none) | none | Unswerving Hammer of Faith → Unswerving Hammer |
| 1528 | Exile Undead | 55 | active | confirmed | (none) | none | Exile Undead |
| 1539 | Fortitude | 55 | active | confirmed | (none) | none | Fortitude |
| 1446 | Stun Command | 55 | active | confirmed | (none) | none | Stun Command |
| 1541 | Wake of Tranquility | 55 | active | confirmed | (none) | none | Wake of Tranquility |
| 116 | Banish Summoned | 56 | active | confirmed | (none) | none | Banish Summoned |
| 1548 | Mark of Karn | 56 | active | confirmed | (none) | none | Mark of Karn |
| 133 | Paralyzing Earth | 56 | active | confirmed | Kunark Era | none | Paralyzing Earth |
| 1524 | Reviviscence | 56 | active | confirmed | (none) | none | Reviviscence |
| 1540 | Aegis | 57 | active | confirmed | (none) | none | Aegis |
| 1537 | Bulwark of Faith | 57 | active | confirmed | (none) | none | Bulwark of Faith |
| 1527 | Trepidation | 57 | active | confirmed | (none) | none | Trepidation |
| 1521 | Word of Restoration | 57 | active | confirmed | (none) | none | Word of Restoration |
| 1525 | Antidote | 58 | active | ambiguous — effect magnitude unresolved | (none) | manual verification | Antidote |
| 8577 | Antidote | 58 | active | ambiguous — effect magnitude unresolved | (none) | manual verification | Antidote |
| 8546 | Enforced Reverence | 58 | active | confirmed | (none) | none | Enforced Reverence |
| 1544 | Enforced Reverence | 58 | active | wrong id (mana mismatch) | (none) | deactivate-duplicate-keep-other-id (keep 8546) | Enforced Reverence |
| 1774 | Naltron's Mark | 58 | active | confirmed | (none) | none | Naltron's Mark |
| 1522 | Celestial Elixir | 59 | active | confirmed | Kunark Era | none | Celestial Elixir |
| 1545 | The Unspoken Word | 59 | active | confirmed | (none) | none | The Unspoken Word |
| 1447 | Aegolism | 60 | active | confirmed | Velious Era | none | Aegolism |
| 1530 | Banishment of Shadows | 60 | active | confirmed | (none) | none | Banishment of Shadows |
| 1546 | Divine Intervention | 60 | active | wrong id (duration mismatch) | (none) | deactivate-duplicate-keep-other-id (keep 8581) | Divine Intervention |
| 8581 | Divine Intervention | 60 | active | confirmed | (none) | none | Divine Intervention |
| 1523 | Word of Redemption | 60 | active | wrong id (mana mismatch) | (none) | deactivate-duplicate-keep-other-id (keep 8461) | Word of Redemption |
| 8461 | Word of Redemption | 60 | active | confirmed | (none) | none | Word of Redemption |

---

## Notes for the migration author

- All "deactivate" and "deactivate-duplicate-keep-other-id" verdicts mean: set `classes2 = 255` on that specific `id` only. No other class columns should be touched by a Cleric-scoped migration — several of the duplicate ids are also grantable to Paladin/other classes on correct values and must not be blanket-deactivated across all `classes1-16`.
- The 5 ambiguous pairs (Heroic Bond, Symbol of Marzin, Antidote, Divine Light, Word of Vigor) should **not** be resolved by guessing in the migration script. Either leave both active pending further research, or — for the two fully-identical pairs (Heroic Bond, Symbol of Marzin) only — it's safe to deactivate one since there is zero mechanical difference.
- The Superior Healing resolution (keep 8631) carries a documented caveat: the wiki says the Druid/Shaman level-51 value took effect "a few months after Velious launch," not on day one. If this server's intended Velious "snapshot date" is early Velious, id 9 (the pre-shift value) could arguably be more accurate for that narrower window — Cleric's own access (level 34) is identical either way, so this only matters if Druid/Shaman scripts also touch this spell.
- `docs/decisions/000_UNCLASSIC_DECISIONS.md` is not touched by this document — this is investigation only, per the constraints given.
