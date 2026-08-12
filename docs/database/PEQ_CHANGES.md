# PEQ Changes

Quick-reference table of all changes made to the Angels Misfits
database relative to its original PEQ import. For full reasoning,
evidence, timing, and implementation detail, see the referenced ADR.

**"TAKP" throughout this document** means the project's local comparison
database — obtained by the user and claimed to be sourced from TAKP (The
Al'Kabor Project), with provenance this project cannot independently
verify. It is not an authoritative source; treat "adopt TAKP value" below
as "adopt the comparison database's value" — some of these were
independently verified against real classic client data (spells, ADR-004),
others only matched the comparison file's own claims about its tuning
(NPC/pet stats, ADR-003/005). See `docs/research/TAKP.md` for the
category-by-category breakdown.

---

## Content Scope Gating (ADR-001)

| Rule | Original (PEQ) | New Value | Reason |
|---|---|---|---|
| `World:ExpansionSettings` | 524287 (maskRoF) | 3 (maskSoV) | Restrict live content to Classic + Kunark + Velious |
| `Expansion:CurrentExpansion` | (unset/modern) | 2 | Set current expansion to Velious |
| `World:CharacterSelectExpansionSettings` | (unset/modern) | 3 | Match char-select screen to expansion gate |
| `World:UseClientBasedExpansionSettings` | true (compiled default) | false | Prevent client's own expansion level from overriding the gate above |

---

## Server Rules (ADR-002)

| Rule | Original (PEQ) | New Value | Reason |
|---|---|---|---|
| `Character:MaxLevel` | 50 (initial)* | 60 | Kunark raised cap to 60; Velious kept it. *Corrected 2026-07-26 — initial 50 was a factual error. |
| `Character:MaxExpLevel` | 50 (initial)* | 60 | Same as above |
| `Character:ExpMultiplier` | (PEQ default) | 0.65 | Faster than classic; deliberate solo-pacing deviation |
| `Character:AAExpMultiplier` | (PEQ default) | 0.65 | Match exp multiplier |
| `Character:FullGroupEXPModifier` | (PEQ default) | 2.16 | Kept at PEQ value |
| `Character:GroupMemberEXPModifier` | (PEQ default) | 0.20 | Kept at PEQ value |
| `Character:UseOldClassExpPenalties` | true (classic) | false | Deliberate deviation — solo play |
| `Character:UseOldRaceExpPenalties` | true (classic) | false | Deliberate deviation — solo play |
| `Character:DeathExpLossLevel` | 10 (PEQ) / 5 (TAKP) | 15 | Custom value, neither source |
| `Character:DeathExpLossMultiplier` | (PEQ default) | 3 | ~3.5% loss on death |
| `Character:DeathKeepLevel` | false | true | No de-leveling on death |
| `Character:DeathItemLossLevel` | 10 (PEQ) / 90 (TAKP, rejected) | 15 | TAKP's 90 would disable item loss entirely at level-50 cap |
| `Character:LeaveNakedCorpses` | (PEQ default) | false | No corpse spawned if player died carrying nothing |
| `Character:CorpseDecayTime` | (PEQ default) | 2147483647 | Practical ceiling (~24.86 days), not true "never" — see 32-bit signed int limit |
| `Character:EmptyCorpseDecayTime` | (PEQ default) | 30000 | 30-sec buffer after corpse is looted clean |
| `Character:EnableHungerPenalties` | false | true | Restore classic food/drink requirement |
| `Character:EnableTGB` | true | false | `/tgb` is post-Velious |
| `Character:RestRegenEnabled` | true | false | Later-era mechanic |
| `Combat:ClassicMasterWu` | false | true | Restore classic monk behavior |
| `Spells:WizCritLevel` | 12 (PEQ) / 80 (TAKP, rejected) | 10 | Community/inference-based; see ADR-002 Research Note for uncertainty |
| `Character:BindAnywhere` | false (classic) | true | Deliberate non-classic deviation |

**Deliberately not set:** `Pets:CanTakeQuestItems` — exists in TAKP but unseeded in PEQ; risk of phantom rule.
**Explicitly rejected in full:** all `Bots:*` rules — group content handled via VV MQ multiboxing, not the EQEmu bot system.

---

## NPC Combat Stats (ADR-003)

Bulk change across ~12,574 NPCs scoped to Classic/Kunark/Velious spawns. Individual per-NPC values not listed here — see ADR-003 for methodology and full scope.

| Field | Change Method | Rows Affected | Reason |
|---|---|---|---|
| `hp` | Adopt TAKP value in full | 4,430 | TAKP consistently higher (median 1.20×) |
| `maxdmg` | Adopt TAKP value in full | 1,992 | TAKP consistently higher (median 1.09×) |
| `AC` | Adopt TAKP value in full | 214 | TAKP consistently higher (median 1.32×) |
| `hp_regen_rate` | Adopt TAKP value in full | 12,403 | TAKP consistently higher (median 43.75×) |
| `MR` / `CR` / `FR` | Adopt TAKP value in full | ~11,600–11,900 each | TAKP consistently higher (median 2.92×) |
| `DR` / `PR` | Adopt TAKP value in full | ~11,760 each | TAKP consistently higher (median 2.50×) |
| `aggroradius` | Custom: arithmetic midpoint of PEQ/TAKP | 1,132 | Full TAKP widening rejected as too punishing for multibox play |

---

## Pet Stats (ADR-005)

Bulk change across 140 of 423 pet-linked NPC templates.

| Field | Change Method | Direction | Reason |
|---|---|---|---|
| `hp` | Adopt TAKP value | Mostly lower (median 0.99×) | Author-stated "less powerful pets" tuning |
| `mindmg` / `maxdmg` | Adopt TAKP value | Mostly lower (0.36× / 0.89×) | Same |
| `AC` | Adopt TAKP value | Roughly balanced (0.93×) | Same |
| `hp_regen_rate` | Adopt TAKP value | Overwhelmingly lower (0.35×) | Same |
| `MR` / `FR` | Adopt TAKP value | Higher (1.67×) | Same source dataset |
| `CR` / `DR` / `PR` | Adopt TAKP value | Mixed (0.58–0.72×) | Same |
| `runspeed` | Adopt TAKP value | Uniformly higher (1.24×) | No stated rationale; adopted as part of verified dataset |

---

## Spell Mechanics (ADR-004)

| Scope | Change Method | Reason |
|---|---|---|
| `spells_new`, 37,729 of ~40,722 spells, 144,666 field changes | Adopt TAKP value in full | TAKP verified byte-for-byte identical to real classic client `spells_us.txt`; PEQ diverges on hundreds to 1,000+ spells per mechanical field |

3 TAKP-only placeholder spells (ids 0, 1348, 5093) excluded as test data. 6 PEQ-only spells left unchanged (no classic reference exists).

---

## Starting Items (ADR-006)

| Item | Original | New | Reason |
|---|---|---|---|
| Gloomingdeep Lantern (id 2, item 9979) | Present | Removed | Absent from TAKP; tied to post-Velious tutorial zone |
| Backpack (id 137, item 32601) | Present | Removed | Absent from TAKP; absent from P99 guide; live-EQ-only mechanic |

All other starting_items rows (recruitment letters, weapons, food/drink, bandages, prescribed spells) verified classic and retained unchanged.

---

## NPC Models (ADR-007)

| Race Change | Scope | Rows | Reason |
|---|---|---|---|
| 367 → 60 | Unconditional | 1,365 | Newer skeleton model corrected to Luclin-era approximation (best available "classic-style" option) |
| 161 → 60 | Name-scoped ("-bone" family, generic skeletal_* names) | 265 of 454 | Generic zone-flavor skeletons, not genuine Iksar-identity NPCs |
| 606 → 161 | Unconditional, run after 161→60 | 4 | Mismatched model corrected to proper Iksar identity |

193 NPCs remain deliberately at race 161 (genuine Iksar-identity content, e.g. Sythrax cult, named nobility, Jarsath tribe).

**Not attempted:** humanoid PC-race NPC/PC model separation (guards, etc.) — confirmed engine-level limitation, not database-fixable. See ADR-007 and ADR-008.

---

## Post-ADR-007 Corrections

| Table | Change | Reference |
|---|---|---|
| `spells_new` | Legacy-audit corrections across all Velious-playable classes; six cosmetic Necromancer illusion size overrides | ADR-009, ADR-012 Part 1 |
| `rule_values` | Classic minimum mana floor; pet zoning/logout behavior; era-containment cleanup | `2026-08-01_classic_minimum_mana_regen.sql`, `2026-08-01_era_containment_cleanup.sql`, CHANGELOG 2026-08-04 |
| `rule_values` | `Character:UseClassicRegen` added and verified 2026-08-09 (gates the source-level classic HP/mana regen rebuild) | ADR-021, `2026-08-08_classic_regen_formulas.sql` |
| `character_inventory` | RoF2 container child-slot location-format repair for Angel's personal and bank bags | ADR-011, `2026-08-01_angel_personal_bag_slot_repair.sql` |
| `npc_types` | Race-60 skeleton pet material template and late-game Necromancer pet race correction (485 → 85) | ADR-012 Parts 2–3, `2026-08-02_necromancer_pet_race_correction.sql` |
| `content_flags` | `don_nest_unlocked` disabled as Velious-era defense in depth | `2026-08-01_era_containment_cleanup.sql` |
| `items` | Applied and verified 2026-08-06 — four-item Classic stack-size correction (Peridot, Bat Wing, Bone Chips, Spiderling Silk) | `2026-08-06_classic_item_stack_size_phase_1.sql` |

The item-stack migration is intentionally narrow: the listed item histories are
verified, while a blanket stack-size conversion would incorrectly alter Classic
ammunition and other items that legitimately stack to 100.

---

## Item Drop Era Gating (ADR-016)

Applied and verified 2026-08-06 (`scripts/2026-08-06_itemization_content_flags_gating.sql`).

| Item(s) | Flag | Live source(s) | Reason |
|---|---|---|---|
| Rubicite armor set (12 pieces, ids 4161-4172) | `Classic_OldWorldDrops` | a_lifestealer_mosquito ×6 NPCs | Removed/disabled Oct 13, 1999 |
| Cryosilk armor set (12 pieces, ids 1211-1222) | `Classic_OldWorldDrops` | a_spinechiller_spider ×5, plus per-piece extra sources (raid NPCs, phoboplasm, haunted chest) | "Fear Era" legacy set |
| Boots of Brawn (12181) | `Classic_OldWorldDrops` | Sir Lucan D`Lere | Dropped until Kunark released |
| Journeyman's Boots (2300) | `Classic_OldWorldDrops` | #The_Fabled_Drelzna, Najena | Changed to quest-based source, Oct 13, 1999 |
| Sarnak Liberator (11924) | `Kunark_LegacyItemDrops` | a_Sarnak_flunkie ×3 NPCs | Removed shortly after Kunark |
| Goblin Eye Poker (10597) | `Kunark_LegacyItemDrops` | #Scout_Charisa (only reachable source) | Removed — was an All/All weapon |

Every other item in FV Project's Classic_OldWorldDrops and
Kunark_LegacyItemDrops lists was checked and found already correct — see
ADR-016 for the full accounting, including two items excluded for
insufficient evidence (Cloak of Shadows, Gem Encrusted Ring) and two open
follow-ups (Kunark_HoleEra raid-mob spawn gating; Rallia Hapera's Hole Key
merchant flag).

---

## Named-NPC Loot Reconciliation (ADR-017)

Applied and verified 2026-08-06 (`scripts/2026-08-06_named_npc_loot_reconciliation_phase_1.sql`).

| Scope | Change | Reason |
|---|---|---|
| 21 lootdrop_entries INSERTs across 15 Classic/Kunark/Velious named NPCs | Restore documented-but-missing wiki loot | Confirmed absent via direct DB query against P99 wiki `known_loot` |
| 2 new loottable/lootdrop pairs (Lhranc, High Scale Kirn) | Both had `loottable_id = 0` — zero loot despite a documented 100% drop each | Lhranc is the Shadow Knight Epic 1.0 mob; this was quest-blocking |
| `lootdrop_entries.content_flags` on Eye of RokGus (item 12881, Chief RokGus) | Gated via `Kunark_LegacyItemDrops` (same flag as ADR-016) | Wiki: "No longer drops" |

~25 additional lower-confidence or design-ambiguous findings (large-scale set replacements, possible cross-NPC item mis-assignments, wiki-uncertain items) are documented in ADR-017 as deferred to a future Phase 2, not included in this migration.

---

## Deferred / Not Yet Changed

- `items` — no global expansion-scoping applied yet (ADR-001, ongoing); the
  targeted stack-size migration above is separate from that work and has
  now been applied (see table above).
- `spells_new` — no level/class filtering for above-cap content (inert but present).
- Quest scripts, custom encounters, itemization beyond starting kit — not yet reviewed.
