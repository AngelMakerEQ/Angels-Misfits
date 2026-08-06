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

### 1. 🔴 HP regeneration — racial bonus likely not applied in the live code path

**Highest priority: foundational, and a real engineering defect, not a data gap.** Source review (2026-08-01) traced `CalcHPRegen()` in the current upstream EQEmu implementation: it takes its baseline from `base_data.hp_regen` and does **not** read `Character:BaseHPRegenBonusRaces` (the rule that is supposed to grant Iksar/Troll their faster regen). A separate `LevelRegen()` routine does read that bitmask, but it is not the function the tick path actually calls. At level 40, live `base_data` supplies an HP baseline of 6 regardless of race.

This is a credible defect: the configured Iksar/Troll bonus (`Character:BaseHPRegenBonusRaces = 4352`, confirmed correctly set) may currently have no effect. `base_data` itself must **not** be changed to compensate — ADR-004 already validated it against the classic client file, and changing it would affect every race, not just the two intended.

**Required next step (runtime test, not yet performed):** compare a level-40 Iksar/Troll character against a level-40 non-Iksar/Troll character of the same class, both at full buffs/AA/item-neutral state, over multiple 6-second ticks, standing and sitting. Expected under the current (likely buggy) code: no racial difference (~+6 HP/tick for both at level 40). If confirmed, the fix is a small server-source patch adding the existing `BaseHPRegenBonusRaces` modifier into `CalcHPRegen()`, followed by rebuild and re-test — not a database change.

### 2. 🔴 Mana regeneration — fix applied, runtime verification still outstanding

`Character:OldMinMana` was set `true` in ruleset 1 (`scripts/2026-08-01_classic_minimum_mana_regen.sql`, applied 2026-08-02 per commit history). This restores the classic floor of 2 mana/tick sitting and 1/tick standing at zero Meditate skill, without altering the normal Meditate formula. **Not yet independently confirmed live in-game** — the recommended test (a character with zero Meditate, before/after comparison, expecting +1 standing / +2 sitting) has not been recorded as performed. Close this out with an in-game tick count once convenient; the SQL change itself is not in question, only whether the server picked it up correctly (ruleset reload requires a full World/Zone restart).

### 3. 🔴 Casting — genuinely unresearched, not contested

Four items with no research pass done at all, distinct from the contested/accepted items in the closed section below:
- Spell interruption (movement/melee-push interrupt chance).
- Spell recast/recovery time enforcement — confirming these are actually enforced server-side at the intended values, not just present in the stored data (component consumption below is the cautionary precedent: correct data does not guarantee correct runtime enforcement).
- Spell component consumption on interruption/fizzle specifically as a runtime behavior — see the Spell Component Consumption item below; the *data* is confirmed correct and no SQL change is needed, but the smoke test confirming runtime behavior has not been recorded as performed.
- Line-of-sight requirements for spellcasting.

### 4. 🔴 Combat — genuinely unresearched, not contested

- Critical hit chance formula (distinct from critical hit *damage*, already documented — see Closed Reference Material below).
- Bash/kick/other combat skill-based special attack mechanics.
- Line-of-sight for aggro.
- Snare/root stacking rules on run speed (no specific stacking rule has been found beyond general debuff-slot behavior).
- Item stacking rules by item type.

### 5. 🔲 Not yet researched — small, low-effort items

Carried forward from the original sweep, none individually large: pet command responsiveness (cast-time lag on pet commands, if any); corpse summoning rules/range beyond configured decay timers; item-loss-on-death mechanic itself (which items are eligible to be lost, separate from the already-set `DeathItemLossLevel` threshold); skill cap enforcement edge cases beyond the ceiling fix in ADR-013.

### 6. 🔲 Confirmation-only, low priority (Tier 2 — do not proactively tune)

Preserve current EQEmu behavior on all of these unless a runtime test finds an actual discrepancy against a real classic target. Do not infer a correction from P99 forum disagreement or a modern-sounding rule name alone: weapon damage caps/max-damage formula/weighted D20/proc rate/backstab formula (conceptually documented, not checked against this project's source); Bind Wound's 50%/70%-at-completion threshold behavior; AA/veteran reward and guild inaccessibility under the Velious gate (near-certain already correct via the expansion gate, worth one quick confirmation rather than an assumption).

---

## Closed — Confirmed Correct (🟢)

- **Era-containment cleanup (2026-08-05).** Live MCP queries confirmed zero
  active-level Beastlord and Berserker grants, `don_nest_unlocked` disabled,
  and the Velious expansion gate unchanged. The committed
  `2026-08-01_era_containment_cleanup.sql` has been applied successfully.
- **Charm break mechanic.** `Spells:CharmBreakCheckChance = 25` (25% chance per buff tick) matches EQEmu's own developer-commented calibration against a documented ~68-tick average charm duration at 0% resist. `Pets:LivelikeBreakCharmOnInvis = true` also confirmed at its correct default.
- **Mesmerize.** Confirmed non-stacking (a second cast before the first expires fails to extend it) and confirmed to interrupt a casting mob's spell for free (no mana cost to the caster) on a successful land.
- **Root.** Direct-damage spells confirmed able to break Root early (dedicated P99 Spell page). The specific "20% of damage dealt" root-break figure remains ambiguous on PvE-general vs. PvP-specific applicability — not fully resolved, low priority.
- **Social aggro / assist radius fallback.** Only 4.4% of NPCs (2,957/67,530) have a nonzero explicit `assistradius`; checking `aggro.cpp` confirms the fallback (`if (assist_range > aggro_range) aggro_range = assist_range`) correctly uses the NPC's regular ADR-003 aggro radius otherwise. Initial appearance of a gap was a false alarm — no fix needed.
- **NPC max melee damage formula** (refines the general reference): non-Giant/non-special NPCs use `2×level + 2`; Giants and Spectres add a flat +20; level 40+ normal NPCs separately follow `100 + 4×level`. Not yet cross-checked against actual NPC data patterns, but the formula itself is confirmed — low-priority follow-up if ever revisited.
- **Feign Death re-aggro percentages.** Below level 35: full forget on success. Above 35: 90% no-re-aggro if the mob already reset to spawn (10% will), 80% if still roaming (20% will); each re-feign further reduces re-aggro chance ~20%. High confidence.
- **Out-of-combat "Rested" regen bonus: confirmed we should NOT have this.** Agnarr-specific (a later progression server), not classic/P99 behavior. Useful negative confirmation, not an open item.
- **Bind Wound formula.** ~10 seconds, interrupted by attacking/being attacked. 1 HP per 4 skill points at skill ≤200 (max 50 HP); 1 HP per 2.5 skill points at skill 201+ (max 84 HP at 210). Usable only while target HP is below 50% (70% at 201+ skill) *at the moment bandaging finishes*, not when started. High confidence on the formula; the completion-time threshold behavior against this project's own source is Tier 2 (unconfirmed, low priority).
- **Resurrection window.** `Character:CorpseResTime = 10,800,000ms` = exactly 3 hours, matching P99 precisely.
- **NPC empty corpse decay.** `NPC:EmptyNPCCorpseDecayTime = 0` (instant), matching "usually decay instantly when the loot window is closed."
- **NPC minor corpse decay.** `NPC:MinorNPCCorpseDecayTime = 450,000ms` (7.5 min), essentially matching "approximately seven minutes."
- **Spell component consumption — data and cast-path logic confirmed correct (2026-08-01).** `Character:PetsUseReagents = true`; all 774 level-50-playable spells with components resolve their component IDs to valid `items` rows (the 12 unmatched IDs are test/NPC-only records, not playable classic spells). The EQEmu cast path performs the fizzle check *before* component handling, so a fizzle costs 1/4 mana and no reagent, and an interrupted cast never reaches component handling either — both are the intended classic behavior, not a gap. Necromancer pet Bone Chip requirements (1 for Cavorting Bones, 2 for the later pet line) confirmed correct. **No SQL change was or is needed.** The optional in-game smoke test (cast with exact/insufficient components, force a fizzle) remains an operational nice-to-have, not a blocking verification gap — folded into item 3 above only as a "hasn't been recorded as run" note, not a data concern.

---

## Closed — Accepted Current Behavior (🟡)

Researched and found genuinely contested even within P99's own community (its own wiki carries explicit "Todo" placeholders or documented internal disagreement), or resolved by an explicit project-lead call. Not pursued further absent materially new evidence — re-litigating these has a proven low return.

- **Spell fizzle rate.** 15+ years of unresolved P99 forum dispute in both directions (too high at max skill, too low at low skill); one analysis suggests the underlying formula itself may be miscalibrated even on P99. Match whatever this project's EQCode source already implements.
- **Resist checks / resist rate scaling.** P99's own Statistics page states its resist-formula information "is not necessarily correct for P99... but it's probably pretty close," with an explicit unfilled "(Todo)" placeholder for the actual formula. No confidence-worthy target exists anywhere, including on P99 itself.
- **Charm duration formula / CHA's role.** The Enchanter class page claims CHA extends charm duration; independent forum testing found no measurable CHA effect. This project's own source checked directly: CHA only appears in `aggro.cpp` for Lull's resist check, nowhere in charm break-check logic — i.e. this implementation matches the "no CHA effect" camp. Given the wiki's own internal disagreement, not treated as a bug.
- **Stun duration and resist mechanics.** Mostly documented in PvP-specific, actively-disputed threads not relevant to this cooperative server; P99's own Game Mechanics page admits "values still being tuned."
- **Riposte/dodge/parry/block.** No clean formula found, mostly qualitative (AGI affects Dodge/Defense/Parry skill-up rate and avoidance AC, with a breakpoint around 75 AGI; a separate low-HP AGI penalty starts near 25% health). Same bucket as fizzle/resist.
- **Sneak/invisibility and social aggro.** P99's Aggro page states plainly that sneak/invis "no longer prevent social aggro on P99" — the phrase "no longer" implies a change from an earlier P99 implementation, and a forum thread theorizes true classic behavior differed, explicitly labeled speculation by its own author. Even P99 itself isn't settled here; match current implementation.
- **Feign Death: resisted-spell interaction.** Whether a resisted (not landed) spell cast on a feigned player should break FD is a real, disputed community question with conflicting patch dates (~2001 vs. ~2005-2006). The core re-aggro percentages above are solid; this sub-question is not.
- **Normal player corpse decay (with items), ~24.86 days vs. classic 7 days.** Deliberate ADR-002 deviation for solo-play convenience, explicitly recorded there as a known non-classic choice, not an oversight.
- **Player empty/naked corpse decay, 30 seconds.** Community sources describe classic values ranging 3 minutes to 3 hours depending on era (with a Feb 21, 2001 patch — inside this project's window — suggesting 3 hours for a naked corpse above level 30). Raised for a decision; **project lead reviewed and elected to keep the current 30-second value.** Closed by decision, not by evidence resolution.
- **NPC major (high-level) corpse decay: 25 min vs. documented 30 min.** A 5-minute gap, small enough not to warrant a dedicated fix on its own — batch in if this rule is ever touched for another reason.
- **General (non-tradeskill) skill-up rate formula.** No formula distinct from the tradeskill skill-up mechanic was found; same shape (governing stat determines chance to gain a point), same lower confidence, not independently verified against source.
- **Pet leash/follow mechanics.** `/pet guard here` confirmed to have no distance limit. `/pet attack [name]` targeting range is reported by the community as much larger in true classic than on current P99, without a precise confirmed number — lower confidence, not verified against source in this pass.

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

## Suggested Order of Attack

HP regen and mana regen runtime verification first (both foundational, both have a concrete test defined, item 1 specifically may require an actual server-source patch once confirmed) — then the genuinely unresearched casting/combat items (spell interruption, recast/recovery enforcement, LoS, crit chance, bash/kick) — treating everything in the Accepted Current Behavior section as settled unless materially new evidence appears.
