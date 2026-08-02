# HP and Mana Regeneration Runtime Review — 2026-08-01

## Outcome

`base_data` must remain unchanged. ADR-004 already establishes that the live
table agrees with the classic client `BaseData.txt`; the live server is also
configured to use its RoF2/SoD-compatible HP and mana calculation path.
Changing that data, or disabling that path, would create a broad and
unvalidated change to every character's maximum HP and mana.

One narrow database correction is justified now:

- Run `scripts/2026-08-01_classic_minimum_mana_regen.sql` to set
  `Character:OldMinMana=true` in active ruleset 1. This restores the classic
  minimum of 2 mana per tick while sitting and 1 while standing for a character
  with no Meditate skill. It does not replace or otherwise change the normal
  Meditate formula.

## Live configuration verified

| Setting | Active value | Assessment |
|---|---:|---|
| Zone ruleset (`sro`) | `1` | The SQL migration correctly targets ruleset 1. |
| `Character:SoDClientUseSoDHPManaEnd` | `true` | Retain. It is the active RoF2 calculation path. |
| `Character:RestRegenEnabled` | `false` | Correct per ADR-002; the modern out-of-combat recovery system is disabled. |
| `Character:HPRegenMultiplier` | `100` | Correct neutral multiplier. |
| `Character:ManaRegenMultiplier` | `100` | Correct neutral multiplier. |
| `Character:BaseHPRegenBonusRaces` | `4352` | Correctly includes Iksar and Troll. |
| `Character:OldMinMana` | `false` | Correct with the supplied SQL migration. |

## Source-path findings

The current upstream EQEmu implementation calls `CalcHPRegen()` and
`CalcManaRegen()` every server tick. `CalcHPRegen()` takes its baseline from
`base_data.hp_regen`; it does not read `Character:BaseHPRegenBonusRaces`.
The separately implemented `LevelRegen()` routine does read that bitmask, but
is not the function invoked by the tick path. At level 40, for example, live
`base_data` supplies an HP baseline of 6 for a Necromancer, regardless of race.

This creates a credible racial-regen defect: the configured Iksar/Troll bonus
may have no effect, while non-Iksar/Troll characters may receive the same
baseline. The database cannot express a race-specific value in `base_data`, so
there is no sound SQL-only correction for this issue.

`CalcManaRegen()` with `OldMinMana=false` produces no baseline mana regen at
zero Meditate skill. Its documented compatibility branch makes the minimum 2
while sitting and 1 while standing when `OldMinMana=true`; that is the purpose
of the supplied migration.

`RestRegenEnabled=false` does successfully prevent the separate fast
out-of-combat recovery path. It does not, by itself, establish that all
ordinary HP and mana tick rates are classic.

## Required runtime verification before an HP code change

The connected server exposes the live database but not the installed zone
source/binary, so confirm the deployed behavior in game before carrying a
source patch forward.

1. Use Angel (level 40 Iksar Necromancer) and a level 40 non-Iksar
   Necromancer. Neither character may have regen items, buffs, AAs, starvation,
   or an active damage-over-time effect.
2. Bring each character well below maximum HP. Record three six-second HP tick
   gains while standing, then three while sitting. Do not remain seated longer
   than one minute for the baseline comparison.
3. The likely deployed result, if it follows the current EQEmu implementation,
   is +6 HP per tick for both characters in both postures at level 40. A
   classic racial result should instead show a material Iksar advantage.
4. For mana, test a character with zero Meditate before and after the SQL
   migration: expected minimums are +1 standing and +2 sitting after the
   migration.

If the HP test confirms no racial distinction, the correct solution is a small
server-source patch to add the existing `BaseHPRegenBonusRaces` racial modifier
to `CalcHPRegen()`, followed by a rebuild and the same two-character test. Do
not compensate by changing `base_data`: that would change every race and
conflict with ADR-004's classic-data validation.

## Decision record compatibility

- ADR-002: preserves the existing decision to keep modern rest regeneration
  disabled.
- ADR-004: preserves the already-validated classic `base_data` values.
- No expansion gate, zone dependency, spell, inventory, or client-asset ADR is
  affected.
