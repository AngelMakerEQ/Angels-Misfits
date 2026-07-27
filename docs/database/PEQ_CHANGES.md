# PEQ Changes

Quick-reference table of all changes made to the Angels Misfits
database relative to its original PEQ import. For full reasoning,
evidence, timing, and implementation detail, see the referenced ADR.

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

## Deferred / Not Yet Changed

- `items` — no expansion-scoping applied yet (ADR-001, ongoing).
- `spells_new` — no level/class filtering for above-cap content (inert but present).
- Quest scripts, custom encounters, itemization beyond starting kit — not yet reviewed.
