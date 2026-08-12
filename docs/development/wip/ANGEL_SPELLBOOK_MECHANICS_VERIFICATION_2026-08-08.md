# Angel Spellbook Mechanics Verification (2026-08-08)

**Status:** Investigation only — no database changes made. For human review;
any correction requires its own ADR/migration per `CODING_STANDARDS.md`.

**Scope:** All 108 spells in Angel's (character id 1, level 40 Necromancer)
spellbook. The spell *list* itself was confirmed correct/era-appropriate by
a prior audit and is not re-litigated here. This pass checks stored
**mechanics** (mana, cast/recast/recovery time, buff duration, damage/heal/
effect magnitude) in `spells_new` against what the P99 wiki documents for
each spell.

**Sources:** Live `angelsmisfits` database (`spells_new`, read via
`mcp__eqemu__run_query`) vs `wiki.project1999.com` API (`action=query`,
`prop=revisions`). All 108 spell pages were found on the P99 wiki directly
(one redirect: `Torbas Acid Blast` → `Torbas' Acid Blast`); the `fvproject.com`
fallback was not needed.

## Summary

- **Spells checked:** 108
- **Fully matched** (every checkable field agrees, or the only difference is
  explained by this server's Velious-era level-60 cap — see note below): **99**
- **Spells with at least one confirmed/likely mismatch:** **9** (listed below)
- **Baseline timing fields** (mana, cast_time, recast_time, recovery_time):
  431 of 432 individual field comparisons matched exactly; the sole
  exception is Reclaim Energy's recovery_time.
- No spell lacked every checkable field — all 108 had at least mana/cast/
  recast/recovery/duration to check. A smaller subset (roughly two dozen,
  mostly pure-utility instants like Gate, True North, Locate Corpse,
  Feign Death, Identify) had no *magnitude* (damage/heal/stat) number to
  check beyond timing and duration; those are simply not itemized in the
  magnitude table below.

### Spells with confirmed or likely mismatches

| id | Spell | Issue |
|---|---|---|
| 331 | Reclaim Energy | `recovery_time` = 2500ms in DB vs wiki's `fizzle_time` 2.25s (2250ms) |
| 355 | Engulfing Darkness | `buffduration` = 10 ticks vs wiki's stated 11 ticks (cross-checked against the wiki's own DPS/DPM math) |
| 435 | Venom of the Snake | `buffduration` = 7 ticks; wiki states a 7–8 tick range and DB sits at the bottom, not the top (medium confidence — see caveats) |
| 452 | Dooming Darkness | `buffduration` = 15 ticks vs wiki's implied 16 ticks (20 dmg/tick × 16 = wiki's own stated 320 total) |
| 1412 | Chilling Embrace | `buffduration` = 15 ticks vs wiki's flat "16 ticks" (40 dmg/tick × 16 = wiki's own stated 640 total); **also**, the spell's live effect list has no "Increase Poison Counter by 3" effect at all (wiki's SLOT1) — only the HP-drain tick effect and inert padding slots are present |
| 641 | Dark Pact | Hidden HP-drain effect (slot 7, `effect_base_value7`) = **-4**/tick vs wiki's "Decrease hitpoints by 2 per tick" |
| 642 | Allure of Death | Hidden HP-drain effect (slot 7) = **-8**/tick vs wiki's "Decrease Hitpoints by 5 per tick" |
| 643 | Call of Bones | Hidden HP-drain effect (slot 7) = **-16**/tick vs wiki's "Decrease Hitpoints by 10 per tick" |
| 369 | Hungry Earth | "Decrease HP when cast" (`SE_CurrentHPOnce`) = -10 vs wiki's stated 26 (L16) to 75 (L65) range — DB value doesn't land near either end (medium confidence; may need formula-level review) |

The Dark Pact family (641/642/643) is the most concrete finding: the mana-gain
side of all three spells matches the wiki exactly (2/4/8 per tick), but the
HP-drain side is roughly 1.6–2x too strong in all three, discovered only by
querying `effectid7`/`effect_base_value7` directly — these values sit outside
the `effect_base_value1-3` columns the standard query covers, in a slot the
wiki numbers by its actual in-client slot position 7.

## Important methodology notes (read before treating any "DIFF" as a bug)

1. **Velious-era level-60 cap.** ADR-002's level-cap correction fixes this
   server's `Character:MaxLevel`/`MaxExpLevel` at 60 (Kunark's cap; Velious
   added no further increase). The live, ongoing P99 wiki reflects a server
   that has since progressed past Velious to a 65+ level cap, so several
   spells' wiki `duration` fields quote an "@L65" example that is **not
   reachable on this server**. Where a spell's duration scales linearly
   with caster level, extrapolating the wiki's own stated growth rate to
   level 60 exactly reproduces the DB's stored value. Verified this way for:
   **Dominate Undead (196)**, **Beguile Undead (197)**, **Shadow Vortex (370)**,
   **Intensify Death (449)**, **Call of Bones (643)** duration, **Scent of
   Dusk/Shadow/Darkness (1511/1512/1513)** — all counted as **matches** above,
   not mismatches, despite the raw wiki number differing from the DB.
2. **AC magnitudes excluded.** Spell-granted Armor Class (`SE_ArmorClass`,
   effect id 1) is stored in the DB as raw internal AC, which is a different
   scale than the "Increase/Decrease AC by X" number the wiki displays
   (confirmed via `effectid`/`SE_ArmorClass` in the EQEmu source — the raw
   DB values ran ~2.5-3.3x the wiki's displayed number across every shielding
   spell checked, not a bug). AC comparisons are intentionally left out of
   the table rather than reported as false mismatches.
3. **Attack Speed offset.** `SE_AttackSpeed` values are stored as
   `100 + percent_change` (100 = unmodified). DB `130` = wiki's "+30%" — a
   match, not a discrepancy. Confirmed on Intensify Death and Augment Death.
4. **Slot alignment required extra queries.** The task's baseline query
   (`effect_base_value1-3`, `max1-2`) does not reliably line up with the
   wiki's displayed slot numbers once a spell has more than ~3 real effects,
   because unused slots are padded with inert `SE_CHA`/`SE_Blank` filler
   between real effects. Every multi-effect spell in the mismatch list above
   was re-verified with a direct `effectid`/`effect_base_value` query up to
   slot 8 before being flagged, specifically to rule out a false mismatch
   from slot misalignment (this is how the Dark Pact family's real
   HP-drain slot, and Chilling Embrace's missing poison-counter effect,
   were found in the first place).
5. **Wiki self-inconsistency.** A few pages' prose `description` field gives
   a slightly different number than the page's own structured
   `SpellSlotRow`/`SpellSlotRowSmart` line (e.g. Word of Spirit: description
   says "91 to 103", the slot row says "97 (L29) to 104 (L33)"). The
   structured slot-row value was treated as authoritative in those cases,
   and the DB matched it in every instance found.

## Full comparison table — mana / cast time / recast time / recovery time

(432 checks; only the one flagged row differs)

| id | name | field | DB value | wiki value | verdict | citation |
|---|---|---|---|---|---|---|
| 31 | Scourge | mana | 170 | 170 | match | P99 wiki: Scourge |
| 31 | Scourge | cast_time(ms) | 4600 | 4.60s -> 4600ms | match | P99 wiki: Scourge |
| 31 | Scourge | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Scourge |
| 31 | Scourge | recovery_time(ms) | 2500 | 2.50s -> 2500ms | match | P99 wiki: Scourge |
| 35 | Bind Affinity | mana | 100 | 100 | match | P99 wiki: Bind Affinity |
| 35 | Bind Affinity | cast_time(ms) | 6000 | 6.00s -> 6000ms | match | P99 wiki: Bind Affinity |
| 35 | Bind Affinity | recast_time(ms) | 12000 | 12.00s -> 12000ms | match | P99 wiki: Bind Affinity |
| 35 | Bind Affinity | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Bind Affinity |
| 36 | Gate | mana | 70 | 70 | match | P99 wiki: Gate |
| 36 | Gate | cast_time(ms) | 5000 | 5.00s -> 5000ms | match | P99 wiki: Gate |
| 36 | Gate | recast_time(ms) | 8000 | 8.00s -> 8000ms | match | P99 wiki: Gate |
| 36 | Gate | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Gate |
| 48 | Cancel Magic | mana | 30 | 30 | match | P99 wiki: Cancel Magic |
| 48 | Cancel Magic | cast_time(ms) | 3500 | 3.50s -> 3500ms | match | P99 wiki: Cancel Magic |
| 48 | Cancel Magic | recast_time(ms) | 5000 | 5.00s -> 5000ms | match | P99 wiki: Cancel Magic |
| 48 | Cancel Magic | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Cancel Magic |
| 49 | Nullify Magic | mana | 50 | 50 | match | P99 wiki: Nullify Magic |
| 49 | Nullify Magic | cast_time(ms) | 4500 | 4.50s -> 4500ms | match | P99 wiki: Nullify Magic |
| 49 | Nullify Magic | recast_time(ms) | 6000 | 6.00s -> 6000ms | match | P99 wiki: Nullify Magic |
| 49 | Nullify Magic | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Nullify Magic |
| 59 | Panic the Dead | mana | 50 | 50 | match | P99 wiki: Panic the Dead |
| 59 | Panic the Dead | cast_time(ms) | 2000 | 2.00s -> 2000ms | match | P99 wiki: Panic the Dead |
| 59 | Panic the Dead | recast_time(ms) | 4000 | 4.00s -> 4000ms | match | P99 wiki: Panic the Dead |
| 59 | Panic the Dead | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Panic the Dead |
| 65 | Major Shielding | mana | 80 | 80 | match | P99 wiki: Major Shielding |
| 65 | Major Shielding | cast_time(ms) | 5000 | 5.00s -> 5000ms | match | P99 wiki: Major Shielding |
| 65 | Major Shielding | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Major Shielding |
| 65 | Major Shielding | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Major Shielding |
| 66 | Greater Shielding | mana | 120 | 120 | match | P99 wiki: Greater Shielding |
| 66 | Greater Shielding | cast_time(ms) | 6000 | 6.00s -> 6000ms | match | P99 wiki: Greater Shielding |
| 66 | Greater Shielding | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Greater Shielding |
| 66 | Greater Shielding | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Greater Shielding |
| 90 | Shadow Sight | mana | 50 | 50 | match | P99 wiki: Shadow Sight |
| 90 | Shadow Sight | cast_time(ms) | 3000 | 3.00s -> 3000ms | match | P99 wiki: Shadow Sight |
| 90 | Shadow Sight | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Shadow Sight |
| 90 | Shadow Sight | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Shadow Sight |
| 96 | Counteract Disease | mana | 50 | 50 | match | P99 wiki: Counteract Disease |
| 96 | Counteract Disease | cast_time(ms) | 4000 | 4.00s -> 4000ms | match | P99 wiki: Counteract Disease |
| 96 | Counteract Disease | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Counteract Disease |
| 96 | Counteract Disease | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Counteract Disease |
| 117 | Dismiss Undead | mana | 90 | 90 | match | P99 wiki: Dismiss Undead |
| 117 | Dismiss Undead | cast_time(ms) | 3300 | 3.30s -> 3300ms | match | P99 wiki: Dismiss Undead |
| 117 | Dismiss Undead | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Dismiss Undead |
| 117 | Dismiss Undead | recovery_time(ms) | 2500 | 2.50s -> 2500ms | match | P99 wiki: Dismiss Undead |
| 127 | Invoke Fear | mana | 100 | 100 | match | P99 wiki: Invoke Fear |
| 127 | Invoke Fear | cast_time(ms) | 2500 | 2.50s -> 2500ms | match | P99 wiki: Invoke Fear |
| 127 | Invoke Fear | recast_time(ms) | 7000 | 7.00s -> 7000ms | match | P99 wiki: Invoke Fear |
| 127 | Invoke Fear | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Invoke Fear |
| 196 | Dominate Undead | mana | 100 | 100 | match | P99 wiki: Dominate Undead |
| 196 | Dominate Undead | cast_time(ms) | 5000 | 5.00s -> 5000ms | match | P99 wiki: Dominate Undead |
| 196 | Dominate Undead | recast_time(ms) | 10000 | 10.00s -> 10000ms | match | P99 wiki: Dominate Undead |
| 196 | Dominate Undead | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Dominate Undead |
| 197 | Beguile Undead | mana | 170 | 170 | match | P99 wiki: Beguile Undead |
| 197 | Beguile Undead | cast_time(ms) | 6000 | 6.00s -> 6000ms | match | P99 wiki: Beguile Undead |
| 197 | Beguile Undead | recast_time(ms) | 12000 | 12.00s -> 12000ms | match | P99 wiki: Beguile Undead |
| 197 | Beguile Undead | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Beguile Undead |
| 199 | Harmshield | mana | 85 | 85 | match | P99 wiki: Harmshield |
| 199 | Harmshield | cast_time(ms) | 1000 | 1.00s -> 1000ms | match | P99 wiki: Harmshield |
| 199 | Harmshield | recast_time(ms) | 600000 | 600.00s -> 600000ms | match | P99 wiki: Harmshield |
| 199 | Harmshield | recovery_time(ms) | 2500 | 2.50s -> 2500ms | match | P99 wiki: Harmshield |
| 204 | Shock of Poison | mana | 100 | 100 | match | P99 wiki: Shock of Poison |
| 204 | Shock of Poison | cast_time(ms) | 3500 | 3.50s -> 3500ms | match | P99 wiki: Shock of Poison |
| 204 | Shock of Poison | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Shock of Poison |
| 204 | Shock of Poison | recovery_time(ms) | 2500 | 2.50s -> 2500ms | match | P99 wiki: Shock of Poison |
| 205 | True North | mana | 5 | 5 | match | P99 wiki: True North |
| 205 | True North | cast_time(ms) | 2000 | 2.00s -> 2000ms | match | P99 wiki: True North |
| 205 | True North | recast_time(ms) | 4000 | 4.00s -> 4000ms | match | P99 wiki: True North |
| 205 | True North | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: True North |
| 209 | Spook the Dead | mana | 10 | 10 | match | P99 wiki: Spook the Dead |
| 209 | Spook the Dead | cast_time(ms) | 2000 | 2.00s -> 2000ms | match | P99 wiki: Spook the Dead |
| 209 | Spook the Dead | recast_time(ms) | 4000 | 4.00s -> 4000ms | match | P99 wiki: Spook the Dead |
| 209 | Spook the Dead | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Spook the Dead |
| 213 | Cure Disease | mana | 20 | 20 | match | P99 wiki: Cure Disease |
| 213 | Cure Disease | cast_time(ms) | 2000 | 2.00s -> 2000ms | match | P99 wiki: Cure Disease |
| 213 | Cure Disease | recast_time(ms) | 3000 | 3.00s -> 3000ms | match | P99 wiki: Cure Disease |
| 213 | Cure Disease | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Cure Disease |
| 218 | Ward Undead | mana | 30 | 30 | match | P99 wiki: Ward Undead |
| 218 | Ward Undead | cast_time(ms) | 2100 | 2.10s -> 2100ms | match | P99 wiki: Ward Undead |
| 218 | Ward Undead | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Ward Undead |
| 218 | Ward Undead | recovery_time(ms) | 2500 | 2.50s -> 2500ms | match | P99 wiki: Ward Undead |
| 221 | Sense the Dead | mana | 5 | 5 | match | P99 wiki: Sense the Dead |
| 221 | Sense the Dead | cast_time(ms) | 2000 | 2.00s -> 2000ms | match | P99 wiki: Sense the Dead |
| 221 | Sense the Dead | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Sense the Dead |
| 221 | Sense the Dead | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Sense the Dead |
| 226 | Endure Disease | mana | 20 | 20 | match | P99 wiki: Endure Disease |
| 226 | Endure Disease | cast_time(ms) | 2500 | 2.50s -> 2500ms | match | P99 wiki: Endure Disease |
| 226 | Endure Disease | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Endure Disease |
| 226 | Endure Disease | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Endure Disease |
| 229 | Fear | mana | 40 | 40 | match | P99 wiki: Fear |
| 229 | Fear | cast_time(ms) | 3500 | 3.50s -> 3500ms | match | P99 wiki: Fear |
| 229 | Fear | recast_time(ms) | 7000 | 7.00s -> 7000ms | match | P99 wiki: Fear |
| 229 | Fear | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Fear |
| 230 | Root | mana | 30 | 30 | match | P99 wiki: Root |
| 230 | Root | cast_time(ms) | 2000 | 2.00s -> 2000ms | match | P99 wiki: Root |
| 230 | Root | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Root |
| 230 | Root | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Root |
| 233 | Expulse Undead | mana | 60 | 60 | match | P99 wiki: Expulse Undead |
| 233 | Expulse Undead | cast_time(ms) | 2750 | 2.75s -> 2750ms | match | P99 wiki: Expulse Undead |
| 233 | Expulse Undead | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Expulse Undead |
| 233 | Expulse Undead | recovery_time(ms) | 2500 | 2.50s -> 2500ms | match | P99 wiki: Expulse Undead |
| 235 | Invisibility versus Undead | mana | 40 | 40 | match | P99 wiki: Invisibility versus Undead |
| 235 | Invisibility versus Undead | cast_time(ms) | 4000 | 4.00s -> 4000ms | match | P99 wiki: Invisibility versus Undead |
| 235 | Invisibility versus Undead | recast_time(ms) | 4000 | 4.00s -> 4000ms | match | P99 wiki: Invisibility versus Undead |
| 235 | Invisibility versus Undead | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Invisibility versus Undead |
| 246 | Lesser Shielding | mana | 25 | 25 | match | P99 wiki: Lesser Shielding |
| 246 | Lesser Shielding | cast_time(ms) | 4000 | 4.00s -> 4000ms | match | P99 wiki: Lesser Shielding |
| 246 | Lesser Shielding | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Lesser Shielding |
| 246 | Lesser Shielding | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Lesser Shielding |
| 288 | Minor Shielding | mana | 10 | 10 | match | P99 wiki: Minor Shielding |
| 288 | Minor Shielding | cast_time(ms) | 2500 | 2.50s -> 2500ms | match | P99 wiki: Minor Shielding |
| 288 | Minor Shielding | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Minor Shielding |
| 288 | Minor Shielding | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Minor Shielding |
| 305 | Identify | mana | 50 | 50 | match | P99 wiki: Identify |
| 305 | Identify | cast_time(ms) | 5000 | 5.00s -> 5000ms | match | P99 wiki: Identify |
| 305 | Identify | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Identify |
| 305 | Identify | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Identify |
| 309 | Shielding | mana | 50 | 50 | match | P99 wiki: Shielding |
| 309 | Shielding | cast_time(ms) | 5000 | 5.00s -> 5000ms | match | P99 wiki: Shielding |
| 309 | Shielding | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Shielding |
| 309 | Shielding | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Shielding |
| 331 | Reclaim Energy | mana | 5 | 5 | match | P99 wiki: Reclaim Energy |
| 331 | Reclaim Energy | cast_time(ms) | 2500 | 2.50s -> 2500ms | match | P99 wiki: Reclaim Energy |
| 331 | Reclaim Energy | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Reclaim Energy |
| 331 | Reclaim Energy | recovery_time(ms) | 2500 | 2.25s -> 2250ms | **mismatch** | P99 wiki: Reclaim Energy |
| 338 | Cavorting Bones | mana | 15 | 15 | match | P99 wiki: Cavorting Bones |
| 338 | Cavorting Bones | cast_time(ms) | 5000 | 5.00s -> 5000ms | match | P99 wiki: Cavorting Bones |
| 338 | Cavorting Bones | recast_time(ms) | 4000 | 4.00s -> 4000ms | match | P99 wiki: Cavorting Bones |
| 338 | Cavorting Bones | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Cavorting Bones |
| 339 | Coldlight | mana | 15 | 15 | match | P99 wiki: Coldlight |
| 339 | Coldlight | cast_time(ms) | 2000 | 2.00s -> 2000ms | match | P99 wiki: Coldlight |
| 339 | Coldlight | recast_time(ms) | 6000 | 6.00s -> 6000ms | match | P99 wiki: Coldlight |
| 339 | Coldlight | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Coldlight |
| 340 | Disease Cloud | mana | 10 | 10 | match | P99 wiki: Disease Cloud |
| 340 | Disease Cloud | cast_time(ms) | 1500 | 1.50s -> 1500ms | match | P99 wiki: Disease Cloud |
| 340 | Disease Cloud | recast_time(ms) | 6000 | 6.00s -> 6000ms | match | P99 wiki: Disease Cloud |
| 340 | Disease Cloud | recovery_time(ms) | 2500 | 2.50s -> 2500ms | match | P99 wiki: Disease Cloud |
| 341 | Lifetap | mana | 9 | 9 | match | P99 wiki: Lifetap |
| 341 | Lifetap | cast_time(ms) | 1500 | 1.50s -> 1500ms | match | P99 wiki: Lifetap |
| 341 | Lifetap | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Lifetap |
| 341 | Lifetap | recovery_time(ms) | 2500 | 2.50s -> 2500ms | match | P99 wiki: Lifetap |
| 342 | Locate Corpse | mana | 5 | 5 | match | P99 wiki: Locate Corpse |
| 342 | Locate Corpse | cast_time(ms) | 1500 | 1.50s -> 1500ms | match | P99 wiki: Locate Corpse |
| 342 | Locate Corpse | recast_time(ms) | 3000 | 3.00s -> 3000ms | match | P99 wiki: Locate Corpse |
| 342 | Locate Corpse | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Locate Corpse |
| 343 | Siphon Strength | mana | 5 | 5 | match | P99 wiki: Siphon Strength |
| 343 | Siphon Strength | cast_time(ms) | 1500 | 1.50s -> 1500ms | match | P99 wiki: Siphon Strength |
| 343 | Siphon Strength | recast_time(ms) | 6000 | 6.00s -> 6000ms | match | P99 wiki: Siphon Strength |
| 343 | Siphon Strength | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Siphon Strength |
| 344 | Clinging Darkness | mana | 20 | 20 | match | P99 wiki: Clinging Darkness |
| 344 | Clinging Darkness | cast_time(ms) | 1750 | 1.75s -> 1750ms | match | P99 wiki: Clinging Darkness |
| 344 | Clinging Darkness | recast_time(ms) | 4000 | 4.00s -> 4000ms | match | P99 wiki: Clinging Darkness |
| 344 | Clinging Darkness | recovery_time(ms) | 2500 | 2.50s -> 2500ms | match | P99 wiki: Clinging Darkness |
| 347 | Numb the Dead | mana | 20 | 20 | match | P99 wiki: Numb the Dead |
| 347 | Numb the Dead | cast_time(ms) | 2000 | 2.00s -> 2000ms | match | P99 wiki: Numb the Dead |
| 347 | Numb the Dead | recast_time(ms) | 3000 | 3.00s -> 3000ms | match | P99 wiki: Numb the Dead |
| 347 | Numb the Dead | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Numb the Dead |
| 348 | Poison Bolt | mana | 30 | 30 | match | P99 wiki: Poison Bolt |
| 348 | Poison Bolt | cast_time(ms) | 1750 | 1.75s -> 1750ms | match | P99 wiki: Poison Bolt |
| 348 | Poison Bolt | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Poison Bolt |
| 348 | Poison Bolt | recovery_time(ms) | 2500 | 2.50s -> 2500ms | match | P99 wiki: Poison Bolt |
| 351 | Bone Walk | mana | 80 | 80 | match | P99 wiki: Bone Walk |
| 351 | Bone Walk | cast_time(ms) | 7000 | 7.00s -> 7000ms | match | P99 wiki: Bone Walk |
| 351 | Bone Walk | recast_time(ms) | 9500 | 9.50s -> 9500ms | match | P99 wiki: Bone Walk |
| 351 | Bone Walk | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Bone Walk |
| 352 | Deadeye | mana | 35 | 35 | match | P99 wiki: Deadeye |
| 352 | Deadeye | cast_time(ms) | 3000 | 3.00s -> 3000ms | match | P99 wiki: Deadeye |
| 352 | Deadeye | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Deadeye |
| 352 | Deadeye | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Deadeye |
| 353 | Mend Bones | mana | 25 | 25 | match | P99 wiki: Mend Bones |
| 353 | Mend Bones | cast_time(ms) | 3500 | 3.50s -> 3500ms | match | P99 wiki: Mend Bones |
| 353 | Mend Bones | recast_time(ms) | 6500 | 6.50s -> 6500ms | match | P99 wiki: Mend Bones |
| 353 | Mend Bones | recovery_time(ms) | 2500 | 2.50s -> 2500ms | match | P99 wiki: Mend Bones |
| 354 | Shadow Step | mana | 10 | 10 | match | P99 wiki: Shadow Step |
| 354 | Shadow Step | cast_time(ms) | 1000 | 1.00s -> 1000ms | match | P99 wiki: Shadow Step |
| 354 | Shadow Step | recast_time(ms) | 5000 | 5.00s -> 5000ms | match | P99 wiki: Shadow Step |
| 354 | Shadow Step | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Shadow Step |
| 355 | Engulfing Darkness | mana | 60 | 60 | match | P99 wiki: Engulfing Darkness |
| 355 | Engulfing Darkness | cast_time(ms) | 2450 | 2.45s -> 2450ms | match | P99 wiki: Engulfing Darkness |
| 355 | Engulfing Darkness | recast_time(ms) | 4000 | 4.00s -> 4000ms | match | P99 wiki: Engulfing Darkness |
| 355 | Engulfing Darkness | recovery_time(ms) | 2500 | 2.50s -> 2500ms | match | P99 wiki: Engulfing Darkness |
| 357 | Dark Empathy | mana | 20 | 20 | match | P99 wiki: Dark Empathy |
| 357 | Dark Empathy | cast_time(ms) | 4000 | 4.00s -> 4000ms | match | P99 wiki: Dark Empathy |
| 357 | Dark Empathy | recast_time(ms) | 7500 | 7.50s -> 7500ms | match | P99 wiki: Dark Empathy |
| 357 | Dark Empathy | recovery_time(ms) | 2500 | 2.50s -> 2500ms | match | P99 wiki: Dark Empathy |
| 358 | Impart Strength | mana | 15 | 15 | match | P99 wiki: Impart Strength |
| 358 | Impart Strength | cast_time(ms) | 4000 | 4.00s -> 4000ms | match | P99 wiki: Impart Strength |
| 358 | Impart Strength | recast_time(ms) | 5000 | 5.00s -> 5000ms | match | P99 wiki: Impart Strength |
| 358 | Impart Strength | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Impart Strength |
| 359 | Vampiric Embrace | mana | 30 | 30 | match | P99 wiki: Vampiric Embrace |
| 359 | Vampiric Embrace | cast_time(ms) | 3000 | 3.00s -> 3000ms | match | P99 wiki: Vampiric Embrace |
| 359 | Vampiric Embrace | recast_time(ms) | 6000 | 6.00s -> 6000ms | match | P99 wiki: Vampiric Embrace |
| 359 | Vampiric Embrace | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Vampiric Embrace |
| 360 | Heat Blood | mana | 72 | 72 | match | P99 wiki: Heat Blood |
| 360 | Heat Blood | cast_time(ms) | 2450 | 2.45s -> 2450ms | match | P99 wiki: Heat Blood |
| 360 | Heat Blood | recast_time(ms) | 4000 | 4.00s -> 4000ms | match | P99 wiki: Heat Blood |
| 360 | Heat Blood | recovery_time(ms) | 2500 | 2.50s -> 2500ms | match | P99 wiki: Heat Blood |
| 361 | Sight Graft | mana | 10 | 10 | match | P99 wiki: Sight Graft |
| 361 | Sight Graft | cast_time(ms) | 5000 | 5.00s -> 5000ms | match | P99 wiki: Sight Graft |
| 361 | Sight Graft | recast_time(ms) | 10000 | 10.00s -> 10000ms | match | P99 wiki: Sight Graft |
| 361 | Sight Graft | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Sight Graft |
| 362 | Convoke Shadow | mana | 120 | 120 | match | P99 wiki: Convoke Shadow |
| 362 | Convoke Shadow | cast_time(ms) | 8000 | 8.00s -> 8000ms | match | P99 wiki: Convoke Shadow |
| 362 | Convoke Shadow | recast_time(ms) | 11000 | 11.00s -> 11000ms | match | P99 wiki: Convoke Shadow |
| 362 | Convoke Shadow | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Convoke Shadow |
| 363 | Wave of Enfeeblement | mana | 40 | 40 | match | P99 wiki: Wave of Enfeeblement |
| 363 | Wave of Enfeeblement | cast_time(ms) | 2500 | 2.50s -> 2500ms | match | P99 wiki: Wave of Enfeeblement |
| 363 | Wave of Enfeeblement | recast_time(ms) | 5500 | 5.50s -> 5500ms | match | P99 wiki: Wave of Enfeeblement |
| 363 | Wave of Enfeeblement | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Wave of Enfeeblement |
| 365 | Infectious Cloud | mana | 78 | 78 | match | P99 wiki: Infectious Cloud |
| 365 | Infectious Cloud | cast_time(ms) | 2750 | 2.75s -> 2750ms | match | P99 wiki: Infectious Cloud |
| 365 | Infectious Cloud | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Infectious Cloud |
| 365 | Infectious Cloud | recovery_time(ms) | 2500 | 2.50s -> 2500ms | match | P99 wiki: Infectious Cloud |
| 366 | Feign Death | mana | 60 | 60 | match | P99 wiki: Feign Death |
| 366 | Feign Death | cast_time(ms) | 1500 | 1.50s -> 1500ms | match | P99 wiki: Feign Death |
| 366 | Feign Death | recast_time(ms) | 15000 | 15.00s -> 15000ms | match | P99 wiki: Feign Death |
| 366 | Feign Death | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Feign Death |
| 367 | Heart Flutter | mana | 80 | 80 | match | P99 wiki: Heart Flutter |
| 367 | Heart Flutter | cast_time(ms) | 2750 | 2.75s -> 2750ms | match | P99 wiki: Heart Flutter |
| 367 | Heart Flutter | recast_time(ms) | 7000 | 7.00s -> 7000ms | match | P99 wiki: Heart Flutter |
| 367 | Heart Flutter | recovery_time(ms) | 2500 | 2.50s -> 2500ms | match | P99 wiki: Heart Flutter |
| 368 | Spirit Armor | mana | 75 | 75 | match | P99 wiki: Spirit Armor |
| 368 | Spirit Armor | cast_time(ms) | 6000 | 6.00s -> 6000ms | match | P99 wiki: Spirit Armor |
| 368 | Spirit Armor | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Spirit Armor |
| 368 | Spirit Armor | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Spirit Armor |
| 369 | Hungry Earth | mana | 30 | 30 | match | P99 wiki: Hungry Earth |
| 369 | Hungry Earth | cast_time(ms) | 2000 | 2.00s -> 2000ms | match | P99 wiki: Hungry Earth |
| 369 | Hungry Earth | recast_time(ms) | 7500 | 7.50s -> 7500ms | match | P99 wiki: Hungry Earth |
| 369 | Hungry Earth | recovery_time(ms) | 2500 | 2.50s -> 2500ms | match | P99 wiki: Hungry Earth |
| 370 | Shadow Vortex | mana | 40 | 40 | match | P99 wiki: Shadow Vortex |
| 370 | Shadow Vortex | cast_time(ms) | 1500 | 1.50s -> 1500ms | match | P99 wiki: Shadow Vortex |
| 370 | Shadow Vortex | recast_time(ms) | 6000 | 6.00s -> 6000ms | match | P99 wiki: Shadow Vortex |
| 370 | Shadow Vortex | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Shadow Vortex |
| 371 | Voice Graft | mana | 10 | 10 | match | P99 wiki: Voice Graft |
| 371 | Voice Graft | cast_time(ms) | 6000 | 6.00s -> 6000ms | match | P99 wiki: Voice Graft |
| 371 | Voice Graft | recast_time(ms) | 12000 | 12.00s -> 12000ms | match | P99 wiki: Voice Graft |
| 371 | Voice Graft | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Voice Graft |
| 387 | Leatherskin | mana | 83 | 83 | match | P99 wiki: Leatherskin |
| 387 | Leatherskin | cast_time(ms) | 4000 | 4.00s -> 4000ms | match | P99 wiki: Leatherskin |
| 387 | Leatherskin | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Leatherskin |
| 387 | Leatherskin | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Leatherskin |
| 393 | Steelskin | mana | 149 | 149 | match | P99 wiki: Steelskin |
| 393 | Steelskin | cast_time(ms) | 4500 | 4.50s -> 4500ms | match | P99 wiki: Steelskin |
| 393 | Steelskin | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Steelskin |
| 393 | Steelskin | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Steelskin |
| 413 | Word of Shadow | mana | 85 | 85 | match | P99 wiki: Word of Shadow |
| 413 | Word of Shadow | cast_time(ms) | 2750 | 2.75s -> 2750ms | match | P99 wiki: Word of Shadow |
| 413 | Word of Shadow | recast_time(ms) | 9000 | 9.00s -> 9000ms | match | P99 wiki: Word of Shadow |
| 413 | Word of Shadow | recovery_time(ms) | 2500 | 2.50s -> 2500ms | match | P99 wiki: Word of Shadow |
| 414 | Word of Spirit | mana | 133 | 133 | match | P99 wiki: Word of Spirit |
| 414 | Word of Spirit | cast_time(ms) | 3500 | 3.50s -> 3500ms | match | P99 wiki: Word of Spirit |
| 414 | Word of Spirit | recast_time(ms) | 9000 | 9.00s -> 9000ms | match | P99 wiki: Word of Spirit |
| 414 | Word of Spirit | recovery_time(ms) | 2500 | 2.50s -> 2500ms | match | P99 wiki: Word of Spirit |
| 415 | Word of Souls | mana | 171 | 171 | match | P99 wiki: Word of Souls |
| 415 | Word of Souls | cast_time(ms) | 4600 | 4.60s -> 4600ms | match | P99 wiki: Word of Souls |
| 415 | Word of Souls | recast_time(ms) | 9000 | 9.00s -> 9000ms | match | P99 wiki: Word of Souls |
| 415 | Word of Souls | recovery_time(ms) | 2500 | 2.50s -> 2500ms | match | P99 wiki: Word of Souls |
| 435 | Venom of the Snake | mana | 160 | 160 | match | P99 wiki: Venom of the Snake |
| 435 | Venom of the Snake | cast_time(ms) | 4600 | 4.60s -> 4600ms | match | P99 wiki: Venom of the Snake |
| 435 | Venom of the Snake | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Venom of the Snake |
| 435 | Venom of the Snake | recovery_time(ms) | 2500 | 2.50s -> 2500ms | match | P99 wiki: Venom of the Snake |
| 440 | Animate Dead | mana | 200 | 200 | match | P99 wiki: Animate Dead |
| 440 | Animate Dead | cast_time(ms) | 10000 | 10.00s -> 10000ms | match | P99 wiki: Animate Dead |
| 440 | Animate Dead | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Animate Dead |
| 440 | Animate Dead | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Animate Dead |
| 441 | Summon Dead | mana | 290 | 290 | match | P99 wiki: Summon Dead |
| 441 | Summon Dead | cast_time(ms) | 12000 | 12.00s -> 12000ms | match | P99 wiki: Summon Dead |
| 441 | Summon Dead | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Summon Dead |
| 441 | Summon Dead | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Summon Dead |
| 442 | Malignant Dead | mana | 390 | 390 | match | P99 wiki: Malignant Dead |
| 442 | Malignant Dead | cast_time(ms) | 14000 | 14.00s -> 14000ms | match | P99 wiki: Malignant Dead |
| 442 | Malignant Dead | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Malignant Dead |
| 442 | Malignant Dead | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Malignant Dead |
| 444 | Renew Bones | mana | 125 | 125 | match | P99 wiki: Renew Bones |
| 444 | Renew Bones | cast_time(ms) | 4500 | 4.50s -> 4500ms | match | P99 wiki: Renew Bones |
| 444 | Renew Bones | recast_time(ms) | 7500 | 7.50s -> 7500ms | match | P99 wiki: Renew Bones |
| 444 | Renew Bones | recovery_time(ms) | 2500 | 2.50s -> 2500ms | match | P99 wiki: Renew Bones |
| 445 | Lifedraw | mana | 63 | 63 | match | P99 wiki: Lifedraw |
| 445 | Lifedraw | cast_time(ms) | 2450 | 2.45s -> 2450ms | match | P99 wiki: Lifedraw |
| 445 | Lifedraw | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Lifedraw |
| 445 | Lifedraw | recovery_time(ms) | 2500 | 2.50s -> 2500ms | match | P99 wiki: Lifedraw |
| 446 | Siphon Life | mana | 72 | 72 | match | P99 wiki: Siphon Life |
| 446 | Siphon Life | cast_time(ms) | 3100 | 3.10s -> 3100ms | match | P99 wiki: Siphon Life |
| 446 | Siphon Life | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Siphon Life |
| 446 | Siphon Life | recovery_time(ms) | 2500 | 2.50s -> 2500ms | match | P99 wiki: Siphon Life |
| 448 | Rest the Dead | mana | 75 | 75 | match | P99 wiki: Rest the Dead |
| 448 | Rest the Dead | cast_time(ms) | 3000 | 3.00s -> 3000ms | match | P99 wiki: Rest the Dead |
| 448 | Rest the Dead | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Rest the Dead |
| 448 | Rest the Dead | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Rest the Dead |
| 449 | Intensify Death | mana | 50 | 50 | match | P99 wiki: Intensify Death |
| 449 | Intensify Death | cast_time(ms) | 6000 | 6.00s -> 6000ms | match | P99 wiki: Intensify Death |
| 449 | Intensify Death | recast_time(ms) | 30000 | 30.00s -> 30000ms | match | P99 wiki: Intensify Death |
| 449 | Intensify Death | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Intensify Death |
| 451 | Boil Blood | mana | 150 | 150 | match | P99 wiki: Boil Blood |
| 451 | Boil Blood | cast_time(ms) | 4000 | 4.00s -> 4000ms | match | P99 wiki: Boil Blood |
| 451 | Boil Blood | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Boil Blood |
| 451 | Boil Blood | recovery_time(ms) | 2500 | 2.50s -> 2500ms | match | P99 wiki: Boil Blood |
| 452 | Dooming Darkness | mana | 120 | 120 | match | P99 wiki: Dooming Darkness |
| 452 | Dooming Darkness | cast_time(ms) | 4000 | 4.00s -> 4000ms | match | P99 wiki: Dooming Darkness |
| 452 | Dooming Darkness | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Dooming Darkness |
| 452 | Dooming Darkness | recovery_time(ms) | 2500 | 2.50s -> 2500ms | match | P99 wiki: Dooming Darkness |
| 454 | Vampiric Curse | mana | 144 | 144 | match | P99 wiki: Vampiric Curse |
| 454 | Vampiric Curse | cast_time(ms) | 4000 | 4.00s -> 4000ms | match | P99 wiki: Vampiric Curse |
| 454 | Vampiric Curse | recast_time(ms) | 10000 | 10.00s -> 10000ms | match | P99 wiki: Vampiric Curse |
| 454 | Vampiric Curse | recovery_time(ms) | 2500 | 2.50s -> 2500ms | match | P99 wiki: Vampiric Curse |
| 455 | Surge of Enfeeblement | mana | 100 | 100 | match | P99 wiki: Surge of Enfeeblement |
| 455 | Surge of Enfeeblement | cast_time(ms) | 3500 | 3.50s -> 3500ms | match | P99 wiki: Surge of Enfeeblement |
| 455 | Surge of Enfeeblement | recast_time(ms) | 5500 | 5.50s -> 5500ms | match | P99 wiki: Surge of Enfeeblement |
| 455 | Surge of Enfeeblement | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Surge of Enfeeblement |
| 491 | Leering Corpse | mana | 40 | 40 | match | P99 wiki: Leering Corpse |
| 491 | Leering Corpse | cast_time(ms) | 6000 | 6.00s -> 6000ms | match | P99 wiki: Leering Corpse |
| 491 | Leering Corpse | recast_time(ms) | 9500 | 9.50s -> 9500ms | match | P99 wiki: Leering Corpse |
| 491 | Leering Corpse | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Leering Corpse |
| 492 | Restless Bones | mana | 160 | 160 | match | P99 wiki: Restless Bones |
| 492 | Restless Bones | cast_time(ms) | 9000 | 9.00s -> 9000ms | match | P99 wiki: Restless Bones |
| 492 | Restless Bones | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Restless Bones |
| 492 | Restless Bones | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Restless Bones |
| 493 | Haunting Corpse | mana | 240 | 240 | match | P99 wiki: Haunting Corpse |
| 493 | Haunting Corpse | cast_time(ms) | 11000 | 11.00s -> 11000ms | match | P99 wiki: Haunting Corpse |
| 493 | Haunting Corpse | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Haunting Corpse |
| 493 | Haunting Corpse | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Haunting Corpse |
| 502 | Lifespike | mana | 18 | 18 | match | P99 wiki: Lifespike |
| 502 | Lifespike | cast_time(ms) | 1750 | 1.75s -> 1750ms | match | P99 wiki: Lifespike |
| 502 | Lifespike | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Lifespike |
| 502 | Lifespike | recovery_time(ms) | 2500 | 2.50s -> 2500ms | match | P99 wiki: Lifespike |
| 522 | Gather Shadows | mana | 35 | 35 | match | P99 wiki: Gather Shadows |
| 522 | Gather Shadows | cast_time(ms) | 5000 | 5.00s -> 5000ms | match | P99 wiki: Gather Shadows |
| 522 | Gather Shadows | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Gather Shadows |
| 522 | Gather Shadows | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Gather Shadows |
| 549 | Screaming Terror | mana | 60 | 60 | match | P99 wiki: Screaming Terror |
| 549 | Screaming Terror | cast_time(ms) | 2600 | 2.60s -> 2600ms | match | P99 wiki: Screaming Terror |
| 549 | Screaming Terror | recast_time(ms) | 6500 | 6.50s -> 6500ms | match | P99 wiki: Screaming Terror |
| 549 | Screaming Terror | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Screaming Terror |
| 641 | Dark Pact | mana | 5 | 5 | match | P99 wiki: Dark Pact |
| 641 | Dark Pact | cast_time(ms) | 3000 | 3.00s -> 3000ms | match | P99 wiki: Dark Pact |
| 641 | Dark Pact | recast_time(ms) | 6000 | 6.00s -> 6000ms | match | P99 wiki: Dark Pact |
| 641 | Dark Pact | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Dark Pact |
| 642 | Allure of Death | mana | 5 | 5 | match | P99 wiki: Allure of Death |
| 642 | Allure of Death | cast_time(ms) | 3000 | 3.00s -> 3000ms | match | P99 wiki: Allure of Death |
| 642 | Allure of Death | recast_time(ms) | 6000 | 6.00s -> 6000ms | match | P99 wiki: Allure of Death |
| 642 | Allure of Death | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Allure of Death |
| 643 | Call of Bones | mana | 5 | 5 | match | P99 wiki: Call of Bones |
| 643 | Call of Bones | cast_time(ms) | 3000 | 3.00s -> 3000ms | match | P99 wiki: Call of Bones |
| 643 | Call of Bones | recast_time(ms) | 6000 | 6.00s -> 6000ms | match | P99 wiki: Call of Bones |
| 643 | Call of Bones | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Call of Bones |
| 698 | Track Corpse | mana | 15 | 15 | match | P99 wiki: Track Corpse |
| 698 | Track Corpse | cast_time(ms) | 1500 | 1.50s -> 1500ms | match | P99 wiki: Track Corpse |
| 698 | Track Corpse | recast_time(ms) | 3000 | 3.00s -> 3000ms | match | P99 wiki: Track Corpse |
| 698 | Track Corpse | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Track Corpse |
| 1412 | Chilling Embrace | mana | 200 | 200 | match | P99 wiki: Chilling Embrace |
| 1412 | Chilling Embrace | cast_time(ms) | 5500 | 5.50s -> 5500ms | match | P99 wiki: Chilling Embrace |
| 1412 | Chilling Embrace | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Chilling Embrace |
| 1412 | Chilling Embrace | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Chilling Embrace |
| 1415 | Torbas Acid Blast | mana | 130 | 130 | match | P99 wiki: Torbas' Acid Blast (redirect) |
| 1415 | Torbas Acid Blast | cast_time(ms) | 4000 | 4.00s -> 4000ms | match | P99 wiki: Torbas' Acid Blast (redirect) |
| 1415 | Torbas Acid Blast | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Torbas' Acid Blast (redirect) |
| 1415 | Torbas Acid Blast | recovery_time(ms) | 2500 | 2.50s -> 2500ms | match | P99 wiki: Torbas' Acid Blast (redirect) |
| 1509 | Leach | mana | 72 | 72 | match | P99 wiki: Leach |
| 1509 | Leach | cast_time(ms) | 2400 | 2.40s -> 2400ms | match | P99 wiki: Leach |
| 1509 | Leach | recast_time(ms) | 10000 | 10.00s -> 10000ms | match | P99 wiki: Leach |
| 1509 | Leach | recovery_time(ms) | 2500 | 2.50s -> 2500ms | match | P99 wiki: Leach |
| 1510 | Shadow Compact | mana | 10 | 10 | match | P99 wiki: Shadow Compact |
| 1510 | Shadow Compact | cast_time(ms) | 2000 | 2.00s -> 2000ms | match | P99 wiki: Shadow Compact |
| 1510 | Shadow Compact | recast_time(ms) | 12000 | 12.00s -> 12000ms | match | P99 wiki: Shadow Compact |
| 1510 | Shadow Compact | recovery_time(ms) | 2500 | 2.50s -> 2500ms | match | P99 wiki: Shadow Compact |
| 1511 | Scent of Dusk | mana | 50 | 50 | match | P99 wiki: Scent of Dusk |
| 1511 | Scent of Dusk | cast_time(ms) | 3000 | 3.00s -> 3000ms | match | P99 wiki: Scent of Dusk |
| 1511 | Scent of Dusk | recast_time(ms) | 6000 | 6.00s -> 6000ms | match | P99 wiki: Scent of Dusk |
| 1511 | Scent of Dusk | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Scent of Dusk |
| 1512 | Scent of Shadow | mana | 100 | 100 | match | P99 wiki: Scent of Shadow |
| 1512 | Scent of Shadow | cast_time(ms) | 3000 | 3.00s -> 3000ms | match | P99 wiki: Scent of Shadow |
| 1512 | Scent of Shadow | recast_time(ms) | 6000 | 6.00s -> 6000ms | match | P99 wiki: Scent of Shadow |
| 1512 | Scent of Shadow | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Scent of Shadow |
| 1513 | Scent of Darkness | mana | 150 | 150 | match | P99 wiki: Scent of Darkness |
| 1513 | Scent of Darkness | cast_time(ms) | 3000 | 3.00s -> 3000ms | match | P99 wiki: Scent of Darkness |
| 1513 | Scent of Darkness | recast_time(ms) | 6000 | 6.00s -> 6000ms | match | P99 wiki: Scent of Darkness |
| 1513 | Scent of Darkness | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Scent of Darkness |
| 1514 | Rapacious Subversion | mana | 200 | 200 | match | P99 wiki: Rapacious Subversion |
| 1514 | Rapacious Subversion | cast_time(ms) | 3000 | 3.00s -> 3000ms | match | P99 wiki: Rapacious Subversion |
| 1514 | Rapacious Subversion | recast_time(ms) | 8000 | 8.00s -> 8000ms | match | P99 wiki: Rapacious Subversion |
| 1514 | Rapacious Subversion | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Rapacious Subversion |
| 8478 | Summon Corpse | mana | 700 | 700 | match | P99 wiki: Summon Corpse |
| 8478 | Summon Corpse | cast_time(ms) | 5000 | 5.00s -> 5000ms | match | P99 wiki: Summon Corpse |
| 8478 | Summon Corpse | recast_time(ms) | 12000 | 12.00s -> 12000ms | match | P99 wiki: Summon Corpse |
| 8478 | Summon Corpse | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Summon Corpse |
| 8504 | Resist Disease | mana | 50 | 50 | match | P99 wiki: Resist Disease |
| 8504 | Resist Disease | cast_time(ms) | 4500 | 4.50s -> 4500ms | match | P99 wiki: Resist Disease |
| 8504 | Resist Disease | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Resist Disease |
| 8504 | Resist Disease | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Resist Disease |
| 8545 | Expel Undead | mana | 130 | 130 | match | P99 wiki: Expel Undead |
| 8545 | Expel Undead | cast_time(ms) | 4300 | 4.30s -> 4300ms | match | P99 wiki: Expel Undead |
| 8545 | Expel Undead | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Expel Undead |
| 8545 | Expel Undead | recovery_time(ms) | 2500 | 2.50s -> 2500ms | match | P99 wiki: Expel Undead |
| 8572 | Banshee Aura | mana | 60 | 60 | match | P99 wiki: Banshee Aura |
| 8572 | Banshee Aura | cast_time(ms) | 5000 | 5.00s -> 5000ms | match | P99 wiki: Banshee Aura |
| 8572 | Banshee Aura | recast_time(ms) | 9500 | 9.50s -> 9500ms | match | P99 wiki: Banshee Aura |
| 8572 | Banshee Aura | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Banshee Aura |
| 8575 | Augment Death | mana | 200 | 200 | match | P99 wiki: Augment Death |
| 8575 | Augment Death | cast_time(ms) | 6000 | 6.00s -> 6000ms | match | P99 wiki: Augment Death |
| 8575 | Augment Death | recast_time(ms) | 30000 | 30.00s -> 30000ms | match | P99 wiki: Augment Death |
| 8575 | Augment Death | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Augment Death |
| 8636 | Spirit Tap | mana | 144 | 144 | match | P99 wiki: Spirit Tap |
| 8636 | Spirit Tap | cast_time(ms) | 4000 | 4.00s -> 4000ms | match | P99 wiki: Spirit Tap |
| 8636 | Spirit Tap | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Spirit Tap |
| 8636 | Spirit Tap | recovery_time(ms) | 2500 | 2.50s -> 2500ms | match | P99 wiki: Spirit Tap |
| 8637 | Drain Spirit | mana | 189 | 189 | match | P99 wiki: Drain Spirit |
| 8637 | Drain Spirit | cast_time(ms) | 5300 | 5.30s -> 5300ms | match | P99 wiki: Drain Spirit |
| 8637 | Drain Spirit | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Drain Spirit |
| 8637 | Drain Spirit | recovery_time(ms) | 2500 | 2.50s -> 2500ms | match | P99 wiki: Drain Spirit |
| 8639 | Grim Aura | mana | 25 | 25 | match | P99 wiki: Grim Aura |
| 8639 | Grim Aura | cast_time(ms) | 3000 | 3.00s -> 3000ms | match | P99 wiki: Grim Aura |
| 8639 | Grim Aura | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Grim Aura |
| 8639 | Grim Aura | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Grim Aura |
| 8643 | Endure Cold | mana | 20 | 20 | match | P99 wiki: Endure Cold |
| 8643 | Endure Cold | cast_time(ms) | 2500 | 2.50s -> 2500ms | match | P99 wiki: Endure Cold |
| 8643 | Endure Cold | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Endure Cold |
| 8643 | Endure Cold | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Endure Cold |
| 8648 | Resist Cold | mana | 50 | 50 | match | P99 wiki: Resist Cold |
| 8648 | Resist Cold | cast_time(ms) | 4500 | 4.50s -> 4500ms | match | P99 wiki: Resist Cold |
| 8648 | Resist Cold | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Resist Cold |
| 8648 | Resist Cold | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Resist Cold |
| 8657 | Shieldskin | mana | 41 | 41 | match | P99 wiki: Shieldskin |
| 8657 | Shieldskin | cast_time(ms) | 3500 | 3.50s -> 3500ms | match | P99 wiki: Shieldskin |
| 8657 | Shieldskin | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Shieldskin |
| 8657 | Shieldskin | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Shieldskin |
| 8659 | Invoke Shadow | mana | 340 | 340 | match | P99 wiki: Invoke Shadow |
| 8659 | Invoke Shadow | cast_time(ms) | 13000 | 13.00s -> 13000ms | match | P99 wiki: Invoke Shadow |
| 8659 | Invoke Shadow | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Invoke Shadow |
| 8659 | Invoke Shadow | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Invoke Shadow |
| 8660 | Breath of the Dead | mana | 45 | 45 | match | P99 wiki: Breath of the Dead |
| 8660 | Breath of the Dead | cast_time(ms) | 2500 | 2.50s -> 2500ms | match | P99 wiki: Breath of the Dead |
| 8660 | Breath of the Dead | recast_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Breath of the Dead |
| 8660 | Breath of the Dead | recovery_time(ms) | 2250 | 2.25s -> 2250ms | match | P99 wiki: Breath of the Dead |

## Buff duration comparison (all 108 spells)

`buffduration` is in ticks (1 tick = 6 seconds); "Instant" spells have a
blank/null `buffduration` in the DB, which is treated as a match against a
wiki `duration = Instant`.

| id | name | DB ticks | wiki duration | verdict | citation |
|---|---|---|---|---|---|
| 31 | Scourge | 21 | 21 ticks (2min 6sec) | match | P99 wiki |
| 35 | Bind Affinity | — | Instant | match | P99 wiki |
| 36 | Gate | — | Instant | match | P99 wiki |
| 48 | Cancel Magic | — | Instant | match | P99 wiki |
| 49 | Nullify Magic | — | Instant | match | P99 wiki |
| 59 | Panic the Dead | 9 | 9 ticks | match | P99 wiki |
| 65 | Major Shielding | 450 | 45 minutes | match | P99 wiki |
| 66 | Greater Shielding | 540 | 54 minutes | match | P99 wiki |
| 90 | Shadow Sight | 270 | 27 minutes | match | P99 wiki |
| 96 | Counteract Disease | — | Instant | match | P99 wiki |
| 117 | Dismiss Undead | — | Instant | match | P99 wiki |
| 127 | Invoke Fear | 7 | 42 seconds (7 ticks) | match | P99 wiki |
| 196 | Dominate Undead | 190 | 7 min @L20 to 20.5 min @L65 | match — see level-60-cap note (linear extrapolation of the wiki's own growth rate lands on 190 ticks at L60) | P99 wiki |
| 197 | Beguile Undead | 190 | 11.2 min @L34 to 20.5 min @L65 | match — see level-60-cap note | P99 wiki |
| 199 | Harmshield | 3 | 3 ticks | match | P99 wiki |
| 204 | Shock of Poison | — | Instant | match | P99 wiki |
| 205 | True North | — | Instant | match | P99 wiki |
| 209 | Spook the Dead | 3 | 1 tick @L1 to 3 ticks @L5 | match | P99 wiki |
| 213 | Cure Disease | — | Instant | match | P99 wiki |
| 218 | Ward Undead | — | Instant | match | P99 wiki |
| 221 | Sense the Dead | — | Instant | match | P99 wiki |
| 226 | Endure Disease | 270 | 27 minutes | match | P99 wiki |
| 229 | Fear | 3 | 18 seconds | match | P99 wiki |
| 230 | Root | 8 | 2 ticks @L4 to 8 ticks @L14 | match | P99 wiki |
| 233 | Expulse Undead | — | Instant | match | P99 wiki |
| 235 | Invisibility versus Undead | 270 | 3 min @L1 to 27 min @L9 | match | P99 wiki |
| 246 | Lesser Shielding | 270 | 24 min @L8 to 27 min @L9 | match | P99 wiki |
| 288 | Minor Shielding | 270 | 27 minutes | match | P99 wiki |
| 305 | Identify | — | Instant | match | P99 wiki |
| 309 | Shielding | 360 | 36 minutes | match | P99 wiki |
| 331 | Reclaim Energy | — | Instant | match | P99 wiki |
| 338 | Cavorting Bones | — | Instant | match | P99 wiki |
| 339 | Coldlight | — | Instant | match | P99 wiki |
| 340 | Disease Cloud | 60 | 3 min @L1 to 6 min @L2 | match | P99 wiki |
| 341 | Lifetap | — | Instant | match | P99 wiki |
| 342 | Locate Corpse | — | Instant | match | P99 wiki |
| 343 | Siphon Strength | 60 | 3 min @L1 to 6 min @L2 | match | P99 wiki |
| 344 | Clinging Darkness | 6 | 2 ticks @L4 to 6 ticks @L12 | match (structured duration field; page's own prose text is internally inconsistent, saying "8 ticks @L16") | P99 wiki |
| 347 | Numb the Dead | 20 | 1.4 min @L4 to 2 min @L10 | match | P99 wiki |
| 348 | Poison Bolt | 7 | 2 ticks @L4 to 7 ticks @L12 | match | P99 wiki |
| 351 | Bone Walk | — | Instant | match | P99 wiki |
| 352 | Deadeye | 270 | 24 min @L8 to 27 min @L9 | match | P99 wiki |
| 353 | Mend Bones | — | Instant | match | P99 wiki |
| 354 | Shadow Step | — | Instant | match | P99 wiki |
| 355 | Engulfing Darkness | 10 | 11 ticks @L22 | **mismatch** (DB 1 tick short) | P99 wiki |
| 357 | Dark Empathy | — | Instant | match | P99 wiki |
| 358 | Impart Strength | 60 | 6 minutes | match | P99 wiki |
| 359 | Vampiric Embrace | 70 | 1.8 min @L8 to 7 min @L60 | match | P99 wiki |
| 360 | Heat Blood | 10 | 6 ticks @L12 to 1 min (10 ticks) @L20 | match | P99 wiki |
| 361 | Sight Graft | 270 | 27 minutes | match | P99 wiki |
| 362 | Convoke Shadow | — | Instant | match | P99 wiki |
| 363 | Wave of Enfeeblement | 40 | 2.2 min @L12 to 4 min @L30 | match | P99 wiki |
| 365 | Infectious Cloud | 21 | 2.1 minutes | match | P99 wiki |
| 366 | Feign Death | — | Instant | match | P99 wiki |
| 367 | Heart Flutter | 12 | 8 ticks @L16 to 1.2 min (12 ticks) @L24 | match | P99 wiki |
| 368 | Spirit Armor | 360 | 36 minutes | match | P99 wiki |
| 369 | Hungry Earth | 8 | 8 ticks | match | P99 wiki |
| 370 | Shadow Vortex | 70 | 3 min @L20 to 7.5 min @L65 | match — see level-60-cap note | P99 wiki |
| 371 | Voice Graft | 270 | 27 minutes | match | P99 wiki |
| 387 | Leatherskin | 540 | 54 minutes | match | P99 wiki |
| 393 | Steelskin | 720 | 1 hour 12 minutes | match | P99 wiki |
| 413 | Word of Shadow | — | Instant | match | P99 wiki |
| 414 | Word of Spirit | — | Instant | match | P99 wiki |
| 415 | Word of Souls | — | Instant | match | P99 wiki |
| 435 | Venom of the Snake | 7 | 7 ticks @L34 to 8 ticks @L36 | **mismatch (medium confidence)** — DB sits at the range's bottom, not top; both example levels (34, 36) are well under this server's level-60 cap so the level-cap explanation doesn't apply here | P99 wiki |
| 440 | Animate Dead | — | Instant | match | P99 wiki |
| 441 | Summon Dead | — | Instant | match | P99 wiki |
| 442 | Malignant Dead | — | Instant | match | P99 wiki |
| 444 | Renew Bones | — | Instant | match | P99 wiki |
| 445 | Lifedraw | — | Instant | match | P99 wiki |
| 446 | Siphon Life | — | Instant | match | P99 wiki |
| 448 | Rest the Dead | 30 | 3 minutes | match | P99 wiki |
| 449 | Intensify Death | 70 | 3.4 min @L24 to 7.5 min @L65 | match — see level-60-cap note | P99 wiki |
| 451 | Boil Blood | 21 | 16 ticks @L29 to 21 ticks @L42 | match | P99 wiki |
| 452 | Dooming Darkness | 15 | 1.5 min @L29 to 1.6 min (16 ticks) @L30 | **mismatch** (wiki's own total-damage statement — 20/tick × 16 = 320 — implies 16 ticks, not 15) | P99 wiki |
| 454 | Vampiric Curse | 9 | 9 ticks | match | P99 wiki |
| 455 | Surge of Enfeeblement | 60 | 6 minutes | match | P99 wiki |
| 491 | Leering Corpse | — | Instant | match | P99 wiki |
| 492 | Restless Bones | — | Instant | match | P99 wiki |
| 493 | Haunting Corpse | — | Instant | match | P99 wiki |
| 502 | Lifespike | — | Instant | match | P99 wiki |
| 522 | Gather Shadows | 200 | 20 minutes | match | P99 wiki |
| 549 | Screaming Terror | 3 | 3 ticks | match | P99 wiki |
| 641 | Dark Pact | 70 | 1.8 min @L8 to 7 min @L60 | match | P99 wiki |
| 642 | Allure of Death | 130 | 5 min @L20 to 13 min @L60 | match | P99 wiki |
| 643 | Call of Bones | 190 | "11:12 + 18sec per level above 34" | match — manual calc: 11.2 min base + 18s × (60−34) levels = 19.0 min = 190 ticks at this server's L60 cap | P99 wiki |
| 698 | Track Corpse | 120 | 12 minutes | match | P99 wiki |
| 1412 | Chilling Embrace | 15 | 16 ticks | **mismatch** (wiki's own total-damage statement — 40/tick × 16 = 640 — implies 16 ticks, not 15) | P99 wiki |
| 1415 | Torbas Acid Blast | — | Instant | match | P99 wiki |
| 1509 | Leach | 9 | 7 ticks @L12 to 9 ticks @L15 | match | P99 wiki |
| 1510 | Shadow Compact | 4 | 24 seconds (4 ticks) | match | P99 wiki |
| 1511 | Scent of Dusk | 130 | 3.4 min @L12 to 14 min @L65 | match — see level-60-cap note | P99 wiki |
| 1512 | Scent of Shadow | 130 | 5.8 min @L24 to 14 min @L65 | match — see level-60-cap note | P99 wiki |
| 1513 | Scent of Darkness | 130 | 8.8 min @L39 to 14 min @L65 | match — see level-60-cap note | P99 wiki |
| 1514 | Rapacious Subversion | — | Instant | match | P99 wiki |
| 8478 | Summon Corpse | — | Instant | match | P99 wiki |
| 8504 | Resist Disease | 360 | 36 minutes | match | P99 wiki |
| 8545 | Expel Undead | — | Instant | match | P99 wiki |
| 8572 | Banshee Aura | 90 | 4.2 min @L16 to 9 min @L40 | match | P99 wiki |
| 8575 | Augment Death | 150 | 12.7 min @L39 to 15 min @L47 | match | P99 wiki |
| 8636 | Spirit Tap | — | Instant | match | P99 wiki |
| 8637 | Drain Spirit | — | Instant | match | P99 wiki |
| 8639 | Grim Aura | 270 | 12 min @L4 to 27 min @L9 | match | P99 wiki |
| 8643 | Endure Cold | 270 | 3 min @L1 to 27 min @L9 | match | P99 wiki |
| 8648 | Resist Cold | 360 | 36 minutes | match | P99 wiki |
| 8657 | Shieldskin | 360 | 36 minutes | match | P99 wiki |
| 8659 | Invoke Shadow | — | Instant | match | P99 wiki |
| 8660 | Breath of the Dead | 270 | 27 minutes | match | P99 wiki |

## Magnitude comparison (damage / heal / stat effects with a checkable wiki number)

AC-granting effects are excluded from this table (see methodology note 2).
Pet combat stats (e.g. Convoke Shadow's summoned skeleton damage) are outside
`spells_new`'s spell-effect fields and are not checked here.

| id | name | field | DB value | wiki value | verdict | citation |
|---|---|---|---|---|---|---|
| 31 | Scourge | disease counter | 4 | Increase Disease Counter by 4 | match | P99 wiki |
| 31 | Scourge | initial hit (once) | -40 | 40 damage initially | match | P99 wiki |
| 31 | Scourge | DoT tick | -24 | 24 damage/tick | match | P99 wiki |
| 65 | Major Shielding | max HP cap | 75 | 75 (L30 cap) | match | P99 wiki |
| 66 | Greater Shielding | max HP cap | 100 | 100 (L40 cap) | match | P99 wiki |
| 96 | Counteract Disease | disease counter (2 slots, -4 each) | -8 (sum) | Decrease Disease Counter by 8 | match (two -4 SE_DiseaseCounter slots sum to the wiki's stated 8) | P99 wiki |
| 117 | Dismiss Undead | dmg cap | 162 | 162 (L35 cap) | match | P99 wiki |
| 204 | Shock of Poison | dmg cap | 160 | 160 (L29 cap) | match | P99 wiki |
| 218 | Ward Undead | dmg cap | 41 | 41 (L11 cap) | match | P99 wiki |
| 226 | Endure Disease | resist cap | 20 | 20 (L10 cap) | match | P99 wiki |
| 233 | Expulse Undead | dmg cap | 94 | 94 (L20 cap) | match | P99 wiki |
| 246 | Lesser Shielding | max HP cap | 30 | 30 (L18 cap) | match | P99 wiki |
| 288 | Minor Shielding | max HP cap | 10 | 10 (L5 cap) | match | P99 wiki |
| 309 | Shielding | max HP cap | 50 | 50 (L20 cap) | match | P99 wiki |
| 340 | Disease Cloud | disease counter / initial / tick | 1 / -5 / -1 | 1 / 5 initial / 1 per tick | match | P99 wiki |
| 341 | Lifetap | dmg cap | 5 | 5 (L4 cap) | match | P99 wiki |
| 343 | Siphon Strength | STR decrease cap | 10 | 10 (L10 cap) | match | P99 wiki |
| 344 | Clinging Darkness | tick dmg / snare cap | -5 / -30% | 5/tick / 30% (L10 cap) | match | P99 wiki |
| 348 | Poison Bolt | poison counter / initial / tick | 1 / -6 / -5 | 1 / 6 initial / 5 per tick | match | P99 wiki |
| 353 | Mend Bones | heal cap | 50 | 50 (L25 cap) | match | P99 wiki |
| 355 | Engulfing Darkness | tick dmg / snare cap | -11 / -40% | 11/tick / 40% | match | P99 wiki |
| 358 | Impart Strength | STR | 10 | Increase STR by 10 | match | P99 wiki |
| 360 | Heat Blood | tick dmg | -17 | 17/tick | match | P99 wiki |
| 363 | Wave of Enfeeblement | STR decrease cap | 15 | 15 (L20 cap) | match | P99 wiki |
| 365 | Infectious Cloud | disease counter / initial / tick | 1 / -20 / -5 | 1 / 20 initial / 5 per tick | match | P99 wiki |
| 367 | Heart Flutter | STR decrease cap / tick dmg | 20 / -12 | 20 (L26 cap) / 12 per tick | match | P99 wiki |
| 369 | Hungry Earth | HP cost when cast | -10 | 26 (L16) to 75 (L65) | **mismatch (medium confidence)** — DB value doesn't land near either end of the wiki's stated range, even after accounting for the level-60 cap | P99 wiki |
| 387 | Leatherskin | absorb cap | 118 | 118 (structured slot value; page's own prose is stale at "47") | match | P99 wiki |
| 393 | Steelskin | absorb cap | 230 | 132 to 230 | match | P99 wiki |
| 413 | Word of Shadow | dmg cap | 58 | 58 (L25 cap) | match | P99 wiki |
| 414 | Word of Spirit | dmg cap | 104 | 104 (structured slot; prose says "91 to 103") | match | P99 wiki |
| 415 | Word of Souls | dmg cap | 155 | 155 (L42 cap) | match | P99 wiki |
| 435 | Venom of the Snake | poison counter / initial / tick | 7 / -40 / -59 | 7 / 40 initial / 59 per tick | match (duration flagged separately above) | P99 wiki |
| 444 | Renew Bones | heal cap | 175 | 175 (L50 cap) | match | P99 wiki |
| 445 | Lifedraw | dmg cap | 45 | 45 (L18 cap) | match | P99 wiki |
| 446 | Siphon Life | dmg cap | 75 | 75 (L25 cap) | match | P99 wiki |
| 449 | Intensify Death | atk speed cap / STR cap | 130 (=100+30%) / 33 | +30% (L40 cap) / 33 (L52 cap) | match | P99 wiki |
| 451 | Boil Blood | tick dmg | -24 | 24/tick | match | P99 wiki |
| 452 | Dooming Darkness | tick dmg / snare cap | -20 / -60% | 20/tick / 60% | match (duration flagged separately above) | P99 wiki |
| 454 | Vampiric Curse | tick dmg (drain+transfer) | -21 | 21/tick | match | P99 wiki |
| 455 | Surge of Enfeeblement | STR decrease cap | 30 | 30 (L50 cap) | match | P99 wiki |
| 502 | Lifespike | dmg cap | 11 | 11 (L8 cap) | match | P99 wiki |
| 549 | Screaming Terror | mesmerize level cap | 55 | "up to level 55" | match | P99 wiki |
| 641 | Dark Pact | mana gain/tick | 2 | Increase mana by 2 per tick | match | P99 wiki |
| 641 | Dark Pact | **HP drain/tick (slot 7)** | **-4** | Decrease hitpoints by 2 per tick | **mismatch** | P99 wiki |
| 642 | Allure of Death | mana gain/tick | 4 | Increase Mana by 4 per tick | match | P99 wiki |
| 642 | Allure of Death | **HP drain/tick (slot 7)** | **-8** | Decrease Hitpoints by 5 per tick | **mismatch** | P99 wiki |
| 643 | Call of Bones | illusion / mana gain/tick | 60 / 8 | Illusion: 60 / 8 per tick | match | P99 wiki |
| 643 | Call of Bones | **HP drain/tick (slot 7)** | **-16** | Decrease Hitpoints by 10 per tick | **mismatch** | P99 wiki |
| 1412 | Chilling Embrace | tick dmg | -40 | 40/tick | match | P99 wiki |
| 1412 | Chilling Embrace | **poison counter effect** | **absent** (no `SE_PoisonCounter` in any of the spell's 4 effect slots — only HP-drain and inert padding) | Increase Poison Counter by 3 | **mismatch — effect missing entirely** | P99 wiki |
| 1415 | Torbas Acid Blast | dmg cap | 220 | 220 (L39 cap) | match | P99 wiki (redirect page) |
| 1511 | Scent of Dusk | poison counter / resist decrease cap | 1 / -9 | 1 / 9 (L16 cap) | match | P99 wiki |
| 1512 | Scent of Shadow | poison counter / resist decrease cap | 4 / -18 | 4 / 18 (L32 cap) | match | P99 wiki |
| 1513 | Scent of Darkness | poison counter / resist decrease cap | 9 / -27 | 9 / 27 (L44 cap) | match | P99 wiki |
| 1514 | Rapacious Subversion | mana gain | 60 | Increase Mana by 60 | match | P99 wiki |
| 8504 | Resist Disease | resist cap | 40 | Increase Disease Resist by 40 | match | P99 wiki |
| 8545 | Expel Undead | dmg cap | 273 | 273 (L38 cap) | match | P99 wiki |
| 8572 | Banshee Aura | damage shield cap | 12 | 12 (L54 cap) | match | P99 wiki |
| 8575 | Augment Death | atk speed cap / STR cap | 155 (=100+55%) / 45 | +55% (L45 cap) / 45 (L50 cap) | match | P99 wiki |
| 8636 | Spirit Tap | dmg cap | 150 | 150 (L35 cap) | match | P99 wiki |
| 8637 | Drain Spirit | dmg cap | 226 | 226 (L44 cap) | match | P99 wiki |
| 8639 | Grim Aura | ATK cap | 10 | 10 (L10 cap) | match | P99 wiki |
| 8643 | Endure Cold | resist cap | 20 | 20 (L10 cap) | match | P99 wiki |
| 8648 | Resist Cold | resist cap | 40 | 40 (L25 cap) | match | P99 wiki |
| 8657 | Shieldskin | absorb cap | 55 | 9 to 55 | match | P99 wiki |

## Caveats for the human reviewer

- The Venom of the Snake and Hungry Earth findings are flagged at **medium
  confidence** — the numbers genuinely don't line up with the wiki, but I
  could not fully rule out an alternate duration/scaling formula behavior
  specific to those effect types without deeper EQEmu source review than
  this pass covered. Worth a second look before any correction is made.
- The level-60-cap explanation for the 8 "not actually a mismatch" spells
  is based on linear extrapolation of the wiki's own stated growth rate
  between its two example levels; it fit exactly in all 8 cases, but it's
  still an inference rather than something the wiki states outright.
- This pass focused on `spells_new` effect/timer fields only. It did not
  check pet stats (npc_types) for the summoned-skeleton spells, proc rates,
  or pet AA-style behavior described qualitatively on some wiki pages.
