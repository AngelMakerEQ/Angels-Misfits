# Mechanics Review

## Purpose

This is the single standing document for game-mechanic verification status. It replaces the former `docs/development/WIP/MECHANICS_REVIEW.md` checklist and three dated point-in-time assessments (HP/Mana Regen Runtime Review, Spell Component Consumption Review, Mechanics Review Final Recommendations), all retired and folded in here via ADR-014.

The purpose is unchanged from the original sweep: catch "unknown unknowns" — mechanics neither research nor memory would think to question — by systematically checking each gameplay category against P99's wiki/bug forums and, where possible, this project's own EQCode source and live database. Update this document in place as items close or new research lands; do not create parallel tracking documents (that fragmentation is exactly what this consolidation is meant to end).

**Status legend:**
- 🟢 **Closed — confirmed correct.** Checked against source/live database (not just documentation) and already matches the intended target.
- 🟡 **Closed — accepted current behavior.** Researched, but either contested even within P99's own community, or resolved by project-lead decision. Not being pursued further absent new evidence.
- 🔵 **Closed — deliberate deviation.** Confirmed non-classic, kept intentionally per an ADR or explicit project-lead call.
- 🔴 **Open — actionable.** A specific, well-evidenced gap with a clear next step.
- 🔲 **Open — not yet researched.** On the list, no work done.

---

## Genuinely Open Items (in priority order)

This is the actual to-do list. Everything else in this document is closed in one of the three closed categories above and does not need revisiting absent new evidence.

### 1. 🔴 Combat — remaining actionable item

- Item stacking rules by item type beyond the narrowly scoped phase-1 Classic
  migration (Bone Chips, Bat Wings, Spiderling Silk, and Peridots; see
  `scripts/2026-08-06_classic_item_stack_size_phase_1.sql`). The migration is
  committed but not yet applied live: direct verification on 2026-08-06 found
  all four rows still at stacksize 100. Further changes must remain
  item-by-item: Classic ammunition legitimately uses 100-item stacks, so a
  blanket stack-size conversion is incorrect.

### 2. 🔲 Not yet researched — small, low-effort items

Carried forward from the original sweep, none individually large: pet command responsiveness (cast-time lag on pet commands, if any).

### 3. 🔲 Confirmation-only, low priority (Tier 2 — do not proactively tune)

Preserve current EQEmu behavior on all of these unless a runtime test finds an actual discrepancy against a real classic target. Do not infer a correction from P99 forum disagreement or a modern-sounding rule name alone: weapon damage caps/max-damage formula/weighted D20/proc rate/backstab formula (conceptually documented, not checked against this project's source); Bind Wound's 50%/70%-at-completion threshold behavior; AA/veteran reward and guild inaccessibility under the Velious gate (near-certain already correct via the expansion gate, worth one quick confirmation rather than an assumption).

---

## Closed — Confirmed Correct (🟢)

- **HP/mana regeneration (2026-08-09, closes the 2026-08-01/08-08 items above).**
  `Character:UseClassicRegen` (ruleset 1) built into both `zone.exe` and
  `world.exe`, deployed, and verified live via `#mystats` on Angel (level 40
  Iksar Necromancer). `CalcHPRegen()` now calls the pre-existing
  `Client::LevelRegen()` classic per-level-bracket table (previously only
  reachable via `Bot::LevelRegen()`) instead of the live-era `base_data`
  curve; `CalcManaRegen()` uses the classic flat-1-standing /
  `floor(skill/12)`-sitting formula instead of the `2 + skill/15` curve.
  Full investigation, table, and deployment notes (including a
  `world.exe`-rebuild pitfall worth reading before touching any other
  custom rule) in **ADR-021**. The native in-game Character/Stats window
  does not reflect this — that figure is computed client-side and is not a
  valid way to verify any server-side regen rule; use `#mystats`/`#showstats`.

- **Era-containment cleanup (2026-08-05).** Live MCP queries confirmed zero
  active-level Beastlord and Berserker grants, `don_nest_unlocked` disabled,
  and the Velious expansion gate unchanged. The committed
  `2026-08-01_era_containment_cleanup.sql` has been applied successfully.
- **Charm break mechanic.** `Spells:CharmBreakCheckChance = 25` (25% chance per buff tick) matches EQEmu's own developer-commented calibration against a documented ~68-tick average charm duration at 0% resist. `Pets:LivelikeBreakCharmOnInvis = true` also confirmed at its correct default.
- **Spell recast/recovery enforcement.** `CastedSpellFinished()` rejects an
  unexpired per-spell reuse timer server-side, then starts that timer from the
  spell's stored recast value after a successful cast. Linked spell timers and
  item-click timers are checked separately. This prevents client/UI bypasses;
  no data or rules change is needed.
- **Spellcasting line-of-sight.** Detrimental single-target spells are checked
  against both geometric and water line of sight in `SpellFinished()`, after
  the cast completes; area effects test each target at resolution. This is the
  pre-September-2002 Classic timing rather than the later cast-start check, so
  no change is needed.
- **Melee/ranged critical hits.** The source limits innate critical hits to
  level-12+ Warriors for melee, Rangers for archery, and Rogues for throwing,
  with no ordinary spell crits in the Classic era. The active critical
  difficulties retain the EQEmu Classic defaults (melee 8,900; archery 3,400;
  throwing 1,100), and NPC critical hits are disabled. This agrees with P99's
  documented Classic class restrictions; no rule or data change is needed.
- **Pet attack engagement range.** `Pets:AttackCommandRange` is the default
  40,000 squared units (200 units), matching P99's archival Classic testing.
  No range adjustment is justified. This does not decide the separate,
  disputed historical ability to use `/pet attack [name]` as a zone-wide
  target-discovery tool.
- **Aggro line-of-sight.** `CheckWillAggro()` and social-assist evaluation both
  require `CheckLosFN()` before an NPC aggroes. This matches the P99 Classic
  baseline: an NPC needs line of sight to body-aggro a player or socially
  assist another NPC. Zone-specific outdoor map geometry remains a map-data
  matter, not a global ruleset discrepancy.
- **Root/snare movement stacking.** Source confirms Root and Snare are
  separate effects. A Snare overwrites a positive movement-speed effect such
  as Spirit of Wolf, while Spirit of Wolf cannot overwrite an existing Snare;
  Root leaves the movement effect intact. This matches the January 2001
  Classic behavior. `Spells:SnareOverridesSpeedBonuses` does not govern the
  normal Classic Snare line and requires no change.
- **Mesmerize.** Confirmed non-stacking (a second cast before the first expires fails to extend it) and confirmed to interrupt a casting mob's spell for free (no mana cost to the caster) on a successful land.
- **Root.** Direct-damage spells confirmed able to break Root early (dedicated P99 Spell page). The specific "20% of damage dealt" root-break figure remains ambiguous on PvE-general vs. PvP-specific applicability — not fully resolved, low priority.
- **Social aggro / assist radius fallback.** Only 4.4% of NPCs (2,957/67,530) have a nonzero explicit `assistradius`; checking `aggro.cpp` confirms the fallback (`if (assist_range > aggro_range) aggro_range = assist_range`) correctly uses the NPC's regular ADR-003 aggro radius otherwise. Initial appearance of a gap was a false alarm — no fix needed.
- **NPC max melee damage formula** (refines the general reference): non-Giant/non-special NPCs use `2×level + 2`; Giants and Spectres add a flat +20; level 40+ normal NPCs separately follow `100 + 4×level`. Not yet cross-checked against actual NPC data patterns, but the formula itself is confirmed — low-priority follow-up if ever revisited.
- **Feign Death re-aggro percentages.** Below level 35: full forget on success. Above 35: 90% no-re-aggro if the mob already reset to spawn (10% will), 80% if still roaming (20% will); each re-feign further reduces re-aggro chance ~20%. High confidence.
- **Out-of-combat "Rested" regen bonus: confirmed we should NOT have this.** Agnarr-specific (a later progression server), not classic/P99 behavior. Useful negative confirmation, not an open item.
- **Bind Wound formula.** ~10 seconds, interrupted by attacking/being attacked. 1 HP per 4 skill points at skill ≤200 (max 50 HP); 1 HP per 2.5 skill points at skill 201+ (max 84 HP at 210). Usable only while target HP is below 50% (70% at 201+ skill) *at the moment bandaging finishes*, not when started. High confidence on the formula; the completion-time threshold behavior against this project's own source is Tier 2 (unconfirmed, low priority).
- **Resurrection window.** `Character:CorpseResTime = 10,800,000ms` = exactly 3 hours, matching P99 precisely.
- **Corpse summoning.** The live `Summon Corpse` spell matches the Classic
  level-39 Necromancer version: 700 mana, 5-second cast, Jade Inlaid Coffin
  reagent, same-zone corpse lookup, and a group-member requirement. No
  additional range rule or data correction is needed.
- **Player-corpse item transfer.** Once the deliberately selected level-15
  item-loss threshold is met, the source transfers worn equipment, general
  inventory, contents of carried bags, and coin to the corpse in one database
  transaction. This is the Classic all-possessions corpse behavior; no item
  eligibility correction is needed.
- **NPC empty corpse decay.** `NPC:EmptyNPCCorpseDecayTime = 0` (instant), matching "usually decay instantly when the loot window is closed."
- **NPC minor corpse decay.** `NPC:MinorNPCCorpseDecayTime = 450,000ms` (7.5 min), essentially matching "approximately seven minutes."
- **Spell component consumption — data and cast-path logic confirmed correct (2026-08-01).** `Character:PetsUseReagents = true`; all 774 level-50-playable spells with components resolve their component IDs to valid `items` rows (the 12 unmatched IDs are test/NPC-only records, not playable classic spells). The EQEmu cast path performs the fizzle check *before* component handling, so a fizzle costs 1/4 mana and no reagent, and an interrupted cast never reaches component handling either — both are the intended classic behavior, not a gap. Necromancer pet Bone Chip requirements (1 for Cavorting Bones, 2 for the later pet line) confirmed correct. **No SQL change was or is needed.** An in-game smoke test remains optional operational confirmation, not an actionable verification gap.

---

## Closed — Accepted Current Behavior (🟡)

Researched and found genuinely contested even within P99's own community (its own wiki carries explicit "Todo" placeholders or documented internal disagreement), or resolved by an explicit project-lead call. Not pursued further absent materially new evidence — re-litigating these has a proven low return.

- **Spell fizzle rate.** 15+ years of unresolved P99 forum dispute in both directions (too high at max skill, too low at low skill); one analysis suggests the underlying formula itself may be miscalibrated even on P99. Match whatever this project's EQCode source already implements.
- **Resist checks / resist rate scaling.** P99's own Statistics page states its resist-formula information "is not necessarily correct for P99... but it's probably pretty close," with an explicit unfilled "(Todo)" placeholder for the actual formula. No confidence-worthy target exists anywhere, including on P99 itself.
- **Charm duration formula / CHA's role.** The Enchanter class page claims CHA extends charm duration; independent forum testing found no measurable CHA effect. This project's own source checked directly: CHA only appears in `aggro.cpp` for Lull's resist check, nowhere in charm break-check logic — i.e. this implementation matches the "no CHA effect" camp. Given the wiki's own internal disagreement, not treated as a bug.
- **Stun duration and resist mechanics.** Mostly documented in PvP-specific, actively-disputed threads not relevant to this cooperative server; P99's own Game Mechanics page admits "values still being tuned."
- **Spell interruption/channeling.** Player casts use the existing
  skill-based concentration calculation; NPC casts use the upstream generic
  85% concentration baseline, reduced by incoming hits and movement. The
  historical NPC interruption target is disputed and there is no rules-only
  correction. A source patch was intentionally not pursued after its separate
  build/deployment test proved incompatible with the live zone binary; preserve
  current behavior unless a concrete player-visible problem emerges.
- **Riposte/dodge/parry/block.** No clean formula found, mostly qualitative (AGI affects Dodge/Defense/Parry skill-up rate and avoidance AC, with a breakpoint around 75 AGI; a separate low-HP AGI penalty starts near 25% health). Same bucket as fizzle/resist.
- **Bash, slam, and kick details.** The Warrior kick stun gate was corrected
  from 56 to the Classic value of 55 on 2026-08-05. The remaining Bash/Slam
  path retains the EQEmu defaults (base damage 2, shield-AC divisor 25,
  two-second stun when a stun lands). P99 evidence supports the level gate and
  duration but not a reliable universal landing/interrupt formula, so no
  further tuning is justified.
- **Sneak/invisibility and social aggro.** P99's Aggro page states plainly that sneak/invis "no longer prevent social aggro on P99" — the phrase "no longer" implies a change from an earlier P99 implementation, and a forum thread theorizes true classic behavior differed, explicitly labeled speculation by its own author. Even P99 itself isn't settled here; match current implementation.
- **Feign Death: resisted-spell interaction.** Whether a resisted (not landed) spell cast on a feigned player should break FD is a real, disputed community question with conflicting patch dates (~2001 vs. ~2005-2006). The core re-aggro percentages above are solid; this sub-question is not.
- **Normal player corpse decay (with items), ~24.86 days vs. classic 7 days.** Deliberate ADR-002 deviation for solo-play convenience, explicitly recorded there as a known non-classic choice, not an oversight.
- **Player empty/naked corpse decay, 30 seconds.** Community sources describe classic values ranging 3 minutes to 3 hours depending on era (with a Feb 21, 2001 patch — inside this project's window — suggesting 3 hours for a naked corpse above level 30). Raised for a decision; **project lead reviewed and elected to keep the current 30-second value.** Closed by decision, not by evidence resolution.
- **NPC major (high-level) corpse decay: 25 min vs. documented 30 min.** A 5-minute gap, small enough not to warrant a dedicated fix on its own — batch in if this rule is ever touched for another reason.
- **General (non-tradeskill) skill-up rate formula.** No formula distinct from the tradeskill skill-up mechanic was found; same shape (governing stat determines chance to gain a point), same lower confidence, not independently verified against source.
- **Skill-cap edge cases.** ADR-013's final comprehensive post-fix sweep found
  no remaining functional cap outliers in the eight in-scope Classic classes.
  The apparent exceptions were either intentionally inert unavailable skills
  or explicitly excluded tradeskills; no further cap migration is needed.
- **Pet leash/follow mechanics.** `/pet guard here` is confirmed to have no distance limit. The actual 200-unit `/pet attack` engagement range is confirmed correct above; only the historical zone-wide target-discovery behavior of `/pet attack [name]` remains disputed and is not worth custom implementation.

---

## Closed — Deliberate Deviation (🔵)

Confirmed non-classic and kept intentionally. Listed so the sweep never mistakes these for undiscovered gaps.

- **Spell scribing/memorization speed.** P99 developer Telin, quoted directly on P99's Non-Classic Compendium: classic scribing/memorizing took meaningfully longer, scaling with level and spell level, and "cannot be fixed at this time due to client limitations." This matches this project's own source tracing (no timing logic anywhere in the scribe/memorize path). **Confirmed unfixable, not merely unresearched** — this project is on RoF2 rather than P99's Titanium, so the exact severity may differ, but no fix is expected from either side.
- **Shadowrest / corpse-summoner NPCs.** Confirmed added post-classic specifically to reduce corpse-recovery frustration. Not present here; if corpse-recovery QoL is ever wanted, that would be a deliberate, conscious non-classic choice (permitted under project philosophy), not a restoration of something authentic.
- **Shared bank slots.** Confirmed added well after the classic/Kunark/Velious era. Standard (non-shared) per-character banking is correct and unaffected.
- **Zone Experience Modifiers (ZEM).** The commonly circulated ZEM values (likely baked into PEQ's stock data this database derives from) trace to a 2003 ShowEQ client dump — not classic. P99 itself has been incrementally correcting these for over a decade and still isn't done. **Explicitly deprioritized per PROJECT_STATUS.md** — base XP pacing (`Character:ExpMultiplier`, ADR-002) already covers the practical leveling-speed concern this would address; a hundreds-of-zones ZEM correction is not planned. Listed here as closed-by-deprioritization, not as a live actionable item — a prior draft of this document listed it as actionable, which was incorrect and is corrected here.
- **Epic weapon level-46 equip requirement.** P99-specific; P99 itself admits it's unclear whether this was universal on live. Tracked as an explicit open decision in `EPIC_QUESTS_REVIEW.md`, not here — this project has not yet adopted or rejected it.
- **Dropping coin on the ground.** Technically classic through Nov 7, 2001 (post-Velious, pre-Luclin) — P99 disabled it early specifically for anti-RMT reasons that don't apply to a private solo/multibox server. Noted for completeness; not worth changing given near-zero practical impact.
- **NPC "leash"/training-distance mechanic.** `Aggro:NPCAggroMaxDistanceEnabled = false` — NPCs chase indefinitely rather than giving up at a fixed distance, restoring classic chase-until-caught behavior. Logged directly (no ADR), confirmed still correctly disabled as of the 2026-08-01 mechanics review pass.
- **Other confirmed non-classic, low-priority/niche (client-side, likely unfixable on this client generation regardless):** only two bags open at once in true classic (Titanium/RoF2 both allow unlimited); Human/Erudite/Barbarian night vision improved from true classic; mana regen visibly ticking up-then-down from a client/server calibration mismatch (Shaman-relevant; unclear if RoF2 exhibits this the same way as Titanium); boats using different models/pathing and granting temporary levitate while boarding (an acknowledged reasonable technical compromise); damage shield timers possibly running 5 minutes instead of a classic 15 (unreferenced even by the source page, lowest confidence item in this whole list).

---

## Closed Reference Material (already documented elsewhere — 🟦 in spirit, not repeated here)

These categories are fully covered in existing documents and are not duplicated in this review:

- Mana calculation formula, Meditate mana-per-tick ratio, buff level-range restrictions, detrimental AE 25-target cap, STA-to-HP conversion by class, Iksar/Troll regen bonus *(as a documented target — its runtime correctness is item 1 above)*, weapon damage caps, weighted D20, proc rate, backstab formula, NPC max melee damage estimate, dual-wield chance, giants/dragons cannot be stunned/mesmerized, solo pet XP split, pet auto-dual-wield, pet weapon-swap behavior — all in `docs/research/GAME_MECHANICS_REFERENCE.md`.
- NPC combat stats (HP/damage/AC/resists/aggro radius) — ADR-003. Aggro radius methodology specifically — ADR-003's per-NPC midpoint approach.
- NPC gate-at-20%-health, 25% HP regain after gating, 3-second post-spawn aggro immunity, direct-vs-indirect hate — `docs/research/GAME_MECHANICS_REFERENCE.md`.
- Sense Heading / Swimming skill training mechanics — logged directly in `CHANGELOG.md`, no open items.
- Merchant pricing, CHA-based haggling, greedy/non-greedy vendor mechanic — logged directly in `CHANGELOG.md`.
- Tradeskill success-rate formula — confirmed correct and present in EQEmu server code, independently verified by a 4,000-combine community spreadsheet: `Success% = MIN(Skill - Trivial + 66, 95)` for Trivial ≤ 67, `MIN(Skill - 0.75×Trivial + 51.5, 95)` for Trivial ≥ 68, hard floor 5%, stats have zero effect on success rate. **Cautionary note for future tradeskill work:** P99's Magician pet-research sequential-prerequisite requirement is a documented example of P99 itself overcorrecting toward unclassic difficulty — a concrete precedent for "harder was mistaken for more classic," worth remembering if this project ever implements or verifies Magician pet research.
- Skill cap ceiling (all classes, not just climb rate) — ADR-013. This closes what earlier drafts of this document listed as an open "skill cap enforcement edge case."

---

## Progress Log

- **2026-07-23 to 2026-07-28:** Original sweep conducted category-by-category (Spellcasting, Charm/Mez/Root/Snare, Combat, Aggro/AI, Regen, Death/Corpses, Tradeskills, Movement, Pets, Skills, Economy). Every major category researched at least once; most cross-checked against source or live database where MCP access allowed.
- **2026-07-28:** NPC leash/training-distance mechanic identified as the one item requiring a direct project-lead decision; resolved same day (disabled, logged in `CHANGELOG.md`).
- **2026-07-30:** Priority order rewritten to focus on HP regen, mana regen, casting, and combat — the categories closest to core moment-to-moment gameplay feel — ahead of the previously-listed ZEM-first order.
- **2026-08-01:** HP/Mana regeneration runtime review. Identified the `CalcHPRegen()` racial-bonus gap (item 1 above, still open) and the `Character:OldMinMana` mana-regen fix (item 2, applied). Spell component consumption reviewed and confirmed correct (no SQL change needed). Era-containment cleanup SQL drafted for the confirmed Beastlord/Berserker/DoN-flag conflicts.
- **2026-08-02:** Skill cap ceiling defect found and fixed across 8 classes (ADR-013), closing what had been an open "skill cap enforcement edge case." Necromancer illusion-height and pet-model-race defects found and corrected (ADR-012); Part 2 of that ADR (485→85 pet race correction) remains pending live application per ADR-012's own status.
- **2026-08-02:** This document consolidated from the WIP checklist plus three dated assessments, with every item re-audited for true open/closed status rather than carried forward by assumption (see ADR-014). The most consequential correction made during that re-audit: ZEM was miscategorized as still-actionable in the prior WIP draft despite being explicitly deprioritized in `PROJECT_STATUS.md` — now correctly closed as a deliberate deprioritization.
- **2026-08-08:** HP/mana regen investigated in full via a live-character comparison (Angel), correcting the 2026-08-01 root-cause guess for item 1 (it's `InnateSkills[InnateRegen]`, not the dead `BaseHPRegenBonusRaces` rule, that doubles Iksar/Troll regen — the defect is the live-era `base_data` baseline being doubled, not a missing racial multiplier) and confirming item 2's standing-mana-regen-0 anomaly is real. **ADR-021** written; a `Character:UseClassicRegen`-gated source patch drafted for both `CalcHPRegen()` and `CalcManaRegen()` (`zone/client_mods.cpp`) plus its supporting rule migration (`scripts/2026-08-08_classic_regen_formulas.sql`). Not yet built or deployed — items 1 and 2 remain 🔴 open (root cause now understood and fix drafted, but nothing is verified live yet), not closed to 🟢.

## Suggested Order of Attack

Build and deploy ADR-021's regen source patch, then re-verify both HP and mana regen in-game per its verification section — this closes out items 1 and 2, the last foundational pieces of the original HP-regen/mana-regen/casting/combat priority order. After that, move to the genuinely unresearched casting/combat items (spell interruption, recast/recovery enforcement, LoS, crit chance, bash/kick) — treating everything in the Accepted Current Behavior section as settled unless materially new evidence appears.
