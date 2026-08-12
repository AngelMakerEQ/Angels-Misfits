# ADR-021: Classic HP/Mana Regeneration Formulas

**Status:** Accepted — Built, deployed, and verified in-game (2026-08-09)

**Date:** 2026-08-08

**Closes:** `docs/development/MECHANICS_REVIEW.md` open items 1 and 2 (HP
regen racial-bonus gap, mana regen runtime verification)

---

## Context

Angel (level 40 Iksar Necromancer, Meditate 225) was observed at 12 HP/tick
standing, 12 HP/tick sitting, 0 mana/tick standing, 17 mana/tick sitting.
Tracing `Client::CalcHPRegen()` / `Client::CalcManaRegen()` in the live
EQEmu source (`zone/client_mods.cpp`) reproduces the HP numbers and the
sitting-mana number exactly, confirming these are not display artifacts —
they are what the current engine actually computes.

**HP regen: correction to the 2026-08-01 finding.** `MECHANICS_REVIEW.md`
item 1 previously concluded that the Iksar/Troll racial bonus
(`Character:BaseHPRegenBonusRaces`) "may currently have no effect" because
`CalcHPRegen()` never reads that rule, and predicted "no racial difference
(~+6 HP/tick for both at level 40)" between an Iksar and a non-Iksar. That
prediction is wrong, verified today: `CalcHPRegen()` doubles `base` whenever
`m_pp.InnateSkills[InnateRegen] != InnateDisabled`, and `Client::SetRaceGenderClass`
(`zone/client.cpp` ~9614/9634) hardcodes `InnateRegen = Enabled` only for
`Race::Troll`/`Race::GrobbCitizen` and `Race::Iksar` — a genuine classic
racial trait ("Increased HP Regeneration"), completely independent of
`BaseHPRegenBonusRaces`. So `BaseHPRegenBonusRaces` really is dead for
players (it's only consumed by `Bot::LevelRegen()`, an unrelated function
used solely for NPC bots), but the racial doubling itself *is* happening —
just through a different, already-correct mechanism. The defect is not "no
racial bonus"; it's that the *base value being doubled* is wrong.

`base_data.hp_regen` for a level-40 Necromancer is 6.0 — this is EQEmu's
modern per-class/per-level live-era curve, not a classic value. `6 × 2`
(Iksar doubling) = 12, matching Angel's observed number exactly on both
standing and sitting (at level < 50, sitting adds no further bracket bonus
in the current code within the first 60 seconds of a sit).

The classic-era reference wiki's per-level-bracket table
(`Character Races#Increased HP Regeneration`, wiki.project1999.com) gives,
for Iksar/Troll at levels 20-49: **Standing = 2, Sitting = 6** — roughly
6x and 2x lower than what this server currently produces. Full table
(levels 1-60, this project's Velious-era cap per ADR-002's correction):

| Level range | Other: Stand/Feign/Sit | Iksar/Troll: Stand/Feign/Sit |
|---|---|---|
| 1-19  | 1/1/2 | 2/2/4 |
| 20-49 | 1/1/3 | 2/2/6 |
| 50    | 1/1/4 | 2/2/8 |
| 51-55 | 2/3/5 | 6/8/12 |
| 56-59 | 3/4/6 | 10/12/16 |
| 60    | 4/5/7 | 12/14/18 |

Note the Iksar/Troll column is **not** a uniform ×2 of the "Other" column
above level 50 (e.g. level 51-55: 2→6 is ×3, not ×2) — it must be table-driven,
not derived by doubling.

The out-of-combat accelerated-sitting ramp in the current
`CalcHPRegen()` (regen climbing the longer you sit continuously, past 60
seconds) is unrelated to this table and is itself non-classic — it matches
`MECHANICS_REVIEW.md`'s existing confirmed finding that "Rested" bonus
regen is Agnarr-specific, not classic/P99 behavior. Removing it in the
classic branch is consistent with an already-settled decision, not a new
one.

**Mana regen.** `CalcManaRegen()` gives sitting mana regen as
`2 + floor(skill/15)`. The classic-era wiki's `Skill Meditate` page states
both a formula in prose ("without [Meditate] you gain 2 mana sitting...
for every 12 points of Meditate skill you gain +1") and a literal
skill→mana/tick table that is exactly `floor(skill/12)` with **no** added
base (e.g. skill 12 → 1, not 3). These two statements are inconsistent
with each other, and the source doesn't resolve it further. Implementation
choice made here, per `DESIGN_PHILOSOPHY.md`'s instruction to state
disagreements explicitly rather than pick silently: **trust the numeric
table** (it's concrete data, not descriptive prose) for skill ≥ 1
(`max(1, floor(skill/12))`), and use the explicit "without it, 2 mana"
statement only for the skill == 0 case, which the table doesn't cover. At
skill 225 this gives 18 (vs. today's 17) — a small gap, but the underlying
`/15` divisor is a different, non-classic constant that would diverge much
further at higher skill (e.g. skill 252: today's formula gives 18,
classic table gives 21).

Standing mana regen is unambiguous in the source: **"Whether you have
Meditate or not, you will only gain 1 mana (per tick) when standing."**
Flat 1, always. This server's `Character:OldMinMana` rule (`true`, ruleset
1, set 2026-08-01 per `scripts/2026-08-01_classic_minimum_mana_regen.sql`)
was intended to enforce exactly this floor, and Oasis (where Angel was
standing when observed) does run ruleset 1. The observed 0 contradicts
both the classic source and this server's own already-configured rule —
worth an in-game re-test after the rebuild below rather than assuming a
second, unrelated bug; the classic branch introduced here does not depend
on `OldMinMana` and sets standing regen to a flat 1 unconditionally,
which will resolve it either way.

## Decision

Add a new rule, `Character:UseClassicRegen` (ruleset 1, default `true`),
gating a classic-formula branch in both `CalcHPRegen()` and
`CalcManaRegen()`. Toggleable rather than a hard replacement, per
implementation-preference-order (`DESIGN_PHILOSOPHY.md`): this is already
an engine modification (last resort in that ordering — no rule or database
configuration can express a per-level-bracket regen table), so the rule
gate is the only lever available short of another recompile to turn it
back off if needed. AA/item/spell/area regen bonuses are layered on top
in both branches, unchanged — this only replaces the "raw" formula, not
itemization.

Bard's meditate exclusion (`GetClass() != Class::Bard` skips the
meditate-based sit bonus entirely) is preserved unchanged in the classic
branch — that's a separate class-mechanic question this investigation
didn't verify against classic Bard behavior, out of scope here.

## Mechanism/Implementation

`zone/client_mods.cpp`:
- `Client::CalcHPRegen()` — new `if (RuleB(Character, UseClassicRegen))`
  branch. **Correction to the plan above:** rather than writing a new
  inline six-bracket table, the build discovered `Client::LevelRegen()`
  already implements this exact table (level bracket,
  `IsSitting()`/`GetFeigned()`, and the Iksar/Troll racial doubling via
  `GetPlayerRaceBit`/`BaseHPRegenBonusRaces`) — it was already present in
  the source and already correctly used by `Bot::LevelRegen()` for bot
  regen, just never called from the Client HP regen path. No new formula
  was written; the classic branch is simply `base = LevelRegen();`,
  reusing this existing, already-verified-correct function. Skips the
  live-only accelerated-sitting ramp entirely.
- `Client::CalcManaRegen()` — new classic branch: standing = flat 1
  (unconditional), sitting = `skill == 0 ? 2 : max(1, skill / 12)`
  (Bard still excluded), no level > 61 AA-era bonus, no 65-mana soft cap
  (irrelevant below level 60 in practice).

New rule: `Character:UseClassicRegen` = `true`, ruleset 1 —
`scripts/Applied/2026-08-08_classic_regen_formulas_APPLIED.sql`.

**Applied 2026-08-09.** Built `zone.exe` and deployed (MD5-verified against
the build output). Verified in-game via the `#mystats` GM command (which
calls the same server-authoritative `CalcHPRegen()`/`LevelRegen()` this
ADR wires up) — the native Character/Stats window's regen figures are
computed client-side by the EQ client itself and do **not** reflect
server-side regen rules at all, so that UI is not a valid verification
method for this or any future regen change; use `#mystats`/`#showstats`
or observed HP/mana over time instead.

**Deployment pitfall found and fixed:** the rule kept disappearing from
`rule_values` after every full server restart. Root cause:
`world_boot.cpp` calls `RuleManager::UpdateOrphanedRules()` on every World
boot, which deletes (across *all* rulesets) any `rule_values` row whose
name isn't in the rule catalog compiled into the **currently running
`world.exe`**. Only `zone.exe` had been rebuilt with the new
`RULE_BOOL(Character, UseClassicRegen, ...)` entry; the live `world.exe`
was a stale pre-session build that didn't recognize the name and wiped it
on every boot. Fixed by rebuilding and redeploying `world.exe` from the
same source tree (no code changes needed — `ruletypes.h` is a shared
`common/` header). **Any future custom rule addition must rebuild and
redeploy both `zone.exe` and `world.exe` together**, or the row will be
silently deleted on the next restart.

## Verification

Per `TESTING.md`, verified 2026-08-09:
1. Confirmed `Character:UseClassicRegen = true` via direct query against
   `rule_values`, ruleset 1, after a full cold restart (not the script's
   own success report) — see the orphaned-rules pitfall above for why a
   post-restart check specifically was necessary.
2. In-game, level-40 Iksar Necromancer (Angel), confirmed via `#mystats`
   (not the client-side Stats window — see above).
3. Not yet done: bracket-boundary exclusion checks (level 55/60) and a
   non-Iksar/Troll comparison character — worth a follow-up pass if a
   second test character becomes available, but not blocking for this
   ADR's Accepted status since the level-40 Iksar case (the originally
   reported bug) is confirmed fixed.
