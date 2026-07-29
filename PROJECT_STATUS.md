# PROJECT_STATUS

**Purpose:** Record the current state of the project and active development priorities.

**Authority:** This document is the authoritative source for the current status of the Angels Misfits project.

**Last Updated:** 2026-07-28

---

# Current Objective

Verify and correct the live database and client against classic-era
(Velious-and-earlier) behavior across all major game systems — spells,
skills, NPCs, factions, merchants, and client presentation — while
supporting active solo/multibox gameplay on the six characters already
created and playable.

---

# Current Phase

**Active Correction & Verification, with Early Gameplay Underway**

The project has moved well past initial foundation work. The database
has undergone extensive, documented correction across combat stats,
spell mechanics, pet balance, starting kit, NPC models, skill
mechanics, faction tiers, and merchant pricing. Six multibox characters
exist, are leveled and equipped, and are bound at a shared location.
Client-side visual restoration toward a classic presentation is
substantially implemented. Remaining work is concentrated in three
areas: finishing the client presentation pass, completing several
large but well-scoped research gaps (faction, merchants, tradeskills),
and resolving a small number of individually-flagged ambiguous items.

---

# Overall Status

## Completed

**Documentation & Architecture**
- GitHub repository and documentation structure established.
- Ten Architectural Decision Records accepted and implemented
  (ADR-001 through ADR-010 — see Recent Major Decisions).

**Database Correction**
- Content scope restricted to Classic/Kunark/Velious (ADR-001).
- Server rules baseline corrected against TAKP/PEQ comparison,
  including the level cap correction to 60 (ADR-002 + addendum).
- NPC combat stats corrected for ~16,950 Velious-scoped NPCs (ADR-003).
- Spell mechanics corrected for 37,729 spells to match verified
  classic client data (ADR-004).
- Pet NPC stats corrected for 140 templates (ADR-005).
- Starting character kit corrected (ADR-006).
- NPC model/race corrected for 1,630 NPCs (ADR-007).
- Full spell/discipline legacy audit completed across all 14
  classes playable through Velious — roughly 150 non-legacy
  spells/disciplines disabled, duplicates and wrong-level placements
  corrected, confirmed omissions restored (ADR-009). Of the three
  items originally left ambiguous, two are now confirmed genuine
  classic content requiring no action: Throw Stone
  (Warrior/Monk/Rogue) and Death Peace (Necromancer). The third,
  "Harmful Touch" (Shadow Knight, id 2774), needs a deeper
  investigation against the confirmed Harm Touch mechanics (recast
  time, effect, mana cost) — not yet resolved.
- Sense Heading and Swimming skill mechanics corrected to require
  guildmaster training and skill-up through use, rather than
  auto-maxing at character creation.
- Bard instrument-modifier mechanic fully verified against P99 —
  confirmed correctly implemented; one broken duplicate spell
  disabled and one non-classic post-Velious AE DoT restriction
  reverted (`Spells:PreNerfBardAEDoT`).
- Faction tier boundaries corrected to match P99-documented values
  across all 8 tiers (ADR-010).
- Merchant pricing system switched from EQEmu's modern flat-markup
  default to the classic percentage-based calculation
  (`Merchant:UseClassicPriceMod` enabled).
- `angels_misfits_migration.sql` (the combined ADR-001/002/003
  migration package) confirmed fully applied via live spot-check.

**Client**
- Client-side classic visual restoration implemented: zone files,
  spell icons/gems/effects, skeleton models, Luclin model toggles
  (player-optional, NPC-classic), and TaipoUI (ADR-008, Phase 1).

**Gameplay Setup**
- Six multibox characters created, leveled to 10, equipped, and
  spellbooks scribed: Zugzug (Ogre Warrior), Grub (Troll Shaman),
  Gwenothyl (High Elf Enchanter), Ohme (Iksar Monk), Balthazaar
  (Erudite Cleric), Dandelion (Half Elf Bard, James's main).
- All six bound at their current location inside Kurn's Tower.
- Kurn's Tower NPC roster and locations checked against FV
  Project/Al'Kabor reference data — confirmed solid, no genuine
  errors found.
- Cabilis (East/West) and Field of Bone merchant inventories checked
  against P99/community reference data — confirmed solid; several
  specifically-named vendors and a known P99-reported inventory gap
  (Klok Scaleroot's alchemy stock) confirmed correctly present in our
  data where P99 itself has the gap.

## In Progress

- **Client visual restoration (ADR-008) remaining sub-items:**
  loading screens still showing RoF2-era art rather than
  Classic/Kunark/Velious; Velious-era zone visual research not
  started; a general in-client verification pass (models, effects,
  icons) deferred. Two prior open items are now closed: Marketplace
  window is confirmed mostly absent under TaipoUI already (Krono
  database-verification spun off separately as a small future audit
  item, not a UI concern), and the Troll/Ogre Luclin-model question
  has been dropped from tracking entirely as a low-stakes, fluid
  preference not worth carrying as an open decision.
- **Faction system:** tier boundaries corrected; broader per-faction
  verification (2,105 factions total) treated as an ongoing
  background item given the scale and the incompleteness of
  community-documented starting standings.
- **Merchant/vendor inventory verification:** Cabilis and Field of
  Bone confirmed; the remaining ~1,300+ merchants server-wide remain
  an ongoing background item, not a single pass.
- **Vendor pricing calibration:** Phase 1 (classic pricing system
  enabled) complete; Phase 2 (populating correct per-vendor `greed`
  values to distinguish the documented non-greedy exceptions from
  the "greedy" majority) not yet started.

## Not Started

- Guild mechanics research (believed disabled via the same
  expansion-setting mechanism as AA; not yet confirmed).
- Tradeskill recipe research (no resourcing yet).
- Item stat-budget conventions for era-appropriate itemization.
- VV MQ subscription-lapse behavior empirical test (plan: run
  MacroQuest.exe directly, bypassing the RedGuides launcher — this
  is a manual test for the project lead, not a research task).

---

# Current Priorities

1. Complete the Harmful Touch deep dive (the one remaining ambiguous
   item from the spell/discipline audit — comparing id 2774 against
   confirmed Harm Touch mechanics).
2. Continue the client visual restoration pass (loading screens,
   Velious zone visuals) as time allows.
3. Scope and begin Phase 2 of vendor pricing calibration when ready.
4. Treat faction, merchant, and tradeskill verification as ongoing
   background workstreams rather than blocking priorities.

---

# Known Issues / Blockers

None blocking. All outstanding items are individually scoped,
non-urgent research/verification gaps rather than active problems
affecting current gameplay. The six existing characters are all
level 10 or below, so none of the ADR-009 spell corrections or
faction/pricing changes have caused any loss of previously-learned
content.

---

# Next Milestones

- Complete the Harmful Touch investigation (the last remaining
  ambiguous item from ADR-009).
- Complete a Velious-era zone visual research pass.
- Scope Phase 2 of vendor pricing calibration (target `greed` value
  and a fuller non-greedy exception list beyond the four currently
  documented Kunark examples).
- Begin faction, merchant, and tradeskill verification incrementally
  as background work between other priorities.

---

# Recent Major Decisions

- ADR-001: Content Scope Restriction (Velious and earlier) — Implemented.
- ADR-002: Server Rules Baseline (PEQ vs TAKP), including the level
  cap correction addendum (50 → 60) — Implemented.
- ADR-003: NPC Combat Stat Tuning (PEQ vs TAKP) — Implemented.
- ADR-004: Spell Mechanics (Classic Restoration) — Implemented.
- ADR-005: Pet NPC Stat Tuning — Implemented.
- ADR-006: Starting Kit Review (Classic Verification) — Implemented.
- ADR-007: NPC Model Correction (Classic vs. Luclin/Later Models) — Implemented.
- ADR-008: Client-Side Classic Visual Restoration (Phase 1) — Partially Implemented.
- ADR-009: Spell & Discipline Legacy Correction — Implemented.
- ADR-010: Faction Tier Boundary Correction — Implemented.
- P99 wiki adopted as the primary era-accuracy reference throughout,
  prioritized above TAKP for any question involving *when* content
  was introduced, since TAKP itself progressed through Luclin and PoP
  and cannot make that distinction.

---

# Notes

This document is intended to provide a high-level snapshot of the
project's current state.

Implementation details, research, architecture, gameplay decisions,
and historical analysis should be documented in their respective
documents rather than here.

---
