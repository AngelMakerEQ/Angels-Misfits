# Necromancer P99-Activation Audit (2026-08-08)

**Status:** Investigation complete, pending human review. Read-only — no database
changes have been made. This document is input for a migration script to be
written separately after review.

**Scope:** Every spell currently active for Necromancer on the live database
(`spells_new.classes11 BETWEEN 1 AND 60`), checked against the P99
(Project 1999) wiki — this project's authoritative era-accuracy source — to
confirm actual Velious-era availability. This follows up ADR-019 (P99 Spell
Mechanics Resync), which explicitly deferred this wiki-based activation check.

## Summary

- **200** active Necromancer spell rows checked, covering **171** distinct
  spell names.
- **170** rows confirmed correct as-is (144 non-duplicate names matched the
  wiki exactly on level, plus 26 duplicate-group "keep" ids resolved below).
- **1** spell (**Corpal Empathy**, id 1413, level 44) not found on the P99
  wiki or on fvproject.com under any spelling searched — flagged for
  deactivation per the project-lead default (undocumented content is assumed
  out-of-era, not given benefit of the doubt).
- **27 duplicate-name/level pairs (56 ids total)** were found and resolved:
  in every one of the 27 cases, the P99 wiki documents exactly **one**
  version of the spell (not two genuine era-versions), so all 27 are
  **erroneous duplicate objects**, not "Kunark vs Velious" splits. **29 ids**
  across these 27 groups are recommended for deactivation, keeping one
  canonical id per group:
  - **20 groups** resolved with solid, cited mechanical evidence (class/level
    grant vectors, mana cost, buff-duration-formula math, or damage-total
    math that uniquely matches the wiki's documented values on one id only).
  - **7 groups** (Breath of the Dead, Invoke Shadow, Manaskin, Pyrocruor,
    Conjure Corpse, Shieldskin's remaining pair, Quivering Veil of Xarn's
    remaining pair) have two candidate ids that are **mechanically
    identical in every field checked** (classes vector, mana, recast,
    buff duration/formula, target type, resist type, spell category, and
    all four flavor-text messages). No evidence distinguishes them. A
    keep/deactivate pick is offered as a low-confidence default only —
    **flagged explicitly for human judgment.**
- **No post-Velious content found.** Every era category seen across all 171
  pages (`Classic Era`, `Kunark Era`, `Velious Era`, `Chardok Revamp Era`,
  `Paineel Era`) is confirmed pre-Luclin — `Category:Chardok Revamp Era`'s own
  wiki description states it covers "one final major patch before the
  release of Shadows of Luclin," and `Category:Timeline`'s full subcategory
  list contains no Luclin/PoP/later category at all. So none of the era tags
  encountered triggered an out-of-era flag by themselves.
- **Net recommended deactivations: 30** (1 missing + 29 duplicate-losers),
  reducing the active Necromancer spell count from 200 rows/171 names to
  170 rows/170 names.

## Methodology notes

- Fetched via MediaWiki API (`action=query&prop=revisions|categories`)
  against `wiki.project1999.com`, batched ~20 titles per request via a
  scratch Python script (not committed) rather than one request per spell.
  All 171 names resolved in a single pass with zero batch errors.
- Two titles needed secondary resolution beyond a direct title match:
  - **"Improved Invis vs Undead"** — the direct title match is an *item*
    (spell scroll) page, not the spell page; the actual spell page is
    titled **"Improved Invis to Undead"** (Necromancer Level 50, mana 75 —
    matches DB exactly). The item page is independently tagged
    `Category:Velious Era` and lists Velious-only drop zones (Cobalt Scar,
    Great Divide, Icewell Keep, Siren's Grotto, Velketor's Labyrinth),
    corroborating in-era placement.
  - **"Sacrifice"** — direct title is a disambiguation page; resolved to
    **"Sacrifice (spell)"** (Necromancer Level 51, mana 100, `Kunark Era`
    — matches DB).
- **Corpal Empathy** (id 1413) — searched both `wiki.project1999.com` (direct
  title fetch + `list=search`) and `fvproject.com` (secondary source per
  methodology step 4) under the exact name and the plausible alternate
  "Corporal Empathy"; zero results on both sites. Per the explicit
  project-lead default, treated as not-documented → deactivate.
- **Duplicate resolution used a wider evidence set than name+level alone**,
  per the coordinator's added instruction: for every duplicate pair, full
  `classes1-16` grant vectors, `mana`, `recast_time`, `buffdurationformula`/
  `buffduration`, `targettype`, `resisttype`, `spell_category`, and the four
  flavor-text columns (`you_cast`, `cast_on_you`, `cast_on_other`,
  `spell_fades`) were pulled from the live DB and cross-checked against the
  wiki page's full `classes = ` block, `duration = ` field, and description
  text (including reverse-engineering two cases via `CalcBuffDuration_formula`
  in `zone/spells.cpp` and via total-damage arithmetic stated in the wiki
  description). See the per-group notes below for exactly which signal
  resolved each case.
- Checked whether DB `field215` (the P99-curator era-annotation column noted
  in ADR-019) could serve as a duplicate tie-breaker: it does not. Only 9 of
  the 200 active rows carry a non-blank `field215` value (always literal
  `1`, never the `!Expansion:X` text ADR-019 described), and that `1` shows
  up on plainly-legitimate singular spells (Plague, Scourge, Trucidation,
  Enslave Death, Banishment of Shadows, Gangrenous Touch of Zum\`uul) just as
  often as on duplicate-losers (Bind Affinity id 40971, Convergence id
  32397). Not used as evidence for any call below.
- No secondary-source (fvproject.com) fallback was needed for any spell
  except the Corpal Empathy check above — the primary P99 wiki answered
  every other lookup.

---

## Duplicate-group resolutions (27 groups, 56 ids)

| Name | Level | Keep id | Deactivate id(s) | Evidence |
|---|---|---|---|---|
| Endure Cold | 4 | 8643 | 225 | Wiki class list includes Ranger‑22; only id 8643 grants Ranger (`classes4=22`), id 225 has `classes4=255` (no Ranger grant at all). |
| Grim Aura | 4 | 8639 | 346 | Wiki lists Shadow Knight‑22; only id 8639 grants SK (`classes5=22`), id 346 has `classes5=255`. |
| Bind Affinity | 12 | 35 | 40971 | Wiki's full cross-class list (Cleric‑14, Druid‑14, Shaman‑14, Wiz‑12, Mag‑12, Ench‑12) matches id 35's vector exactly. Id 40971's vector doesn't match on Cleric(10)/Druid(12)/Enchanter(14), and it has blank mana + a 1.5s recast (anomalous vs. the documented 100 mana/12s recast) — not a player-facing object. |
| Banshee Aura | 16 | 8572 | 364 | Wiki states duration scales "up to 9 mins @L35." `buffdurationformula=9` on both ids, but only id 8572's `buffduration` cap (90 ticks = 9 min) reaches that; id 364's cap (30 ticks = 3 min) would truncate well short of the documented maximum. |
| Cancel Magic | 16 | 48 | 8662 | Both ids have an identical class/level vector matching the wiki exactly. They differ only in `targettype`: id 48 = 5 (`ST_Target`, single-target, per EQEmu `common/spdat.h`), matching the wiki's single-target "affecting your target" description; id 8662 = 6 (`ST_AECaster`, AE-around-caster) — an undocumented AE dispel variant. |
| Shieldskin | 16 | 8640 *(tie, see below)* | 236; **8657 tie-break, low confidence** | Wiki lists Shadow Knight‑34. Id 236 has `classes5=39` (mismatch → deactivate). Ids 8640 and 8657 both have `classes5=34` (match) and are otherwise byte-identical (mana, recast, duration/formula, target/resist type, category, all flavor text). No evidence distinguishes 8640 from 8657 — recommending 8640 kept / 8657 deactivated is an arbitrary low-confidence default, **flagged for human pick.** |
| Breath of the Dead | 24 | **8660 (low confidence)** | **478 (low confidence)** | Wiki lists Shadow Knight‑49; both ids have `classes5=49` and are identical on every other checked field (mana, recast, duration/formula 3/270, category 94, target type 6, all flavor text). True tie — no distinguishing evidence found. Default follows the pattern from resolved cases (the "8xxx" id was correct in every case with real evidence), **not itself independently evidenced here — flagged for human confirmation.** |
| Resist Cold | 24 | 8648 | 61 | Wiki explicitly tags the Ranger‑55 class grant `{{Velious Era Inline}}` — a wiki-documented Velious-specific addition. Only id 8648 has `classes4=55`; id 61 has `classes4=255` (no Ranger grant). |
| Spirit Tap | 29 | 8636 | 524 | Wiki lists Shadow Knight‑55. Id 8636 has `classes5=55` (match); id 524 has `classes5=56` (mismatch). |
| Invoke Shadow | 34 | **8659 (low confidence)** | **494 (low confidence)** | Wiki lists Necromancer‑34 only; both ids match and are identical on every other checked field (mana 340, recast 2250, resisttype 4, target type 6, category 51, all flavor text). True tie, same low-confidence pattern-based default as above — **flagged for human confirmation.** |
| Resist Disease | 34 | 8504 | 63 | Wiki tags the Paladin‑51 grant `{{Kunark Era Inline}}`. Only id 8504 has `classes3=51`; id 63 has `classes3=255`. |
| Augment Death | 39 | 8575 | 661 | Wiki states mana cost 200. Id 8575 = 200 mana (match); id 661 = 100 mana (mismatch). |
| Drain Spirit | 39 | 8637 | 525 | Wiki lists Shadow Knight‑57. Id 8637 has `classes5=57` (match); id 525 has `classes5=60` (mismatch). |
| Expel Undead | 39 | 8545 | 662 | Wiki lists Paladin‑54 (tagged `{{Kunark Era Inline}}`). Id 8545 has `classes3=54` (exact match); id 662 has `classes3=55` (off by one, mismatch). |
| Summon Corpse | 39 | 8478 | 3 | Wiki lists Shadow Knight‑51. Id 8478 has `classes5=51` (match); id 3 has `classes5=255` (no SK grant at all). |
| Diamondskin | 44 | 8641 | 394 | Wiki lists Shadowknight‑59. Id 8641 has `classes5=59` (match); id 394 has `classes5=255` (no SK grant). |
| Drain Soul | 49 | 8638 | 447 | Wiki lists Shadowknight‑60. Id 8638 has `classes5=60` (match); id 447 has `classes5=255` (no SK grant). |
| Splurt | 51 | 8653 | 1620 | Wiki states mana cost 237. Id 8653 = 237 mana (match); id 1620 = 240 mana (mismatch). |
| Manaskin | 52 | **8521 (low confidence)** | **1609 (low confidence)** | Wiki lists Necromancer‑52 and Wizard‑52 only; both ids match and are identical on every other checked field (mana 330, duration 1200/formula 3, category 83, target type 6, all flavor text). True tie — **flagged for human confirmation.** |
| Convergence | 53 | 1733 | 32397 | Wiki states mana cost 700. Id 1733 = 700 mana (match); id 32397 has blank/0 mana — clearly a broken or vestigial object. |
| Skin of the Shadow | 55 | 8496 | 1625 | Wiki states duration "17.5 minutes @L55 to 20.5 minutes @L65." `buffdurationformula=10` on both ids uses `3×level+10` ticks (verified against `CalcBuffDuration_formula`, `zone/spells.cpp`), giving 175 ticks (17.5 min) @L55 and 205 ticks (20.5 min) @L65 — matching the wiki exactly, *if uncapped*. Id 8496's cap (`buffduration=360` ticks = 36 min) never truncates that range; id 1625's cap (`buffduration=200` ticks = 20 min) would truncate the L65 value to 20 min, contradicting the wiki's stated 20.5 min. |
| Conjure Corpse | 57 | **8661 (low confidence)** | **1773 (low confidence)** | Wiki lists Necromancer‑57 only; both ids identical on every checked field (mana 700, recast 12000, category 52, target type 6, no flavor text on either). True tie — **flagged for human confirmation.** |
| Vexing Mordinia | 57 | 8473 | 1616 | Wiki states mana cost 495. Id 8473 = 495 mana (match); id 1616 = 450 mana (mismatch). |
| Pyrocruor | 58 | **8509 (low confidence)** | **1617 (low confidence)** | Wiki lists Necromancer‑58 only; both ids identical on every checked field (mana 400, resisttype 2, duration 18/formula 1, category 129, target type 5, all flavor text). True tie — **flagged for human confirmation.** |
| Quivering Veil of Xarn | 58 | 8508 *(tie, see below)* | 1612; **8673 tie-break, low confidence** | Wiki states duration "18 secs (3 ticks)." Id 1612's duration cap = 4 ticks (mismatch → deactivate). Ids 8508 and 8673 both have duration = 3 ticks (match) and are otherwise identical (mana 135, recast 600000, category 54, target type 6, all flavor text). No evidence distinguishes 8508 from 8673 — recommending 8508 kept / 8673 deactivated is an arbitrary low-confidence default, **flagged for human pick.** |
| Devouring Darkness | 59 | 8556 | 1619 | Wiki states total damage "1391 damage" from 107 dmg/tick. 107 × 13 ticks = 1391 (exact match) — id 8556 has `buffduration=13`. Id 1619 has `buffduration=15` → 107×15=1605, contradicting the wiki total. |
| Touch of Night | 59 | 8479 | 1618 | Wiki states mana 405 and "1.77 lifetap efficiency" for 720 hp drained. 720/405 = 1.778 (matches "1.77" almost exactly) — id 8479 = 405 mana. Id 1618 = 495 mana; 720/495 = 1.454, contradicting the wiki's stated ratio. |

**7 low-confidence "true tie" groups needing a human pick** (no mechanical,
textual, or class-vector evidence distinguishes the two candidate ids in any
of these): **Shieldskin** (8640 vs 8657, after 236 is deactivated on solid
evidence), **Breath of the Dead** (478 vs 8660), **Invoke Shadow** (494 vs
8659), **Manaskin** (1609 vs 8521), **Conjure Corpse** (1773 vs 8661),
**Pyrocruor** (1617 vs 8509), and **Quivering Veil of Xarn** (8508 vs 8673,
after 1612 is deactivated on solid evidence). The "keep the higher/8xxx id"
default shown in the table above is offered only because every one of the 20
*evidenced* duplicate resolutions above happened to land on the higher id —
a pattern, not independent proof for these 7 — a human should confirm before
this becomes a migration.

---

## Non-duplicate spells (144 names, 1 flagged)

All other 144 distinct spell names (each with a single active id) were
checked individually. 143 confirmed exactly as documented (name, level, and
era all consistent with the wiki); 1 (Corpal Empathy) could not be found on
either wiki checked.

| id | name | level | current status | P99 verdict | era category | action needed | citation (wiki page checked) |
|---|---|---|---|---|---|---|---|
| 338 | Cavorting Bones | 1 | Active | Confirmed active, level matches | Classic Era | none | Cavorting Bones |
| 339 | Coldlight | 1 | Active | Confirmed active, level matches | Classic Era | none | Coldlight |
| 340 | Disease Cloud | 1 | Active | Confirmed active, level matches | Classic Era | none | Disease Cloud |
| 235 | Invisibility versus Undead | 1 | Active | Confirmed active, level matches | Classic Era | none | Invisibility versus Undead |
| 341 | Lifetap | 1 | Active | Confirmed active, level matches | Classic Era | none | Lifetap |
| 342 | Locate Corpse | 1 | Active | Confirmed active, level matches | Classic Era | none | Locate Corpse |
| 288 | Minor Shielding | 1 | Active | Confirmed active, level matches | Classic Era | none | Minor Shielding |
| 331 | Reclaim Energy | 1 | Active | Confirmed active, level matches | Classic Era | none | Reclaim Energy |
| 221 | Sense the Dead | 1 | Active | Confirmed active, level matches | Classic Era | none | Sense the Dead |
| 343 | Siphon Strength | 1 | Active | Confirmed active, level matches | Classic Era | none | Siphon Strength |
| 344 | Clinging Darkness | 4 | Active | Confirmed active, level matches | Classic Era | none | Clinging Darkness |
| 229 | Fear | 4 | Active | Confirmed active, level matches | Classic Era | none | Fear |
| 36 | Gate | 4 | Active | Confirmed active, level matches | Classic Era | none | Gate |
| 491 | Leering Corpse | 4 | Active | Confirmed active, level matches | Classic Era | none | Leering Corpse |
| 502 | Lifespike | 4 | Active | Confirmed active, level matches | Classic Era | none | Lifespike |
| 347 | Numb the Dead | 4 | Active | Confirmed active, level matches | Classic Era | none | Numb the Dead |
| 348 | Poison Bolt | 4 | Active | Confirmed active, level matches | Classic Era | none | Poison Bolt |
| 205 | True North | 4 | Active | Confirmed active, level matches | Classic Era | none | True North |
| 351 | Bone Walk | 8 | Active | Confirmed active, level matches | Classic Era | none | Bone Walk |
| 357 | Dark Empathy | 8 | Active | Confirmed active, level matches | Classic Era | none | Dark Empathy |
| 641 | Dark Pact | 8 | Active | Confirmed active, level matches | Classic Era | none | Dark Pact |
| 352 | Deadeye | 8 | Active | Confirmed active, level matches | Classic Era | none | Deadeye |
| 522 | Gather Shadows | 8 | Active | Confirmed active, level matches | Classic Era | none | Gather Shadows |
| 358 | Impart Strength | 8 | Active | Confirmed active, level matches | Classic Era | none | Impart Strength |
| 246 | Lesser Shielding | 8 | Active | Confirmed active, level matches | Classic Era | none | Lesser Shielding |
| 353 | Mend Bones | 8 | Active | Confirmed active, level matches | Classic Era | none | Mend Bones |
| 354 | Shadow Step | 8 | Active | Confirmed active, level matches | Classic Era | none | Shadow Step |
| 359 | Vampiric Embrace | 8 | Active | Confirmed active, level matches | Classic Era | none | Vampiric Embrace |
| 218 | Ward Undead | 8 | Active | Confirmed active, level matches | Classic Era | none | Ward Undead |
| 362 | Convoke Shadow | 12 | Active | Confirmed active, level matches | Classic Era | none | Convoke Shadow |
| 226 | Endure Disease | 12 | Active | Confirmed active, level matches | Classic Era | none | Endure Disease |
| 355 | Engulfing Darkness | 12 | Active | Confirmed active, level matches | Classic Era | none | Engulfing Darkness |
| 360 | Heat Blood | 12 | Active | Confirmed active, level matches | Classic Era | none | Heat Blood |
| 1509 | Leach | 12 | Active | Confirmed active, level matches | Paineel Era | none | Leach |
| 445 | Lifedraw | 12 | Active | Confirmed active, level matches | Classic Era | none | Lifedraw |
| 1511 | Scent of Dusk | 12 | Active | Confirmed active, level matches | Paineel Era | none | Scent of Dusk |
| 361 | Sight Graft | 12 | Active | Confirmed active, level matches | Classic Era | none | Sight Graft |
| 209 | Spook the Dead | 12 | Active | Confirmed active, level matches | Classic Era | none | Spook the Dead |
| 363 | Wave of Enfeeblement | 12 | Active | Confirmed active, level matches | Classic Era | none | Wave of Enfeeblement |
| 213 | Cure Disease | 16 | Active | Confirmed active, level matches | (none tagged) | none | Cure Disease |
| 366 | Feign Death | 16 | Active | Confirmed active, level matches | (none tagged) | none | Feign Death |
| 367 | Heart Flutter | 16 | Active | Confirmed active, level matches | (none tagged) | none | Heart Flutter |
| 369 | Hungry Earth | 16 | Active | Confirmed active, level matches | (none tagged) | none | Hungry Earth |
| 365 | Infectious Cloud | 16 | Active | Confirmed active, level matches | (none tagged) | none | Infectious Cloud |
| 492 | Restless Bones | 16 | Active | Confirmed active, level matches | (none tagged) | none | Restless Bones |
| 309 | Shielding | 16 | Active | Confirmed active, level matches | Classic Era | none | Shielding |
| 368 | Spirit Armor | 16 | Active | Confirmed active, level matches | (none tagged) | none | Spirit Armor |
| 371 | Voice Graft | 16 | Active | Confirmed active, level matches | (none tagged) | none | Voice Graft |
| 642 | Allure of Death | 20 | Active | Confirmed active, level matches | (none tagged) | none | Allure of Death |
| 440 | Animate Dead | 20 | Active | Confirmed active, level matches | (none tagged) | none | Animate Dead |
| 196 | Dominate Undead | 20 | Active | Confirmed active, level matches | (none tagged) | none | Dominate Undead |
| 233 | Expulse Undead | 20 | Active | Confirmed active, level matches | (none tagged) | none | Expulse Undead |
| 199 | Harmshield | 20 | Active | Confirmed active, level matches | (none tagged) | none | Harmshield |
| 305 | Identify | 20 | Active | Confirmed active, level matches | Classic Era | none | Identify |
| 1510 | Shadow Compact | 20 | Active | Confirmed active, level matches | (none tagged) | none | Shadow Compact |
| 370 | Shadow Vortex | 20 | Active | Confirmed active, level matches | (none tagged) | none | Shadow Vortex |
| 446 | Siphon Life | 20 | Active | Confirmed active, level matches | (none tagged) | none | Siphon Life |
| 698 | Track Corpse | 20 | Active | Confirmed active, level matches | Kunark Era | none | Track Corpse |
| 413 | Word of Shadow | 20 | Active | Confirmed active, level matches | (none tagged) | none | Word of Shadow |
| 493 | Haunting Corpse | 24 | Active | Confirmed active, level matches | (none tagged) | none | Haunting Corpse |
| 449 | Intensify Death | 24 | Active | Confirmed active, level matches | (none tagged) | none | Intensify Death |
| 387 | Leatherskin | 24 | Active | Confirmed active, level matches | Classic Era | none | Leatherskin |
| 65 | Major Shielding | 24 | Active | Confirmed active, level matches | Classic Era | none | Major Shielding |
| 1514 | Rapacious Subversion | 24 | Active | Confirmed active, level matches | (none tagged) | none | Rapacious Subversion |
| 448 | Rest the Dead | 24 | Active | Confirmed active, level matches | (none tagged) | none | Rest the Dead |
| 1512 | Scent of Shadow | 24 | Active | Confirmed active, level matches | (none tagged) | none | Scent of Shadow |
| 549 | Screaming Terror | 24 | Active | Confirmed active, level matches | (none tagged) | none | Screaming Terror |
| 90 | Shadow Sight | 24 | Active | Confirmed active, level matches | (none tagged) | none | Shadow Sight |
| 204 | Shock of Poison | 24 | Active | Confirmed active, level matches | (none tagged) | none | Shock of Poison |
| 451 | Boil Blood | 29 | Active | Confirmed active, level matches | (none tagged) | none | Boil Blood |
| 117 | Dismiss Undead | 29 | Active | Confirmed active, level matches | (none tagged) | none | Dismiss Undead |
| 452 | Dooming Darkness | 29 | Active | Confirmed active, level matches | Classic Era | none | Dooming Darkness |
| 59 | Panic the Dead | 29 | Active | Confirmed active, level matches | (none tagged) | none | Panic the Dead |
| 444 | Renew Bones | 29 | Active | Confirmed active, level matches | (none tagged) | none | Renew Bones |
| 441 | Summon Dead | 29 | Active | Confirmed active, level matches | (none tagged) | none | Summon Dead |
| 454 | Vampiric Curse | 29 | Active | Confirmed active, level matches | (none tagged) | none | Vampiric Curse |
| 414 | Word of Spirit | 29 | Active | Confirmed active, level matches | (none tagged) | none | Word of Spirit |
| 197 | Beguile Undead | 34 | Active | Confirmed active, level matches | (none tagged) | none | Beguile Undead |
| 643 | Call of Bones | 34 | Active | Confirmed active, level matches | Classic Era | none | Call of Bones |
| 66 | Greater Shielding | 34 | Active | Confirmed active, level matches | Classic Era | none | Greater Shielding |
| 127 | Invoke Fear | 34 | Active | Confirmed active, level matches | Classic Era | none | Invoke Fear |
| 230 | Root | 34 | Active | Confirmed active, level matches | Classic Era | none | Root |
| 393 | Steelskin | 34 | Active | Confirmed active, level matches | Classic Era | none | Steelskin |
| 455 | Surge of Enfeeblement | 34 | Active | Confirmed active, level matches | (none tagged) | none | Surge of Enfeeblement |
| 1415 | Torbas Acid Blast | 34 | Active | Confirmed active, level matches | (none tagged) | none | Torbas' Acid Blast (wiki redirect) |
| 435 | Venom of the Snake | 34 | Active | Confirmed active, level matches | (none tagged) | none | Venom of the Snake |
| 1412 | Chilling Embrace | 39 | Active | Confirmed active, level matches | (none tagged) | none | Chilling Embrace |
| 96 | Counteract Disease | 39 | Active | Confirmed active, level matches | Classic Era | none | Counteract Disease |
| 442 | Malignant Dead | 39 | Active | Confirmed active, level matches | (none tagged) | none | Malignant Dead |
| 49 | Nullify Magic | 39 | Active | Confirmed active, level matches | Classic Era | none | Nullify Magic |
| 1513 | Scent of Darkness | 39 | Active | Confirmed active, level matches | (none tagged) | none | Scent of Darkness |
| 31 | Scourge | 39 | Active | Confirmed active, level matches | (none tagged) | none | Scourge |
| 415 | Word of Souls | 39 | Active | Confirmed active, level matches | (none tagged) | none | Word of Souls |
| 67 | Arch Shielding | 44 | Active | Confirmed active, level matches | Classic Era | none | Arch Shielding |
| 1508 | Asystole | 44 | Active | Confirmed active, level matches | Classic Era | none | Asystole |
| 495 | Cackling Bones | 44 | Active | Confirmed active, level matches | (none tagged) | none | Cackling Bones |
| 1413 | Corpal Empathy | 44 | Active | Not found on P99 wiki or FVProject.com (checked both) | (none tagged) | deactivate | Corpal Empathy (searched, no page found on either site) |
| 1515 | Covetous Subversion | 44 | Active | Confirmed active, level matches | (none tagged) | none | Covetous Subversion |
| 457 | Dead Man Floating | 44 | Active | Confirmed active, level matches | Classic Era | none | Dead Man Floating |
| 559 | Ignite Bones | 44 | Active | Confirmed active, level matches | Classic Era | none | Ignite Bones |
| 2014 | Incinerate Bones | 44 | Active | Confirmed active, level matches | (none tagged) | none | Incinerate Bones |
| 694 | Pact of Shadow | 44 | Active | Confirmed active, level matches | Classic Era | none | Pact of Shadow |
| 8621 | Summon Companion | 44 | Active | Confirmed active, level matches | (none tagged) | none | Summon Companion |
| 118 | Banish Undead | 49 | Active | Confirmed active, level matches | (none tagged) | none | Banish Undead |
| 456 | Bond of Death | 49 | Active | Confirmed active, level matches | (none tagged) | none | Bond of Death |
| 198 | Cajole Undead | 49 | Active | Confirmed active, level matches | Classic Era | none | Cajole Undead |
| 453 | Cascading Darkness | 49 | Active | Confirmed active, level matches | Classic Era | none | Cascading Darkness |
| 1391 | Dead Men Floating | 49 | Active | Confirmed active, level matches | Chardok Revamp Era | none | Dead Men Floating |
| 6 | Ignite Blood | 49 | Active | Confirmed active, level matches | (none tagged) | none | Ignite Blood |
| 443 | Invoke Death | 49 | Active | Confirmed active, level matches | (none tagged) | none | Invoke Death |
| 644 | Lich | 49 | Active | Confirmed active, level matches | (none tagged) | none | Lich |
| 133 | Paralyzing Earth | 49 | Active | Confirmed active, level matches | Kunark Era | none | Paralyzing Earth |
| 1411 | Improved Invis vs Undead | 50 | Active | Confirmed active, level matches | Velious Era | none | Improved Invis to Undead (own page title differs; corroborated by item drop page "Improved Invis vs Undead", Velious Era loot) |
| 1532 | Dread of Night | 51 | Active | Confirmed active, level matches | (none tagged) | none | Dread of Night |
| 436 | Envenomed Bolt | 51 | Active | Confirmed active, level matches | Classic Era | none | Envenomed Bolt |
| 1768 | Sacrifice | 51 | Active | Confirmed active, level matches | Kunark Era | none | Sacrifice (spell) (disambiguation page resolved) |
| 1630 | Defoliation | 52 | Active | Confirmed active, level matches | (none tagged) | none | Defoliation |
| 32 | Plague | 52 | Active | Confirmed active, level matches | (none tagged) | none | Plague |
| 1716 | Scent of Terris | 52 | Active | Confirmed active, level matches | (none tagged) | none | Scent of Terris |
| 1526 | Annul Magic | 53 | Active | Confirmed active, level matches | Kunark Era | none | Annul Magic |
| 131 | Enstill | 53 | Active | Confirmed active, level matches | Classic Era | none | Enstill |
| 1621 | Minion of Shadows | 53 | Active | Confirmed active, level matches | (none tagged) | none | Minion of Shadows |
| 1613 | Deflux | 54 | Active | Confirmed active, level matches | (none tagged) | none | Deflux |
| 1717 | Shadowbond | 54 | Active | Confirmed active, level matches | (none tagged) | none | Shadowbond |
| 1610 | Shield of the Magi | 54 | Active | Confirmed active, level matches | Kunark Era | none | Shield of the Magi |
| 1624 | Thrall of Bones | 54 | Active | Confirmed active, level matches | (none tagged) | none | Thrall of Bones |
| 1414 | Augmentation of Death | 55 | Active | Confirmed active, level matches | (none tagged) | none | Augmentation of Death |
| 1614 | Chill Bones | 55 | Active | Confirmed active, level matches | (none tagged) | none | Chill Bones |
| 2015 | Conglaciation of Bone | 55 | Active | Confirmed active, level matches | Chardok Revamp Era | none | Conglaciation of Bone |
| 1734 | Infusion | 55 | Active | Confirmed active, level matches | (none tagged) | none | Infusion |
| 1626 | Levant | 55 | Active | Confirmed active, level matches | (none tagged) | none | Levant |
| 1615 | Cessation of Cor | 56 | Active | Confirmed active, level matches | (none tagged) | none | Cessation of Cor |
| 1718 | Sedulous Subversion | 56 | Active | Confirmed active, level matches | Kunark Era | none | Sedulous Subversion |
| 1622 | Servant of Bones | 56 | Active | Confirmed active, level matches | (none tagged) | none | Servant of Bones |
| 1527 | Trepidation | 56 | Active | Confirmed active, level matches | (none tagged) | none | Trepidation |
| 1528 | Exile Undead | 57 | Active | Confirmed active, level matches | (none tagged) | none | Exile Undead |
| 132 | Immobilize | 58 | Active | Confirmed active, level matches | Classic Era | none | Immobilize |
| 1623 | Emissary of Thule | 59 | Active | Confirmed active, level matches | Kunark Era | none | Emissary of Thule |
| 1416 | Arch Lich | 60 | Active | Confirmed active, level matches | (none tagged) | none | Arch Lich |
| 1530 | Banishment of Shadows | 60 | Active | Confirmed active, level matches | (none tagged) | none | Banishment of Shadows |
| 1611 | Demi Lich | 60 | Active | Confirmed active, level matches | (none tagged) | none | Demi Lich |
| 1629 | Enslave Death | 60 | Active | Confirmed active, level matches | (none tagged) | none | Enslave Death |
| 1393 | Gangrenous Touch of Zum`uul | 60 | Active | Confirmed active, level matches | Chardok Revamp Era | none | Gangrenous Touch of Zum`uul |
| 1735 | Trucidation | 60 | Active | Confirmed active, level matches | (none tagged) | none | Trucidation |

---

## For the follow-up migration script (not written here)

1. Set `classes11 = 255` on: id 1413 (Corpal Empathy, not documented).
2. Set `classes11 = 255` on the 22 solidly-evidenced duplicate-losers: 225,
   346, 40971, 364, 8662, 236, 61, 524, 63, 661, 525, 662, 3, 394, 447, 1620,
   32397, 1625, 1616, 1612, 1619, 1618 (22 ids — includes both Shieldskin's
   solidly-resolved loser, id 236, and Quivering Veil's solidly-resolved
   loser, id 1612, even though each of those two groups also has a separate
   *remaining* tie between its other two ids, handled in step 3; the 7
   true-tie groups' still-undecided losers are intentionally excluded from
   this step, pending human confirmation below).
3. For the 7 true-tie groups, get a human decision on which id to deactivate
   before including them in the same script (or ship them as a separate,
   clearly-labeled low-confidence batch): Shieldskin (8640 vs 8657),
   Breath of the Dead (478 vs 8660), Invoke Shadow (494 vs 8659), Manaskin
   (1609 vs 8521), Conjure Corpse (1773 vs 8661), Pyrocruor (1617 vs 8509),
   Quivering Veil of Xarn (8508 vs 8673).
4. Per `CODING_STANDARDS.md`/`TESTING.md`: back up first, verify post-run via
   direct query (targeted checks on every id above, zero-result confirmation
   that `classes11` reads 255, exclusion check that no other id was touched,
   random sampling), and record an entry in `000_UNCLASSIC_DECISIONS.md` is
   **not** needed here (these are era-accuracy corrections, not deliberate
   non-classic choices) — a `CHANGELOG.md` line referencing this document is
   sufficient per the ADR-threshold convention already in place.
