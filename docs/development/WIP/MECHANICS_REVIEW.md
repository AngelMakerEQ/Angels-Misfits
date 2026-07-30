# Mechanical Systems Sweep — Standing Checklist

**Purpose:** A systematic, category-by-category sweep of every major game
mechanic, built specifically to catch "unknown unknowns" — mechanics
neither of us would think to question from memory, surfaced instead by
searching P99's own bug forums and wiki for each category in turn. This
is a standing document meant to be added to across multiple sessions,
since research capacity resets daily. Update in place; don't recreate.

**Confidence key:**
- ✅ **Confirmed, actionable** — a specific, well-documented claim with a
  clear fix or clear verification target once MCP is back.
- ⚠️ **Contested/uncertain** — even P99's own community disputes this one;
  treat as lower priority, likely best resolved by matching EQEmu's
  documented default rather than chasing a "true" answer nobody has.
- 🔲 **Not yet researched** — on the list, no search pass done yet.
- 🟦 **Already covered** — addressed in an existing ADR or reference doc;
  listed here for completeness so the sweep doesn't re-do work.

---

## Spellcasting

- 🔴 **Spell scribing/memorization speed — researched, checked against
  source, and now confirmed by an actual P99 developer quote.**
  Developer Telin, quoted directly on P99's own "Non-Classic
  Compendium" page: *"Scribing new spells should take a lot longer,
  and memorizing spells also took longer depending on your level and
  the level of the spell being memorized. This is a known issue, but
  cannot be fixed at this time due to client limitations."* This
  matches exactly what tracing our own source code found (no timing
  logic anywhere in the scribe/memorize path) — now confirmed
  authoritatively rather than just inferred: **this is a genuine
  client-side limitation, not a server rule we're missing.** Given
  we're on RoF2 (a much newer client generation than Titanium, which
  P99 uses), it's unclear whether this limitation applies the same way,
  more severely, or potentially differently for us — worth keeping in
  mind but not expecting a fix from our side either way.
- ⚠️ **Spell fizzle rate** — long-running (2010-2011+), unresolved dispute
  even within P99's own bug forums. Complaints run in both directions:
  fizzle rate feels too *high* at maxed skill (~15% observed vs. ~5%
  expected) and too *low* at very low skill (should approach "fizzle the
  entire mana bar" on a freshly-learned spell, but P99 reports casting
  successfully after just 2-5 attempts at single-digit skill). One
  poster even showed the *statistical distribution* of fizzle streaks
  doesn't match a flat 5% rate, suggesting the underlying formula itself
  might be miscalibrated on P99, not just perception. Given this is
  disputed even by dedicated researchers with a decade of forum
  discussion behind it, **treat as low-confidence-obtainable** — likely
  best resolved by matching whatever formula our EQCode source already
  implements (probably EQEmu's own default) rather than expecting to
  land on a "correct" answer that P99 itself hasn't settled.
- 🔲 Spell interruption (movement/melee-push interrupt chance)
- ⚠️ **Resist checks / resist rate scaling** — genuinely underdocumented,
  even by P99's own standards. The wiki's own dedicated Statistics page
  states outright that its resist-formula information "is based on
  EQEmu development discussions... and is not necessarily correct for
  P99. But it's probably pretty close" — and a 2020 forum thread has a
  player pointing out the wiki literally has a "(Todo: Add the mechanics
  and formulas behind resistances.)" placeholder where the real formula
  should be. Rough, low-confidence community folklore exists (~6
  resistance points ≈ 1% more resist chance; a 7-level difference shifts
  resist chance ~12%; always some floor/ceiling chance regardless of
  stat), but nothing rises to the confidence level of tradeskills or
  Harm Touch. **Same treatment as fizzle rate:** best resolved by
  matching whatever formula our EQCode source already implements, not
  by chasing a "true" classic answer that doesn't appear to exist
  publicly even for P99 itself.
- 🔲 Spell recast/recovery time enforcement
- 🔲 Spell component consumption rules (reagent loss on fizzle vs. success)
- 🟦 Mana calculation formula, Meditate mana-per-tick ratio (Game
  Mechanics reference)
- 🟦 Buff level-range restrictions (Game Mechanics reference)
- 🟦 Detrimental AE 25-target cap (Game Mechanics reference — flagged
  there as a P99-specific anti-exploit change, not an era-accuracy item)

## Charm, Mez, Root, Snare

- 🟢 **Charm break mechanic — researched, then verified against source
  and live database: already correct, no fix needed.** The exact
  per-tick probability model is implemented via `Spells:
  CharmBreakCheckChance` (a 25% chance per buff tick to trigger a break
  check), and the EQEmu source even includes a developer comment noting
  this was calibrated against a documented "~68 ticks average charm
  duration on LIVE" statistic against 0%-resist targets. Our live
  database has this rule at its default (25), and the related
  `Pets:LivelikeBreakCharmOnInvis` rule (whether becoming invisible
  breaks an active charm) is also at its sensible default (true). This
  is a genuine confirmation, not just an assumption — nothing to change
  here.
- 🟡 **Charm duration formula: genuinely contested on the wiki itself,
  and checked against source — CHA does not factor in.** Sources
  disagree on whether Charisma extends charm duration/break-resistance:
  the Enchanter class page states CHA "extends the duration of Charms
  by making it harder for targets to break free," but a forum poster's
  own controlled testing (changing CHA while tracking charm outcomes)
  found "CHA really doesn't play a role at all" — level difference and
  target magic resistance were the dominant factors. **Checked against
  our source:** Charisma only appears in `aggro.cpp` in relation to
  **Lull** spells' secondary resist check — nowhere in the charm
  break-check logic itself. So our implementation matches the "CHA
  doesn't matter" camp, not the wiki page's claim. Given the wiki's own
  internal disagreement, this doesn't look like a clear bug — more
  likely the class page's CHA claim is itself inaccurate community
  folklore, but flagging plainly since it's not a slam-dunk either way.
  Duration itself is also widely described as "randomly generated"
  rather than following any confirmed formula — likely another item to
  treat like fizzle/resist (accept our implementation absent a
  confirmed correct target).
- 🟢 **Mesmerize: confirmed non-stacking, and a useful tactical
  confirmation.** Mesmerize/Enthrall/Mesmerization (the single-target
  mez line) do not stack with each other — casting a second one before
  the first expires simply fails to extend it; you must let one lapse
  before re-applying. Also confirmed: successfully landing Mesmerize on
  a casting mob interrupts its cast without costing the caster any
  mana. Straightforward, well-documented, no discrepancy expected.
- 🟢 **Root: nukes confirmed to potentially break it early.** Direct
  damage spells ("nukes") may break Root early — confirmed on the
  dedicated Spell page. The specific 20%-of-damage-dealt root-break
  figure from the Game Mechanics reference remains ambiguous on whether
  it's PvE-general or PvP-specific; not fully resolved in this pass.
- 🟦 Giants/Dragons cannot be stunned or mesmerized (Game Mechanics
  reference)
- 🔲 Snare mechanics (stacking rules, resist scaling) — no specific
  stacking rule found beyond general debuff-slot behavior; not
  resolved in this pass.

## Combat

- 🟦 Weapon damage caps by level/class, max damage formulas, weighted D20,
  weapon proc rate, backstab formula, NPC max melee damage estimate,
  dual wield chance (all in Game Mechanics reference — several flagged
  there as themselves uncertain even on the wiki)
- 🟦 NPC combat stats (hp/damage/AC/resists/aggro radius) — ADR-003
- ⚠️ Stun duration and resist mechanics — mostly documented in PvP-
  specific, actively-disputed threads (not relevant to our cooperative
  server); even P99's own Game Mechanics page admits "a maximum stun
  duration exists... values still being tuned." Same low-confidence
  bucket as fizzle/resist.
- ⚠️ Riposte/dodge/parry/block — no clean formula found, mostly
  qualitative. Agility affects Dodge/Defense/Parry skill-up rate and
  avoidance AC, with a notable breakpoint at 75 AGI (below 75 = steep
  AC penalty, e.g. going 66→75 AGI grants ~45 AC vs. only ~3 AC going
  76→85) and a separate low-HP AGI penalty starting around 25% health.
  Same low-actionability bucket as the combat damage formulas already
  in the Game Mechanics reference.
- 🔲 Critical hit chance formula (distinct from critical hit *damage*,
  which is in the Game Mechanics reference)
- 🔲 Bash/kick/other combat skill-based special attack mechanics

## Aggro & NPC AI

- 🟦 Aggro radius (ADR-003, custom per-NPC midpoint methodology)
- 🟦 NPC gate-at-20%-health, 25% HP regain after gating, 3-second
  post-spawn aggro immunity, direct-vs-indirect hate distinction (Game
  Mechanics reference)
- ✅ **Social aggro (assist) radius: checked against source — working
  correctly, initial concern was a false alarm.** Only 2,957 of 67,530
  NPCs (4.4%) have a nonzero `assistradius`. This looked like a possible
  gap at first, but checking the actual code (`aggro.cpp`) shows the
  logic is `if (assist_range > aggro_range) aggro_range = assist_range`
  — meaning a zero assist radius simply falls back to using the NPC's
  regular aggro radius (already populated for virtually every NPC via
  ADR-003). The 2,957 NPCs with an explicit, larger assist radius are
  exactly the documented classic exception case — "some NPCs have a
  small aggro radius but a very large call-for-help radius." No fix
  needed; the fallback design already handles this correctly.
- 🟡 **Social aggro faction/type-matching logic itself: not checked in
  this pass, folds into the broader ongoing faction verification
  workstream.** P99's dedicated Aggro page documents detailed rules
  (same primary faction usually assists; related-but-different
  factions sometimes do — e.g. Kromzek/Kromrif giants always assist
  each other; live vs. undead frogloks don't assist each other but do
  assist their own kind; absent a faction, type/race/species-based
  assist applies instead — undead assist undead, elementals assist
  elementals). Verifying this against our actual `faction_association`
  data for specific named NPCs is a real, larger task — treat as part
  of the standing faction-system background item, not a quick win here.
- 🔴 **Invisibility/Sneak and social aggro: actively disputed, worth
  knowing regardless of resolution.** P99's Aggro page states plainly
  that "Invisibility, Sneak, and other player faction adjustments no
  longer prevent social aggro on P99" — the word "no longer" itself
  implies this is a change from an earlier P99 implementation. A
  detailed forum thread has a player theorizing this current behavior
  may not be classic-accurate at all — that true classic sneak/invis
  may have functioned like a "positional invisibility" preventing
  nearby social assists, contradicted by P99's current design. This is
  explicitly labeled speculation by its own author ("could easily be
  all wrong"), not confirmed. Given even P99 itself isn't settled here,
  treat like fizzle/resist — match our current implementation rather
  than chase an unresolved classic answer.
- 🟢 **NPC max melee damage: more precise formula found, refining the
  Game Mechanics reference entry.** For non-Giant, non-special-ability
  NPCs: `2×level + 2`. Giants and Spectres add a flat +20. Separately,
  for level 40+ normal NPCs: `100 + 4×level` (a different breakpoint
  formula for higher-level content). Worth a follow-up check against
  actual NPC data patterns if we want to verify our NPCs match this
  more precise version rather than the rougher estimate originally
  captured.
- 🔴 **"Training"/leash mechanics — significant finding, needs your
  decision, not a simple fix.** Whether NPCs should ever stop chasing a
  fleeing target ("leash") at distance is a genuinely disputed, hotly-
  argued topic on P99 itself. Strong community voices state plainly
  "mobs did not leash at any point through Velious" and call any
  leashing "not classic," while a P99 developer's own comment confirms
  a "lazy aggro" distance-based drop was *added* to P99 at some point
  (not originally present) — some argue any leashing that existed even
  in true classic was zone-specific (large outdoor Kunark zones) and
  possibly an unintended pathing bug rather than deliberate design.
  **Checked against our server: `Aggro:NPCAggroMaxDistanceEnabled =
  true`** (EQEmu's compiled default, never touched by any prior ADR) —
  NPCs currently drop aggro beyond 600 units. If true classic behavior
  was "mobs chase forever, no distance-based reset," this is a
  meaningful non-classic safety net currently active on our server.
  **However — this cuts both ways for us specifically.** Training/
  kiting danger is explicitly one of the "dangerous encounters" pillars
  our own VELIOUS_VISION.md wants preserved, arguing for disabling
  this. But we're a solo multibox server — an NPC that chases forever
  with no reset is a genuine, real safety risk when managing 6 clients
  at once, not just an authenticity question. This is a judgment call
  between classic accuracy and practical solo-multibox safety, not a
  clear bug — flagging for your decision rather than recommending
  either way.
- 🔲 Line-of-sight requirements for aggro and spell casting — not
  researched in this pass.
- ✅ **Feign Death break chance/re-aggro: well-documented, high
  confidence.** Below level 35, mobs fully "forget" you after a
  successful FD regardless of standing up. Above level 35: if the mob
  has already reset to its spawn point, 90% chance it won't re-aggro
  (10% it will); if still roaming/hasn't reset yet, only 80% chance it
  won't re-aggro (20% it will). Each subsequent re-feign further reduces
  re-aggro chance by roughly 20%. **Contested sub-question:** whether a
  *resisted* (not just landed) spell cast on a feigned player should
  break FD — real, unresolved community debate with disputed patch
  dates (some say ~2001, others argue changes came later, ~2005-2006,
  eventually partially "sold back" as a Monk AA). Treat the core
  re-aggro percentages as solid; treat the resisted-spell interaction
  like fizzle/resist (lower confidence).

## Regeneration & Character Stats

- 🟦 STA-to-HP conversion by class, Iksar/Troll regen bonus (Game
  Mechanics reference)
- 🟢 **Out-of-combat/"Rested" regen bonus: confirmed we should NOT have
  this.** A dedicated Agnarr-vs-P99 comparison page lists a "Rested"
  state (HP regen increasing the longer you sit, kicking in 30 seconds
  after combat) explicitly as an Agnarr-specific (later progression
  server) feature, distinct from classic/P99 behavior. Useful negative
  confirmation — we should not add anything resembling a modern
  "rested bonus" system. The existing, separate "sit to regen faster"
  mechanic is unrelated and already classic/expected.
- ✅ **Bind Wound: precise, high-confidence formula found.** Takes ~10
  seconds, interrupted by attacking or being attacked. Heals 1 HP per 4
  skill points at skill ≤200 (max 50 HP at 200 skill); 1 HP per 2.5
  skill points at skill 201+ (max 84 HP at 210 skill). Can only be used
  while target HP is below 50% (or 70% for users with 201+ skill) *at
  the moment bandaging finishes*, not when started. Every character's
  skill cap is `(Level×5)+5`, with class-specific higher caps allowing
  some classes past 200. **Check once convenient:** whether our
  `skill_caps`/healing-calculation source matches this exact formula
  and the 50%/70% threshold-at-completion behavior (not threshold-at-
  start, a subtle but meaningful timing distinction).

## Death & Corpses

- 🟡 **Normal corpse decay time (with items): confirmed classic value is
  7 days — but we deliberately deviate, already documented.** P99's own
  dedicated Corpse page states a normal player corpse decays "exactly 7
  days after it was created, regardless of level... online or offline."
  Our server's `Character:CorpseDecayTime` is set to ~24.86 days (the
  practical 32-bit integer ceiling) — this was a **deliberate ADR-002
  decision**, explicitly recorded as a known non-classic deviation for
  solo-play convenience, not an oversight. No action needed; flagging
  here only so the sweep doesn't mistake this for an undiscovered gap.
- ✅ **Resurrection window: verified correct.** `Character:CorpseResTime
  = 10,800,000ms = exactly 3 hours`, matching P99's documented value
  precisely. No action needed.
- ✅ **NPC empty corpse decay: verified correct.** `NPC:
  EmptyNPCCorpseDecayTime = 0` (instant), matching the wiki's "empty
  corpses usually decay instantly when the loot window is closed."
- 🟢 **NPC normal (minor) corpse decay: verified close enough.**
  `NPC:MinorNPCCorpseDecayTime = 450,000ms = 7.5 minutes`, essentially
  matching the wiki's "approximately seven minutes."
- 🟡 **NPC high-level (major) corpse decay: minor discrepancy, low
  priority.** `NPC:MajorNPCCorpseDecayTime = 1,500,000ms = 25 minutes`,
  vs. the wiki's documented "30 minutes after death" for level 55+ NPCs.
  A 5-minute gap — small enough that it's likely not worth a dedicated
  fix on its own, but worth batching in if we ever touch this rule for
  another reason.
- 🟢 **Player empty/naked corpse decay: flagged, reviewed, kept as-is.**
  `Character:EmptyCorpseDecayTime = 30,000ms = 30 seconds`. Community-
  documented classic values for a **player** dying completely naked
  range from 3 minutes up to 3 hours depending on era/level, meaningfully
  longer than our current setting. Raised for a decision; project lead
  has reviewed and elected to keep the current 30-second value as-is.
  Closed, not an open item.
- ⚠️ **Naked/empty player corpse decay: genuinely contested, era-
  dependent.** Community discussion shows three different remembered
  numbers depending on patch era: 3 minutes (earliest, pre-2001), 30
  minutes (a later intermediate figure), and 3 hours for a naked corpse
  above level 30 specifically (per a **Feb 21, 2001 patch** — which
  falls inside our Velious-and-earlier window, so is likely the
  correct target for us, not the earlier 3-minute figure). Lower
  confidence than the 7-day figure above; worth checking our
  `Character:EmptyCorpseDecayTime` (currently 30 seconds, per ADR-002)
  against whichever of these actually applies to *player* corpses
  specifically — ADR-002's 30-second value may have been written with
  NPC empty-corpse behavior in mind rather than player naked-corpse
  behavior, which appears to be a separate, longer timer historically.
- 🔴 **Shadowrest / corpse-summoner NPCs: confirmed NOT classic.**
  Multiple community members state directly this was added later,
  specifically to reduce corpse-recovery frustration, and was never
  part of original classic play. Not a bug to fix, just useful context
  if we ever consider adding any corpse-recovery convenience feature —
  doing so would be a deliberate, conscious non-classic QoL choice (our
  philosophy allows this), not something to mistake for authentic.
- **Informational, likely not actionable:** "hell levels" — dying at
  specific levels (31, 36, 41, 46, 55, 60, with 54 and 59 as "double
  hell") causes disproportionately painful exp loss, purely as a side
  effect of how the game's underlying per-level exp-requirement curve
  interacts with a flat-percentage death penalty. This pattern is
  driven by the hardcoded exp curve itself, not by any of ADR-002's
  rate rules (`ExpMultiplier` etc. affect *how fast* you gain exp, not
  the underlying per-level *requirement* curve the penalty is a
  percentage of) — so this should already hold true on our server
  without any specific action needed. Noted for completeness/interest
  rather than as an open item.
- 🔲 Corpse summoning rules/range beyond what's covered above
- 🔲 Item loss on death thresholds beyond ADR-002's DeathItemLossLevel
  rule value (worth confirming the *mechanic* itself — which items are
  eligible to be lost — matches classic, separate from the level
  threshold already set)

## Tradeskills

- ✅ **Success rate formula** — well-confirmed, explicitly stated by the
  wiki to be "present in the EQEmu server code" and independently
  verified by a community member's 4,000-combine spreadsheet:
  - Trivial ≤ 67: `Success% = MIN(Skill - Trivial + 66, 95)`
  - Trivial ≥ 68: `Success% = MIN(Skill - 0.75×Trivial + 51.5, 95)`
  - Hard floor: success is never below 5%, no matter how far under
    trivial the combine is (excepting a small number of intentional
    no-fail quest combines).
  - **Stats have zero effect on success rate** — only current skill and
    the recipe's trivial value matter. This is a specific, easy-to-get-
    wrong detail worth checking directly against our source.
- ⚠️ **Skill-up rate formula** — less settled than success rate. Governed
  by the *highest* of the relevant stat (INT/WIS generally; STR for
  Smithing; DEX for Fletching/Poison Making) — stat affects chance to
  *gain* a skill point, never success chance. Community-documented as a
  "two-pass" check (stat-vs-difficulty, then current-skill-vs-threshold),
  but the specific source for this is a 2004-dated live-EQ post whose
  applicability to our era is unconfirmed even by the P99 community
  itself. Treat the shape (stat governs skill-up, not success) as solid;
  treat the exact formula constants as lower-confidence.
- 🔴 **Cautionary example found — worth remembering for our own work:**
  a documented case of P99 *overcorrecting* toward unclassic difficulty:
  Magician pet-summoning research was implemented requiring sequential
  prerequisite combines (must successfully make a tier-24 pet before
  attempting tier-29, etc.) — a poster argues persuasively this is "as
  unclassic as it can be," since no other class's tradeskill research
  works this way, and it was apparently rarely if ever encountered by
  real classic players. This is a direct, concrete example of exactly
  the failure mode you flagged earlier in this project — "harder" was
  mistaken for "more classic." Worth keeping in mind if we ever
  implement or verify Magician pet research specifically.
- **Scoping note:** a community poster observes that most tradeskills
  have limited practical relevance on a Velious-locked server —
  Jewelcrafting, Alchemy, and some Tailoring are the main exceptions;
  most tradeskills "actually start to have value" once Luclin/PoP
  content exists. Worth keeping expectations calibrated when deciding
  how much verification effort this category deserves right now.
- 🔲 Skill level thresholds / trivial value data itself — not yet checked
  against our `tradeskill_recipe` table.

## Movement

- 🟦 Swimming skill mechanics (Sense Heading/Swimming skill fix)
- 🔲 Levitate interactions (combat, falling damage, zone restrictions)
- 🔲 Snare/root effect on run speed stacking rules

## Pets (non-charm)

- 🟦 Solo pet XP split (>50% damage = half XP), pet auto-dual-wield by
  class, pet weapon-swap/upgrade behavior (Game Mechanics reference)
- 🟡 **Pet leash/follow mechanics: researched, mixed confidence.**
  `/pet guard here` confirmed to have no distance limit at all — a pet
  will walk back to its guard spot from anywhere in the zone. `/pet
  attack [name]`'s targeting range is reported by the community as much
  larger in classic than currently on P99 ("in classic I could target a
  mob clear across West Karana and say pet attack... now I basically
  have to stick my shovel up the mob's bum"), though without a precise
  confirmed number — lower confidence, not independently verified
  against our source in this pass.
- 🔲 Pet command responsiveness (cast-time lag on pet commands, if any)

## Skills (General)

- 🟦 Sense Heading, Swimming (skill training mechanics fix)
- ⚠️ General skill-up rate formula (non-tradeskill) — no separate
  formula found distinct from the tradeskill skill-up mechanic already
  documented; same shape (governing stat determines chance to gain a
  point) and same lower confidence level. Not independently verified
  against our source in this pass.
- 🔲 Skill cap enforcement edge cases beyond what's already in
  `skill_caps` — not resolved in this pass.

## Economy / Vendors

- 🟦 Merchant pricing system, CHA-based haggling, greedy/non-greedy
  vendor mechanic (merchant pricing work)
- 🟢 **Shared bank slots: confirmed non-classic.** A dedicated forum
  thread states plainly "shared bank slots were added long after the
  classic (original + Kunark + Velious) era" — useful negative
  confirmation if this is ever considered as a QoL addition; doing so
  would be a deliberate non-classic choice, same category as
  Shadowrest. Standard (non-shared) per-character banking is unaffected
  and already expected/correct.
- 🔲 Item stacking rules by item type — not resolved in this pass, no
  specific rule surfaced.

## Not applicable / deliberately out of scope

- PvP-specific mechanics (Game Mechanics reference, PvP section) — not
  relevant to our cooperative solo/multibox server.
- AA / veteran rewards — should not exist at all for a Velious-scoped
  server; worth a quick confirmation they're genuinely absent rather
  than assuming, but not a "mechanic to tune," just a presence/absence
  check.

## Non-Classic Compendium — dedicated pass completed

P99's own curated list of confirmed non-classic deviations, with
developer reasoning. Highest-value findings for our project:

- ✅ **Spell scribing confirmed unfixable by an actual developer quote**
  — see Spellcasting section above. The single most authoritative
  confirmation found in this whole sweep.
- 🔴 **Zone Experience Modifiers (ZEM) — genuinely new, actionable
  finding.** The commonly-known ZEM values circulated online (and
  likely baked into PEQ's stock data, which our database originally
  derives from) come from a 2003 ShowEQ client data dump — **not
  classic**. P99's own devs have been incrementally correcting these
  as better evidence surfaces, over more than a decade, and still
  aren't done. This means our per-zone experience rates may not be
  classic-accurate, inherited from the same non-classic source
  everyone else started from. Given the scale (hundreds of zones) and
  P99's own decade-long incremental progress, this isn't a quick fix —
  but it's worth logging as a real, identified gap rather than an
  assumed-correct area, and worth prioritizing zones our characters
  actually level through first if ever tackled.
- 🟡 **Epic weapon level-46 equip requirement — confirmed P99-specific,
  uncertain if universally classic.** P99 requires level 46 to equip
  any epic weapon; their own page admits "it is unclear whether or not
  all epics on live required a specific level." Worth cross-referencing
  against the Class Epic Quest Reference document — if we ever
  implement epics, this requirement (or lack thereof) needs an explicit
  decision rather than assuming either way.
- 🟢 **Epic quest steps: confirmed our existing research is already
  correct.** The compendium's table of "Live vs. Classic Live" epic
  quest differences (Cleric, Magician, Wizard) — e.g., Cleric's classic
  version skips the Pearlescent Fragment/Skyfire step entirely — was
  cross-checked against the Class Epic Quest Reference document
  already built this session. Our Cleric notes already reflect the
  corrected/classic version (no Pearlescent Fragment or Skyfire
  mentioned), confirming that research was correctly sourced from P99's
  current pages rather than outdated "Live" guides found elsewhere.
  Added a note to that document for future context.
- 🟢 **Post-Luclin newbie armor quests (Kelethin Bard/Tranquilsong,
  Rivervale Druid/Moss Toe, etc.) confirmed out of scope** — genuinely
  Luclin+, never relevant to our Velious-scoped server. Good negative
  confirmation, no action needed.
- 🟡 **Dropping coin on the ground: technically classic for us,
  practically irrelevant.** Live didn't disable this until Nov 7, 2001
  — after Velious, before Luclin, so technically outside our "Velious
  and earlier" cutoff on the classic side. P99 disabled it early
  specifically to prevent RMT/scamming — concerns that don't really
  apply to a private solo/multibox server. Noted for completeness; not
  worth changing given the near-zero practical impact either way.
- 🟢 **Cross-validation of two items already flagged as disputed in
  this sweep:** P99's own "Unconfirmed Changes" list independently
  includes both "sneak pulling mechanics" and "FD memblur mechanics" —
  the same two disputes already logged in this checklist (social
  aggro/invis and Feign Death's resisted-spell interaction,
  respectively). Good confirmation these were correctly categorized as
  genuinely unresolved rather than something we should have been able
  to pin down.
- **Other confirmed non-classic, low-priority/niche, logged for
  completeness:** only two bags could be open at once in true classic
  (Titanium/RoF2 both allow unlimited — likely unfixable client-side for
  us too); Human/Erudite/Barbarian night vision is improved client-side
  from true classic (likely also unfixable); mana regen can visibly
  tick up-then-down due to a client/server calibration mismatch
  (Shaman-relevant, client-side, unclear if RoF2 exhibits this the same
  way as Titanium); boats use different models/pathing and grant
  temporary levitate while boarding (an acknowledged, reasonable
  technical compromise); damage shield timers possibly running 5
  minutes instead of a classic 15 (unreferenced/unconfirmed even by
  this page).

---

## Progress log

- **Harm Touch investigation: resolved (separate from this sweep, but
  using the same technique).** Confirmed via P99's dedicated wiki page
  that classic Harm Touch has a 72-minute recast. Our database had
  three entries active for Shadow Knight at level 1 — two named "Harm
  Touch" with an incorrect 30-second recast (ids 88, 2821), and one
  named "Harmful Touch" with the correct 72-minute recast (id 2774).
  Fix identified: disable ids 88 and 2821, keep 2774 active.
- **Tradeskills: done, high confidence on success rate, lower on
  skill-up rate.** See above.
- **Resist checks: done, low confidence — genuinely underdocumented
  even by P99.** See above. Same category as fizzle rate.
- **MCP verification pass completed for two items:**
  - Spell scribing/memorization: confirmed NOT fixable via any existing
    rule — the mechanic simply isn't implemented server-side at all.
    Downgraded from actionable to "known gap, no easy lever."
  - Charm break mechanic: confirmed ALREADY correctly implemented and
    configured (`Spells:CharmBreakCheckChance=25`,
    `Pets:LivelikeBreakCharmOnInvis=true`, both at sensible defaults).
    No fix needed — a genuine, verified confirmation rather than an
    open question.
- **Corpse/Death mechanics: researched and verified against live
  database.** Resurrection window and NPC corpse decay times (normal
  and empty) all confirmed correct or close enough not to need action.
  NPC high-level corpse decay is off by 5 minutes (25 vs. 30 min) —
  minor, low priority. Player empty/naked corpse decay flagged, project
  lead reviewed and elected to keep the current value as-is — closed.
- **Charm duration formula: researched and checked against source.**
  Genuinely contested even on the wiki itself (Enchanter page claims CHA
  extends duration; a forum tester's own data found no CHA effect).
  Checked our source directly — CHA only appears in Lull's resist
  check, not charm's. Our implementation matches the "no CHA effect"
  camp. Not treated as a bug given the wiki's own internal disagreement;
  logged as a low-confidence item like fizzle/resist.
- **Social aggro / assist radius: researched and checked against
  source.** Initial data (95.6% of NPCs showing assistradius=0) looked
  like a possible gap; tracing the actual code showed this is a
  non-issue — a sensible fallback to the regular aggro radius. Also
  surfaced a genuinely disputed question (does invis/sneak block social
  aggro classically? — P99 currently says no, with real community
  debate about whether that's accurate) and a more precise NPC melee
  damage formula than originally captured.
- **Remaining categories swept:** Stun/riposte/dodge/parry (low
  confidence, same bucket as fizzle/resist), Feign Death (high
  confidence, solid percentages found), Bind Wound (high confidence,
  precise formula found), out-of-combat "Rested" regen (confirmed we
  should NOT have this), general skill-up rate (inherits tradeskill's
  confidence level), pet leash/follow (mixed confidence), mesmerize and
  root interactions (confirmed non-stacking / nuke-breaks-root),
  shared bank slots (confirmed non-classic), and — the most significant
  finding of this batch — **NPC "leash"/training distance mechanics**,
  which is currently enabled on our server (`Aggro:
  NPCAggroMaxDistanceEnabled=true`) but is a genuinely disputed,
  possibly non-classic addition, and cuts against our own solo-multibox
  safety needs if disabled. Flagged prominently for your decision.

## Sweep status: substantially complete

Every major category originally listed has now been researched at
least once, with most also checked against our actual source code or
live database where MCP access allowed. Remaining fully-unresolved
items are genuinely small (line-of-sight for aggro/casting, snare
stacking rules, item stacking rules, skill cap enforcement edge cases)
and can be picked up opportunistically rather than needing a dedicated
push. The one item requiring your direct decision is the NPC leash/
training mechanic above — everything else is either confirmed correct,
confirmed non-classic (and intentionally not changed), or logged as
genuinely low-confidence/contested with no better answer available.

**Recommended next steps, in order:**
1. ~~Decide on the NPC leash/training mechanic~~ — resolved: disabling
   it, SQL provided, matching project lead's stated preference for
   classic chase-forever behavior given the only real risk in a
   solo-multibox context is personal error, not other players training
   mobs onto them.
2. ~~Non-Classic Compendium dedicated pass~~ — done, see above.
3. **New, genuinely open item worth prioritizing next: Zone Experience
   Modifiers (ZEM).** Likely inherited non-classic (2003 ShowEQ-sourced)
   values from PEQ's original data. Given the scale, best approached
   incrementally — starting with zones our actual characters level
   through, not all zones at once.
4. Batch together the small number of genuinely fixable items found
   across this whole sweep (Harm Touch already done; NPC leash toggle
   pending your SQL run) into any future correction pass.
