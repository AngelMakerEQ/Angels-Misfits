# Angels Misfits Changelog

Lightweight chronological index of major project milestones. Each entry states what changed in plain terms. Full decision reasoning and implementation detail lives in the referenced ADR.

---

- **2026-07-22** — Project documentation structure established. (No ADR — foundational setup.)
- **2026-07-22 → 2026-07-23** — ADR-001: Content scope restricted to Velious-and-earlier. Later-expansion content is retained in the database but hidden from players.
- **2026-07-23** — ADR-002: Server rules rebaselined against PEQ/TAKP — restored several classic mechanics (hunger, Master Wu, no `/tgb`), removed class/race exp penalties, added faster exp rate and always-bindable for solo play.
- **2026-07-23** — ADR-003: NPC combat stats increased across ~12,574 Classic/Kunark/Velious NPCs — higher HP, damage, AC, resists, and regen; aggro radius widened moderately (not full TAKP widening, to preserve multibox viability).
- **2026-07-23** — ADR-004: Spell mechanics replaced wholesale (37,729 spells) with data verified against the real classic client — affects cast times, targeting, effects, and reagents across all classes.
- **2026-07-23** — ADR-005: Pet stats reduced to align with classic behavior — pets hit softer and self-heal slower, but resist magic/fire better and move faster.
- **2026-07-25** — ADR-006: Starting kit corrected — removed a non-classic backpack and Gloomingdeep lantern; all other starting items verified classic and kept.
- **2026-07-26** — ADR-002 correction: level cap corrected from 50 to 60 (Kunark, not Velious, raised the cap; earlier value was a factual error).
- **2026-07-26** — ADR-007: Skeleton-family NPCs (1,630 total) corrected to classic-style models; genuine Iksar-identity NPCs deliberately excluded.
- **2026-07-26 (ongoing)** — ADR-008: Client-side classic visual restoration — Luclin models disabled, classic zone files applied, spell icons/gems/effects and skeleton models updated, TaipoUI selected as current UI.
# 2026-07-28

## Sense Heading & Swimming Skill Correction

Corrected two skills that were using EQEmu's modern default behavior
instead of classic mechanics:

- `Skills:SenseHeadingStartValue` changed from 200 (auto-maxed at
  character creation) to 0 — characters must now train Sense Heading
  at their guildmaster before it can be used at all.
- `Skills:TrainSenseHeading` changed from false to true — Sense Heading
  now increases through use like any other trained skill, instead of
  remaining permanently frozen at its starting value.
- `Skills:SwimmingStartValue` changed from 100 to 0 — corrects both a
  historical-accuracy issue and a real inconsistency (100 exceeded a
  level-1 character's own skill cap of 5).

No other skills in the ruleset use this starting-value override
mechanism; a full search confirmed these two were the only cases.

## Bard Instrument Mechanics Verification

Investigated the Bard instrument-modifier system (instrument type/skill
matching, fizzle-rate dependence on instrument skill, item bardtype/
bardvalue data) end to end. Confirmed correctly implemented and
data-complete — no broader fix needed. Two small corrections made:

- Disabled a broken duplicate spell entry ("Angstlich's Appalling
  Screech," id 1329) that carried an invalid skill value (5, not a
  real Bard instrument/singing skill). The correct copy (id 706,
  skill=12/Brass) is unaffected.
- `Spells:PreNerfBardAEDoT` changed from false to true — restores
  pre-2004 behavior where Bard PBAoE songs damage moving targets. The
  restrictive version of this mechanic postdates Velious.

`Character:EnableBardMelody` reviewed and deliberately left enabled
(true) for player convenience, despite being a non-classic
QoL feature — a conscious deviation, not an oversight.

---

For full project history and reasoning, see `docs/decisions/`.

---

## Merchant Pricing System Correction

Switched the server's merchant pricing calculation from EQEmu's modern
default to the classic mechanic:

- `Merchant:UseClassicPriceMod` changed from false to true — this
  enables the classic percentage-based pricing formula (including
  CHA-based haggling) in place of the modern flat-markup system
  (`SellCostMod`/`BuyCostMod`, which sold at only ~5% markup and
  bought at ~95% of value — far gentler than intended).

This affects every merchant transaction server-wide. Note: every
vendor's individual `greed` value is still at its default (0), which
under the classic formula means all vendors currently trade at the
baseline rate rather than the correct "greedy vs. non-greedy" split
documented for classic EQ (most vendors buy at half/sell at double,
with a small set of specifically non-greedy exceptions like Cabilis).
Populating correct per-vendor `greed` values is logged as a separate,
larger follow-up item (Vendor Pricing Calibration Phase 2).