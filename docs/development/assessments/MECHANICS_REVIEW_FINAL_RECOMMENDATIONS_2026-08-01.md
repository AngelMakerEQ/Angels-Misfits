# Mechanics Review — Final Recommendations

**Review date:** 2026-08-01  
**Reviewed:** the pulled revisions to `CURRENT_STATE.md`, `PROJECT_STATUS.md`,
`ADR-004_CLASSIC_SPELLS.md`, and `MECHANICS_REVIEW.md`; all ADRs; and the live
read-only Angels Misfits database.

## Outcome

The revised priority order is sound with two adjustments:

1. Complete the currently scoped zone-architecture review first, but restrict
   it to the zones whose geometry was actually overridden in ADR-008. Do not
   delay all mechanics work for a world-wide geometry audit.
2. Before resuming the mechanics sweep, perform one small **era-containment
   cleanup**. It closes concrete ADR-001/ADR-009 gaps with far less effort than
   another broad mechanics investigation.

No combat, casting, regeneration, or spell-data rule should be changed merely
because it is unverified. The next work should establish the current runtime
behavior with a reproducible test, then change it only where a strong
classic-era target and an actual discrepancy both exist.

## Assessment of the Pulled Revisions

### Accepted

- `ADR-004_CLASSIC_SPELLS.md` now correctly declares its status as
  **Implemented**. Its implementation section already provides the necessary
  evidence for the 37,729-row spell migration.
- `PROJECT_STATUS.md` and `CURRENT_STATE.md` correctly make the client/server
  zone-geometry alignment the immediate focus and place mechanics second.
- The rewritten `MECHANICS_REVIEW.md` priority order is substantially better
  than the former ZEM-first list. HP/mana behavior, spell interruption,
  recast/recovery enforcement, component handling, critical-hit chance, and
  special attacks are all more player-visible than a speculative world-wide
  ZEM correction.
- Re-opening **runtime enforcement** for recast/recovery and components is
  appropriate. ADR-004 proves that the stored spell fields are classic; it
  does not itself prove every current server-code path consumes or enforces
  them correctly.

### Required documentation adjustments

1. Rename the first rewritten section to **Character HP and regeneration**.
   STA-to-HP is foundational character-stat calculation, not regeneration.
2. Replace statements such as “never confirmed against our actual database”
   with “runtime implementation not independently verified.” ADR-004 already
   records that `base_data` and the complete `skill_caps` dataset matched the
   classic reference; the open question is source/runtime behavior.
3. Update the older WIP passages that still say the NPC leash is enabled or
   awaiting a decision. Live ruleset 1 has
   `Aggro:NPCAggroMaxDistanceEnabled = false`, matching the current status
   documents.
4. Mark ZEM **deprioritized / intentionally addressed through base XP pacing**
   in its original WIP section. Leaving it red/actionable there conflicts with
   `PROJECT_STATUS.md` and risks reviving work the project lead deliberately
   set aside.
5. Reconcile the character-level statements in `PROJECT_STATUS.md`. The
   document presently refers to six characters at level 10 or below while a
   recent revision/history records a level-40 Necromancer and six characters
   adjusted to level 12. Use the live character list as the authority.

## Era-containment cleanup — do this before the next mechanics pass

### 1. Disable all Beastlord and Berserker spell grants

This is the only confirmed live data conflict with the stated Velious class
scope. ADR-009 excludes both classes, yet the live database has:

| Class column | Grants at levels 1–60 | Grants at any active level (<255) |
|---|---:|---:|
| `classes15` (Beastlord) | 57 | 1,157 |
| `classes16` (Berserker) | 37 | 735 |

The SoV expansion gate should prevent normal character creation, so this is
not evidence of a current player-facing breach. It is nevertheless an
ADR-009 inconsistency and leaves avoidable GM/direct-scribe exposure.

After a database backup, apply the following narrowly scoped correction and
verify both postconditions:

```sql
UPDATE spells_new SET classes15 = 255 WHERE classes15 BETWEEN 1 AND 254;
UPDATE spells_new SET classes16 = 255 WHERE classes16 BETWEEN 1 AND 254;

SELECT
  SUM(classes15 BETWEEN 1 AND 254) AS beastlord_grants,
  SUM(classes16 BETWEEN 1 AND 254) AS berserker_grants
FROM spells_new;
```

Expected postcondition: both counts are zero. This does not alter the spells'
mechanics or any of the 14 Velious-playable class columns.

### 2. Disable the unused Dragons of Norrath content flag

`don_nest_unlocked` is enabled. ADR-001's expansion gate is correctly active
and remains the primary control, so this flag is not proof that DoN content is
reachable. Disable it as defense in depth unless it has a documented test-only
purpose, then smoke-test the normal Classic–Velious zone path.

### 3. Close the Krono check without deleting data

Krono item `88888` exists in the retained PEQ catalog, but has no merchant,
lootdrop, starting-item, character-inventory, or shared-bank reference. Record
it as **retained inert reference data** under ADR-001 rather than deleting it.
This resolves ADR-008's residual verification note without turning a harmless
catalog row into needless schema/data churn.

## Mechanics execution plan

### Tier 1 — runtime tests with high player value

Run each once as a short, scripted or repeatable in-game test and save the
result with server version and ruleset ID.

1. **HP and regeneration:** verify class/level STA-to-HP deltas, baseline
   seated versus standing regen, and Troll/Iksar bonus behavior. The live
   `Character:BaseHPRegenBonusRaces = 4352` bitmask already selects Troll and
   Iksar; verify the resulting runtime values before changing anything.
2. **Mana and Meditate:** test just below/at/above 200 INT or WIS, zero versus
   trained Meditate, and seated versus standing ticks.
3. **Casting:** test movement interruption, melee push interruption,
   recovery/recast lockout, and components on success, interruption, and
   fizzle. Use a spell with a known component and a spell with visibly distinct
   recast/recovery timers.
4. **Line of sight and snare/root:** test spell LoS, NPC aggro LoS, pet attack
   LoS/range, and two movement-speed effects. Keep the existing conservative
   configuration (`Pets:PetsRequireLoS = false`,
   `Spells:SnareOverridesSpeedBonuses = false`) unless observation shows a
   concrete discrepancy.

### Tier 2 — source/config confirmation; no proactive tuning

- Critical-hit chance; bash/kick/special attacks; weapon caps; proc and
  backstab calculations.
- Bind Wound completion-time threshold behavior.
- Skill-cap edge cases and item stacking.
- AA/veteran and guild inaccessibility.

For this tier, preserve current EQEmu behavior if no high-confidence
classic-era target exists. Do not infer a correction from P99 forum disagreement
or from a modern rule name alone.

### Explicitly low-priority / accepted-current-behavior items

Fizzle formula, resist scaling, detailed avoidance formulae, stun mechanics,
sneak/social-assist interaction, charm/CHA duration, and Feign Death's
resisted-spell interaction all lack a sufficiently settled classic target.
Capture the current implementation once, label the evidence quality, and close
them as **accepted EQEmu behavior** unless stronger evidence emerges.

## ADR consistency notes

- The active ruleset is **1**. Values from ruleset 10 (for example level cap
  68) are not live conflicts with ADR-002's level cap of 60.
- ADR-010 remains the right faction decision. The dedicated P99 Faction page
  supports the implemented thresholds (Ally 1051, Warmly 701, Kindly 451, and
  so on); the alternate Game Mechanics table labels itself unconfirmed.
- `Bots:Enabled = false`, all four ADR-001 expansion rules match their
  specification, and NPC leash is disabled. No adjustment is recommended for
  these controls.

## Final priority order

1. Zone-architecture audit for ADR-008's overridden zones only.
2. Beastlord/Berserker spell-column cleanup; disable the unused DoN flag;
   record the inert Krono result.
3. Correct the identified WIP/status-document drift.
4. Run the Tier 1 runtime test matrix.
5. Handle Tier 2 checks opportunistically and close contested mechanics as
   accepted current behavior rather than pursuing speculative retunes.
