# PROJECT_STATUS

**Purpose:** Record the current state of the project and active development priorities.

**Authority:** This document is the authoritative source for the current status of the Angels Misfits project.

**Last Updated:** 2026-07-30

---

# Current Objective

Complete a systematic mechanics-verification pass (tracked in
`docs/development/WIP/MECHANICS_REVIEW.md`) through to a final
disposition on every item, while maintaining a small set of standing
background items (item stat-budget conventions, faction increment
verification, tradeskill data verification, out-of-era NPC
identification, and Epic Quest database verification) for when
capacity allows.

---

# Current Phase

**Active Correction & Verification, with Early Gameplay Underway**

The database has undergone extensive, documented correction across
combat stats, spell mechanics, pet balance, starting kit, NPC models,
skill mechanics, faction tiers, merchant pricing, and NPC aggro/leash
behavior. Six multibox characters exist, are leveled and equipped, and
are bound at a shared location. Client-side visual restoration toward
a classic presentation is substantially implemented. The current
primary focus is finishing a systematic sweep of game mechanics
(`MECHANICS_REVIEW.md`) to a definitive resolution on every tracked
item, rather than starting new large research efforts.

---

# Overall Status

## Completed

**Documentation & Architecture**
- GitHub repository and documentation structure established.
- Eleven Architectural Decision Records/addendums accepted and
  implemented (ADR-001 through ADR-010, plus addendums to ADR-002,
  ADR-008, and ADR-009 — see CHANGELOG.md for the full index).
- Three research/working documents committed: `docs/research/
  GAME_MECHANICS_REFERENCE.md`, `docs/research/
  CLASS_EPIC_QUEST_REFERENCE.md`, and `docs/development/WIP/
  MECHANICS_REVIEW.md`.

**Database Correction**
- Content scope, server rules baseline, level cap, NPC combat stats,
  spell mechanics, pet stats, starting kit, and NPC models all
  corrected per ADR-001 through ADR-007 (see CHANGELOG.md).
- Full spell/discipline legacy audit completed across all 14 classes
  playable through Velious (ADR-009) — non-classic spells disabled,
  duplicates and wrong-level placements corrected, confirmed
  omissions restored. All three originally-ambiguous items now
  resolved: Throw Stone and Death Peace confirmed genuine classic
  content; the Harm Touch duplicate-recast bug fixed (two broken
  30-second-recast copies disabled, correct 72-minute version
  confirmed active, matching P99 exactly).
- Faction tier boundaries corrected across all 8 tiers to match
  P99-documented values (ADR-010). Core faction hit mechanism
  separately verified correct against a documented P99 example.
- Sense Heading and Swimming skill training mechanics corrected to
  require guildmaster training and skill-up through use.
- Bard instrument-modifier system verified end-to-end and confirmed
  correctly implemented; one broken duplicate spell disabled and a
  non-classic post-Velious AE DoT restriction reverted.
- Merchant pricing switched from EQEmu's modern flat-markup system to
  the classic percentage-based formula with CHA-based haggling.
- NPC "leash"/training-distance mechanic disabled — NPCs now chase
  indefinitely rather than resetting at a fixed distance, a deliberate
  classic-authenticity choice made with awareness of the added
  solo-multibox risk.
- `angels_misfits_migration.sql` (combined ADR-001/002/003 migration)
  confirmed fully applied via live spot-check.

**Client**
- Client-side classic visual restoration implemented (ADR-008): zone
  files, spell icons/gems/effects, skeleton models, Luclin model
  toggles (player-optional, NPC-classic), TaipoUI. Troll/Ogre Luclin
  model question and Marketplace/Krono UI item both closed out.

**Gameplay Setup**
- Six multibox characters created, leveled to 10, equipped, and
  spellbooks scribed: Zugzug (Ogre Warrior), Grub (Troll Shaman),
  Gwenothyl (High Elf Enchanter), Ohme (Iksar Monk), Balthazaar
  (Erudite Cleric), Dandelion (Half Elf Bard).
- All six bound at their current location inside Kurn's Tower.
- Kurn's Tower NPC roster and Cabilis/Field of Bone merchant
  inventories both checked against external reference data and
  confirmed solid.

**Research**
- P99's "Game Mechanics" wiki page and "Non-Classic Compendium" page
  both fully synthesized (`GAME_MECHANICS_REFERENCE.md`).
- Epic quest research completed for 7 classes (Warrior, Shaman,
  Enchanter, Monk, Cleric, Bard, Necromancer) — quest givers, NPCs,
  items, zones, and final weapon stats documented
  (`CLASS_EPIC_QUEST_REFERENCE.md`). Paladin, Ranger, Shadow Knight,
  Druid, Magician, Wizard, and Rogue epics not yet researched.
- A systematic, category-by-category mechanics sweep substantially
  complete (`MECHANICS_REVIEW.md`) — see In Progress below for what
  remains.

## In Progress

- **`MECHANICS_REVIEW.md` — current primary focus.** Most major
  categories have a documented disposition (confirmed correct,
  confirmed non-classic and fixed, or confirmed genuinely
  contested/unresolvable even by P99 itself). Remaining unresolved
  items to work through: line-of-sight for aggro/casting, snare
  stacking rules, item stacking rules, skill cap enforcement edge
  cases, critical hit chance formula, bash/kick special attack
  mechanics, and pet leash/`/pet attack` range specifics. Goal is a
  final, explicit disposition on every remaining item before moving to
  new research areas.
- **External GitHub repository review** — 11 candidate repos
  identified and given an initial metadata-level pass, but each still
  needs an actual deep-dive into its contents before a final verdict
  can be trusted; treat all 11 as open/unresolved rather than settled.
  One dead end confirmed: the external database link referenced by two
  of the EQClassic-derived repos (newagesoldier.com) is dead.
- **Client visual restoration remaining sub-items (ADR-008):** loading
  screens still RoF2-era art; Velious-era zone visual research not
  started; general in-client verification pass deferred.
- **Faction system:** tier boundaries and core hit mechanism verified;
  broader per-faction verification (2,105 factions) and full
  kill/quest increment accuracy remain open, ongoing background items.
- **Merchant/vendor inventory verification:** Cabilis and Field of Bone
  confirmed; the rest of the world remains an ongoing background item.
- **Vendor pricing calibration Phase 2** (per-vendor `greed` values)
  not yet started.

## Not Started

- **Item stat-budget conventions** — whether item stats (AC, HP, mana,
  resists) are appropriately scaled for their introduction era; the
  item-side equivalent of the ADR-009 spell audit.
- **Tradeskill recipe/threshold data verification** — the general
  success-rate and skill-up-rate *formulas* have been researched
  (`MECHANICS_REVIEW.md`), but the actual recipe and trivial-value
  *data* in our database has not been checked against classic sources.
- **Out-of-era NPC identification** — a pass to find NPCs that don't
  belong in their zone/era (e.g., a reported Halfling NPC in Cabilis).
- **Epic Quest database verification** — research is complete
  (`CLASS_EPIC_QUEST_REFERENCE.md`), but our database has not been
  checked against it: confirming quest-giver and drop NPCs exist, all
  quest legs are active/scripted (not just that NPCs/items exist), and
  loot tables have correct drop rates.
- Guild mechanics research (believed disabled via the same
  expansion-setting mechanism as AA, not yet confirmed).
- VV MQ subscription-lapse behavior empirical test (a manual test for
  the project lead to run, not a research task).

## Deprioritized / Resolved Differently

- **Zone Experience Modifiers (ZEM)** — flagged earlier as a
  potentially high-value gap (commonly-circulated values trace to a
  non-classic 2003 ShowEQ dump), but the project lead has since
  addressed leveling pace directly via base-level experience
  adjustments. No longer tracked as an open research item.

---

# Current Priorities

1. Work through every remaining item in `MECHANICS_REVIEW.md` to a
   final, explicit disposition before starting new research areas.
2. Maintain the standing background items (item stat-budget
   conventions, faction verification, tradeskill data, out-of-era
   NPCs, Epic Quest database verification) opportunistically.
3. Continue the GitHub repository deep-dive as a lower-intensity,
   ongoing background task.

---

# Known Issues / Blockers

None blocking. All outstanding items are individually scoped,
non-urgent research/verification gaps rather than active problems
affecting current gameplay.

---

# Next Milestones

- Close every remaining item in `MECHANICS_REVIEW.md`.
- Complete at least one deep-dive pass on a GitHub repo from the
  review list.
- Begin Epic Quest database verification once mechanics review work
  allows.

---

# Recent Major Decisions

- ADR-001 through ADR-010 (plus addendums to ADR-002, ADR-008, and
  ADR-009) — all implemented; see CHANGELOG.md for the full index.
- P99 wiki adopted as the primary era-accuracy reference throughout,
  prioritized above TAKP for any question involving *when* content was
  introduced, since TAKP itself progressed through Luclin and PoP and
  cannot make that distinction.
- Classic "mobs chase indefinitely" behavior restored over a modern
  distance-based leash mechanic, a deliberate authenticity choice made
  with explicit awareness of added solo-multibox risk.
- ZEM research deprioritized in favor of directly adjusting base-level
  experience rates to manage leveling pace.

---

# Notes

This document is intended to provide a high-level snapshot of the
project's current state.

Implementation details, research, architecture, gameplay decisions,
and historical analysis should be documented in their respective
documents rather than here.

---
