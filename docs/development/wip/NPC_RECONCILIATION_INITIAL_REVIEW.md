# NPC Reconciliation: Initial Read-Only Review

**Status:** In progress — no database changes proposed or applied  
**Scope rule:** Include only `zone.version = 0` and `spawn2.version = 0` for
Classic, Kunark, and Velious. Later zone versions are revamps and are excluded.

## Baseline and Method

- The live database is `angelsmisfits`; the EQEmu MCP was checked with
  `list_tables` and a harmless read query before analysis.
- P99 is the acceptance source where it publishes an NPC field. A previous
  broad tuning value is not an intentional-deviation allowlist: it must be
  replaced when a reliable classic value is available, unless a current,
  independently documented project decision explicitly retains it.
- The live scan currently covers 28,461 version-0 spawn points, 16,272 unique
  NPC templates, and 7,788 reachable loot items. Per populated expansion:

| Era | Populated zones | Spawn points | NPC templates | Reachable items |
| --- | ---: | ---: | ---: | ---: |
| Classic | 80 | 15,076 | 9,409 | 4,261 |
| Kunark | 27 | 7,211 | 3,340 | 2,352 |
| Velious | 21 | 6,174 | 3,528 | 2,830 |

The per-era template counts overlap; do not sum them as a unique-template
total.

## First Three-Zone Review Package

### Classic — Lower Guk: `a_froglok_shin_knight` (66047)

Live: level 27, HP 999, damage 1–58, AC 115, `attack_count = -1`, 11
version-0 Lower Guk spawns. P99 records level 27–31, HP 970–1084, damage
13–62, AC 275, two attacks per round, and no special ability.

Classification: **confirmed unintentional drift** for minimum damage, maximum
damage, and AC. HP falls within the published P99 range. `attack_count = -1`
requires an EQEmu semantic check before it is classified against the P99
two-attacks field.

P99 evidence: <https://wiki.project1999.com/A_Froglok_Shin_Knight>

P99-known Lower Guk loot is partly present (mesh pieces, Shin Gauntlets,
Froglok Leg, and Froglok Meat), but the present live chain does not contain
the P99-listed Breath of Solusek, Shin Greaves, or Froglok Blood. This is a
comparison finding, not yet a proposed addition: P99-known-loot lists need
NPC/zone context review before absence is treated as a defect.

Generic lootdrops 155138 and 155139 are reachable at 100% table probability
and are shared by five active templates across 24 active Lower Guk spawn
points. Examples include Raw Amber/Crimson/Indigo/Shimmering Nihilite,
Froglok Egg Capsule, Alkalai Loam, and Flawless Spinneret Fluid. Raw Amber
Nihilite is documented as a Gates of Discord-era drop, establishing the pool
as post-Velious contamination.

Evidence: <https://www.eqtraders.com/articles/article_page.php?article=g232>

### Kunark — Emerald Jungle: `greater_spurbone` (94049)

The originally sampled City of Mist template (90094) is version 1 and is
gated to expansion 6, so it is excluded from this audit. The active
version-0 Emerald Jungle template is 94049, with eight spawn points.

Live: level 37, HP 2500, damage 14–85, AC 160, `attack_count = -1`, see
invisible enabled, and special-ability string `10,1^21,1^23,1^45,1`.
P99 records level 36–40, HP 2454–2534, damage 14–94, AC 253, two attacks per
round, immune to flee, and see invisible.

Classification: **confirmed unintentional drift** for maximum damage and AC.
HP, minimum damage, level, and see-invisible align. The `f` special-attack
flag and `special_abilities` string need EQEmu semantic verification before
they are accepted as evidence of P99's immune-to-flee behavior. As with the
Classic sample, `attack_count = -1` needs its runtime meaning confirmed.

P99 evidence: <https://wiki.project1999.com/Greater_Spurbone>

Generic pools 159294 and 159295 are shared by five active Emerald Jungle
templates across 20 active spawn points. All 38 rows in those pools are
ungated (`min_expansion = max_expansion = -1`); their item-era classification
is queued before any change.

### Velious — Crystal Caverns: `a_Ry`Gorr_watchman` (121000)

Live: level 29, HP 1580, damage 11–62, AC 131, `attack_count = -1`, and
eight version-0 Crystal Caverns spawns. P99 records level 29–31, HP 1131,
damage 11–58, AC 259, two attacks per round, and no special ability.

Classification: **confirmed unintentional drift** for HP, maximum damage, and
AC. Minimum damage, level, and the absence of a special ability align.

P99 evidence: <https://wiki.project1999.com/A_Ry%60Gorr_watchman>

Expected P99 loot such as Bottle of Karsin Acid, Klezendian Crystal, Frozen
Long Sword, the Velium weapons, and Shimmering Velium Ruby is present in the
current chain. The same NPC also reaches generic lootdrop 129680 at 100% table
probability. That pool contains 47 rows, including Pliant Loam, Regurgitated
Crystals, and later-era cultural/tradeskill materials. Lootdrops 129680 and
129681 are shared by five active templates across 22 active Crystal Caverns
spawn points.

## Controls Before Any SQL

1. Build the item-era manifest with an individual source and confidence for
   every generic-pool item; item IDs and unguarded rows are leads, not era
   evidence.
2. Inspect every active consumer of a shared lootdrop before modifying it.
   Clone/split a pool where target-era and later-era consumers need different
   contents.
3. For an evidence-confirmed out-of-era loot row, use an existing or new
   descriptive `content_flags` value at `enabled = 0`, rather than deleting
   the row. Retain the source, flag name, affected consumers, and a one-row
   re-enable path in the manifest.
4. Preserve original rows, proposed rows, rollback SQL, probability/cardinality
   checks, and exclusion queries in the review package.
5. Do not alter `attack_count` until its `-1` runtime meaning is verified in
   the EQEmu source or documentation.

## Content-Flag Draft: Phase 1

The first review identified six item types with sufficient era evidence for a
global, disabled-by-default gate. The accompanying draft migration is
`scripts/2026-08-06_npc_reconciliation_content_flags_phase_1.sql`; it is not
applied. It defines `GatesOfDiscord_GlobalDrops` for the four Raw Nihilites
(12,677 current loot rows) and `SecretsOfFaydwer_GlobalDrops` for Alkalai
Loam plus Flawless Spinneret Fluid (1,100 current loot rows). The script has
preflight, transaction, targeted verification, exclusion verification, and
rollback instructions matching ADR-016.

## Priority-Zone Stat Spot Checks

### Classic — Plane of Hate: `a_forsaken_revenant` (186000, 186003)

P99 identifies the male Magician and female Enchanter variants as level 51
with HP 10,870, AC 350, damage 74–203, two attacks per round, immune to flee,
and see invisible. The two active live templates instead are level 55/53,
HP 10,120, AC 397/383, and damage 46–234 / 46–230 across 17 and 15 spawn
points respectively.

Classification: **confirmed unintentional drift** for level, HP, AC, and
minimum/maximum damage. Both templates retain see invisible; their flee
immunity and attack-count representation need EQEmu semantic verification.

P99 evidence: <https://wiki.project1999.com/A_Forsaken_Revenant>

### Kunark — Veeshan's Peak: `a_racnar` (108037, 108500)

P99 records level 60, HP 21,000, AC 511, damage 240–500, two attacks per
round, and listed summon/immunity behavior. The two active live templates are
both level 60 but have HP 56,000, AC 254, and damage 181–713 across 32 and 40
spawn points. One template also has an additional special-ability string;
both retain see invisible.

Classification: **confirmed unintentional drift** for HP, AC, and
minimum/maximum damage. The special-ability mappings remain a separate source
and server-semantics check.

P99 evidence: <https://wiki.project1999.com/A_Racnar>

### Velious — Temple of Veeshan: `an_elder_onyx_drake` (124053)

The P99 Temple of Veeshan roster confirms the NPC's identity, Warrior class,
level 62, and multiple 50% spawn contexts. The active live template is level
62 at 30 spawn points. The P99 source does not publish combat values here, so
the live HP 60,000, AC 455, damage 100–290, spells, and special abilities are
**insufficient evidence**, not a correction candidate yet.

P99 evidence: <https://wiki.project1999.com/Temple_of_Veeshan?redirected_from_http=1>
