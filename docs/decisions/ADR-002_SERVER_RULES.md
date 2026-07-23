# ADR-002: Server Rules Baseline (PEQ vs TAKP)

**Status:** Accepted (implementation pending MCP connection)
**Date:** 2026-07-23
**Supersedes:** Earlier draft titled "ADR-002: Experience & Level Cap Rules"

---

## Context

A complete diff of the `rule_values` table was performed between the
imported PEQ database (Sept 2025 dump) and the TAKP Reference database
(2023-era dump, content-only extraction).

Results of the comparison, ruleset_id 1:

- PEQ: 1,001 rules
- TAKP: 714 rules
- Differing in value: 39
- Present only in TAKP: 12 (see "Rule Renames" — most are not
  genuinely new)
- Present only in PEQ: 299 (almost entirely rules added to EQEmu after
  TAKP's 2023 dump; not deliberate removals)

PEQ defaults target a modern, full-expansion server. TAKP reconstructs
classic-era mechanics but also contains the file author's personal
changes, notably an enabled bot system and several difficulty
reductions. Each difference was evaluated individually rather than
adopting either source wholesale.

---

## Decisions

### Experience & Leveling

| Rule | Value | Source | Notes |
|---|---|---|---|
| `Character:MaxLevel` | 50 | TAKP | Velious-era cap |
| `Character:MaxExpLevel` | 50 | TAKP | Matches cap |
| `Character:ExpMultiplier` | 0.65 | PEQ | Faster than classic; solo pacing |
| `Character:AAExpMultiplier` | 0.65 | PEQ | Matches exp multiplier |
| `Character:FullGroupEXPModifier` | 2.16 | PEQ | |
| `Character:GroupMemberEXPModifier` | 0.20 | PEQ | |
| `Character:UseOldClassExpPenalties` | false | PEQ | Deliberate deviation |
| `Character:UseOldRaceExpPenalties` | false | PEQ | Deliberate deviation |

### Death & Corpses

| Rule | Value | Source | Notes |
|---|---|---|---|
| `Character:DeathExpLossLevel` | 15 | Custom | PEQ 10 / TAKP 5 |
| `Character:DeathExpLossMultiplier` | 3 | PEQ | ~3.5% loss |
| `Character:DeathKeepLevel` | true | TAKP | No de-leveling |
| `Character:DeathItemLossLevel` | 15 | Custom | PEQ 10 / TAKP 90 |
| `Character:LeaveCorpses` | true | PEQ | Unchanged |
| `Character:LeaveNakedCorpses` | false | Custom | No corpse if died carrying nothing |
| `Character:CorpseDecayTime` | 2147483647 | Custom | ~24.86 days — practical ceiling, **not** true "never"; see Corpse Decay Note |
| `Character:EmptyCorpseDecayTime` | 30000 | Custom | 30-second buffer after corpse is looted clean |

### Classic Mechanics Restored

| Rule | Value | Source | Notes |
|---|---|---|---|
| `Character:EnableHungerPenalties` | true | TAKP | Classic food/drink requirement |
| `Character:EnableTGB` | false | TAKP | `/tgb` is post-Velious; PEQ's own rule note recommends false for classic |
| `Character:RestRegenEnabled` | false | TAKP | Later-era mechanic |
| `Combat:ClassicMasterWu` | true | TAKP | Classic monk behavior |
| `Spells:WizCritLevel` | 10 | Custom | PEQ 12 / TAKP 80 — see Research Note |

### Convenience Retained

| Rule | Value | Source | Notes |
|---|---|---|---|
| `Character:BindAnywhere` | true | TAKP | Deliberate non-classic deviation |

### Restrictions Retained

| Rule | Value | Source | Notes |
|---|---|---|---|
| `Pets:CanTakeNoDrop` | false | PEQ | |

`Pets:CanTakeQuestItems` is **deliberately not set**. It exists in the
TAKP file but is not seeded in PEQ's `rule_values`, and it is unclear
whether current EQEmu still recognizes it. Seeding an unrecognized rule
would add a phantom entry with no effect. If pet quest-item handling
proves to be a problem in play, revisit then.

### Bot System — Excluded Entirely

All bot-related rule changes present in the TAKP file are **rejected**.
PEQ defaults are retained, including `Bots:Enabled = false`.

Rejected TAKP bot changes: `Bots:Enabled`, `Bots:BotLevelsWithOwner`,
`Bots:FinishBuffing`, `Bots:GroupBuffing`, `Bots:QuestableSpawnLimit`,
`Bots:ManaRegen`, `Bots:CasterStopMeleeLevel`,
`Bots:BotExpansionSettings`, `Bots:AllowOwnerOptionAltCombat`,
`Bots:BotGroupXP`.

Rationale: group content is handled through Very Vanilla MQ
multiboxing (see VELIOUS_VISION.md). The EQEmu bot system is not part
of this project's design, and its enablement in the TAKP file reflects
the file author's personal preferences, not classic accuracy.

### Other TAKP Changes Rejected

| Rule | TAKP value | Reason for rejection |
|---|---|---|
| `Character:DeathItemLossLevel` | 90 | With a level 50 cap this disables item loss entirely, removing corpse recovery as a mechanic |

---

## Deliberate Deviations from Classic

Recorded explicitly so these are not later mistaken for oversights.
All are permitted under the Solo Player Philosophy in
VELIOUS_VISION.md.

1. **Experience rate (0.65)** — faster than classic pacing.
2. **Class/race experience penalties disabled** — classic applied
   these; disabled here for solo play.
3. **`BindAnywhere` enabled** — classic restricted binding heavily.
4. **Corpses holding items effectively do not decay** — set to the
   practical ceiling (~24.86 days) rather than true "never". Classic
   corpse decay pressure is removed in normal play. See Corpse Decay
   Note for the limit of this.
5. **`DeathKeepLevel` enabled** — de-leveling cannot occur.

---

## Research Note: `Spells:WizCritLevel`

Value 10 was chosen over both PEQ (12) and TAKP (80).

- *Community consensus / wiki:* wizards gain an innate critical chance
  on direct damage spells from level 10, stacking with later AA lines.
- *Reasoned inference from secondary sources:* wizards were the only
  class able to critical with nukes prior to Luclin, when Fury of Magic
  extended the ability to other classes. This indicates innate wizard
  crits were active during Velious.
- *Conflicting community discussion:* archived forum posts variously
  recall level 10 and level 30, with one attributing the addition to an
  early Kunark-era caster rebalance. The exact level is disputed.

TAKP's value of 80 disables the mechanic entirely at a level 50 cap,
which appears inconsistent with Velious-era behavior. Existence of the
mechanic is well-supported; the precise level is not verified.

---

## Corpse Decay Note

True "never decay" may not be expressible. If
`Character:CorpseDecayTime` is parsed as a signed 32-bit integer, the
ceiling is 2,147,483,647 ms (~24.86 days), which is the value adopted.

**Practical consequence:** an unrecovered corpse *will* still expire
with its items after roughly 25 days. This is acceptable during active
play but is a real risk across an extended break from the server.

EQEmu uses `-1` as a "disabled" convention on some rules (e.g.
`Character:ExperiencePercentCapPerKill`, whose own note states -1
disables the cap). Whether that convention applies to corpse decay is
**unverified**. If a true "never" is wanted later, test `-1` before
assuming it works.

Diagnostic: if corpses decay immediately rather than persisting, that
indicates integer overflow in the decay calculation rather than a
configuration error. Step the value down (e.g. to 1000000000 ms,
~11.6 days) to confirm.

---

## Rule Renames (Comparison Artifact)

Five rules appearing "TAKP-only" are renames — EQEmu dropped the `MS`
suffix between the 2023 and 2025 dumps. Their values still differ and
were compared on that basis:

`Character:CorpseDecayTimeMS` → `Character:CorpseDecayTime`
`Character:CorpseResTimeMS` → `Character:CorpseResTime`
`NPC:EmptyNPCCorpseDecayTimeMS` → `NPC:EmptyNPCCorpseDecayTime`
`NPC:MajorNPCCorpseDecayTimeMS` → `NPC:MajorNPCCorpseDecayTime`
`NPC:MinorNPCCorpseDecayTimeMS` → `NPC:MinorNPCCorpseDecayTime`

Two further rules were restructured rather than renamed:
`Spells:AOEMaxTargets` was split into `DefaultAOEMaxTargets`,
`PointBlankAOEMaxTargets`, and `TargetedAOEMaxTargets`.
`Zone:SecondsBeforeIdle` was split into
`Character:SecondsBeforeIdleCombatZone` and `...NonCombatZone`.

Genuinely TAKP-only and non-bot: `NPC:ReturnNonQuestNoDropItems`,
`NPC:ReturnQuestItemsFromNonQuestNPCs`, `Pets:CanTakeQuestItems`.

---

## Open Items — Resolved 2026-07-23

1. **Corpse decay ceiling** — resolved. Practical ceiling adopted; see
   Corpse Decay Note.
2. **Empty corpse decay** — resolved. Set to 30000 ms (30 seconds)
   rather than 0, providing a small buffer after a corpse is looted
   clean and avoiding reliance on the unverified assumption that 0
   means immediate.
3. **"Naked" vs "empty" corpse distinction** — accepted as inferred and
   proceeding on that basis. Still not formally verified against EQEmu
   source; revisit if corpse behavior does not match expectations in
   testing.
4. **`Pets:CanTakeQuestItems`** — resolved. Deliberately not set. See
   Restrictions Retained.

No open verification items remain. The expansion gating mechanism
formerly carried forward from ADR-001 was verified and closed on
2026-07-23.

---

## Spire Compatibility

No schema changes. `rule_values` is a standard PEQ table Spire already
edits directly. Every decision above can be applied through Spire's UI
or via SQL with identical results.

---

## Implementation Status

**Not implemented.** No database changes have been made. Implementation
will occur directly against the live Angels Misfits database once EQEmu
MCP is connected, following the backup and rollback process defined in
the project's database safety policy.