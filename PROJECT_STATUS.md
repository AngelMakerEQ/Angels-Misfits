# PROJECT_STATUS

**Purpose:** Record the current state of the project and active development priorities.

**Authority:** This document is the authoritative source for the current status of the Angels Misfits project.

**Last Updated:** 2026-08-06

---

# Current Objective

Resume the systematic mechanics sweep, prioritizing the open and
undecided items around combat, casting, HP regen, and mana regen.

---

# Current Phase

**Mechanics Sweep Resuming**

The project has moved well past initial foundation work — fifteen ADRs
are implemented, a full spell/discipline legacy audit is complete across
all 14 classes playable through Velious, and a systematic mechanics
sweep is well underway. The prior concern that client-side classic zone
restoration (ADR-008) might have left server-side zone data (zone points,
safe coordinates, zone flags) inconsistent with the restored geometry has
been closed without a dedicated review: EQEmu's zone points were already
correct against the classic geometry, only the client-side files needed
to match it, and no in-game issues have surfaced. Focus now returns fully
to the mechanics sweep, on the categories most central to core gameplay
feel: combat, spellcasting, and HP/mana regeneration.

---

# Current Priorities

1. **Resume the mechanics sweep** (`docs/development/MECHANICS_REVIEW.md`,
   consolidated and re-audited via ADR-014), prioritizing the still-open
   items: the HP regen racial-bonus defect (likely requires a small
   server-source patch), mana regen runtime verification, and the
   unresearched casting/combat
   categories — see that document for the full breakdown.
2. Continue the remaining standing research gaps as background work
   between the above: item stat-budget conventions, faction kill/quest
   increment verification, tradeskill recipe data, and the out-of-era NPC
   audit. All fourteen classes' epic 1.0 quests have now passed full
   database/quest-script verification — every NPC, loot source, and
   hand-in script traced end to end, not just the final reward
   (`docs/gameplay/EPIC_QUESTS_REVIEW.md`, closed 2026-08-06). The epic
   weapon equip-level question is decided (left ungated — see that
   document).

---

# Overall Status

## Completed

- GitHub repository and documentation structure established.
- Fifteen Architectural Decision Records accepted (ADR-001 through
  ADR-015), covering content scope, server rules and level cap, NPC
  combat stats, spell mechanics, pet stats, starting kit, NPC models,
  client visual restoration (Phase 1), the full spell/discipline
  legacy audit, faction tier boundaries, RoF2 inventory container
  location format, necromancer illusion/pet-model corrections (Part 2
  pending live application), the all-class skill cap ceiling
  correction, and the mechanics/epic-quest documentation consolidation
  covered by this update.
- Sense Heading and Swimming skill mechanics corrected to require
  guildmaster training and skill-up through use.
- Bard instrument-modifier mechanic verified correct; one broken
  duplicate spell disabled; a non-classic post-Velious AE DoT
  restriction reverted.
- Merchant pricing switched to the classic percentage-based/CHA-
  haggling calculation.
- Harm Touch (Shadow Knight) corrected — duplicate entries with an
  incorrect recast disabled, correct 72-minute version retained.
- NPC "leash"/training distance mechanic disabled, restoring classic
  chase-until-caught behavior.
- A systematic mechanics sweep is substantially underway across
  skills, combat, aggro, corpses, charm, tradeskills, and more,
  including a full re-audit of every item's true open/closed status —
  see `docs/development/MECHANICS_REVIEW.md` (consolidated and
  re-audited via ADR-014, replacing the former WIP checklist and
  three dated assessments).
- The all-class skill cap ceiling defect corrected (ADR-013); the
  classic minimum mana-regen floor applied (`Character:OldMinMana`);
  spell component consumption confirmed correct with no data change
  needed.
- Era-containment cleanup applied and verified live: Beastlord and Berserker
  active-level grants are zero, `don_nest_unlocked` is disabled, and the
  Velious expansion gate remains intact.
- Race-60 skeleton pet material restoration implemented and verified live:
  Malignant Dead now summons its correct red/brown, size-6 skeleton using NPC
  template 623, texture 1 (ADR-012 Part 2).
- Late-game necromancer Spectre pet-model correction applied and verified:
  all 38 templates in the six affected pet chains use classic race 85; none
  remain at Luclin-era race 485 (ADR-012 Part 3).
- All fourteen classes' epic 1.0 quests researched and fully verified
  against the live database and quest scripts (the last seven — Paladin,
  Ranger, Shadow Knight, Druid, Magician, Wizard, Rogue — closed
  2026-08-06 with a full NPC/loot-table/quest-script trace, not just the
  final reward) — see `docs/gameplay/EPIC_QUESTS_REVIEW.md` (consolidated
  via ADR-014, replacing the former research reference and audit
  documents). Core game mechanics reference material remains at
  `docs/research/GAME_MECHANICS_REFERENCE.md`.
- Multibox characters created, leveled, equipped, and bound — see
  Known Issues below for the corrected current level range.
- Server-side zone architecture review closed (2026-08-05) without
  further action needed: EQEmu's zone points, safe coordinates, and
  zone flags were already correct against the classic geometry; only
  the client-side files needed to match (ADR-008), and no in-game
  issues have been encountered.
- Epic weapon equip-level policy decided (2026-08-05): left ungated.
  See `docs/gameplay/EPIC_QUESTS_REVIEW.md` for the full decision and
  its single-player-server rationale.

## In Progress

- Mechanics sweep resumption, prioritized toward combat/casting/HP
  regen/mana regen per current focus.
- Client visual restoration (ADR-008) remaining sub-items: loading
  screens still RoF2-era, Velious-era zone visual research, general
  in-client verification pass.
- Broader faction system verification beyond tier boundaries (2,105
  factions total) — ongoing background item.
- Merchant/vendor inventory verification beyond Cabilis/Field of Bone
  — ongoing background item.

## Not Started

- Item stat-budget conventions for era-appropriate itemization.
- Zone Experience Modifiers (ZEM) correction — deprioritized; base
  experience rate has already been separately adjusted, so this is no
  longer considered high priority.
- Guild mechanics research.
- Tradeskill recipe data verification (trivial values, components)
  against classic sources — success-rate formula itself is already
  researched and confirmed.
- Out-of-era NPC audit.
- Vendor greed/pricing calibration Phase 2 (per-vendor values).

---

# Known Issues / Blockers

Lavastorm was mistakenly believed to have zoneid=6039 but this was due to the query pulling tableid from "id" command. Correct command to pull zoneid is "zoneidnumber". Lavastorm zoneidnumber=27 confirmed. 

None blocking. All open items are individually scoped research or
verification gaps rather than active problems affecting current
gameplay.

**Correction (2026-08-02, via ADR-014):** this section previously
stated all characters were level 10 or below and that no correction
had caused any loss of previously-learned content. Both claims were
stale — Angel, an Iksar Necromancer, is level 40, and ADR-013's skill
cap ceiling correction reduced seven of her already-trained skills
(1H/2H Blunt, Bind Wound, Defense, Dodge, Hand to Hand, 1H Piercing,
Throwing, Alcohol Tolerance) plus a specialization that had drifted
above the true cap. That reduction is intended and correct — the
character had trained past a defect that has since been fixed — but
it is a real, visible change to previously-learned content, not a
no-op. Live character levels beyond Angel have not been re-confirmed
as part of this correction; treat "six characters at level 10 or
below" as unverified rather than assume it still holds.

---

# Next Milestones

- Resume and continue the mechanics sweep, working through the
  combat/casting/HP-regen/mana-regen items flagged as priority in
  `MECHANICS_REVIEW.md`.
- Continue faction, merchant, and tradeskill verification incrementally
  as background work.

---

# Recent Major Decisions

- ADR-001 through ADR-015 — see `docs/decisions/` for full detail on
  each. ADR-011 through ADR-015 (RoF2 inventory container locations,
  necromancer illusion/pet-model corrections, skill cap ceiling
  correction, and this mechanics/epic-quest documentation
  consolidation) postdate this document's prior update and were not
  previously reflected here.
- P99 wiki adopted as the primary era-accuracy reference throughout,
  prioritized above the TAKP-claimed comparison database for any question
  involving *when* content was introduced, since that database itself
  progressed through Luclin and PoP and cannot make that distinction. That
  database's provenance is also unverified — see `docs/research/TAKP.md` —
  so it's not treated as authoritative for any question, not just dating.
- The server-side zone data concern raised alongside ADR-008 (whether
  zone points/safe coordinates/flags still matched the restored classic
  geometry) is closed: confirmed already correct, no review needed.
- Mechanics sweep work is treated as a living, cross-session document
  rather than a one-time pass — see `MECHANICS_REVIEW.md`.
- Epic weapon equip-level requirement decided as left ungated, given
  this server's current single-player context — see
  `EPIC_QUESTS_REVIEW.md`.

---

# Environment

**Server platform:**
- Local Windows installation
- EQEmu Windows Installer v23.10.3 (Akk Stack Docker)
- MariaDB database, managed via HeidiSQL
- Spire for server management and configuration
- Rain of Fear 2 (RoF2) client, base client sourced from AddictedDads'
  "RoF2_Full.zip" (used as a pristine base only; see ADR-008)
- EQEmu MCP — connected and in active use for direct database
  inspection and modification

**Database origin:** Originally imported as a pure PEQ database (Sept
2025 dump); has since undergone extensive, documented correction
toward classic/Velious-era accuracy — see `docs/decisions/` for the
full ADR series and `CHANGELOG.md` for smaller fixes.

**Key reference material:** `docs/research/GAME_MECHANICS_REFERENCE.md`
(core mechanics formulas), `docs/development/MECHANICS_REVIEW.md`
(living mechanics sweep tracker), `docs/gameplay/EPIC_QUESTS_REVIEW.md`
(epic quest tracker).

---

# Notes

This document is intended to provide a high-level snapshot of the
project's current state.

Implementation details, research, architecture, gameplay decisions,
and historical analysis should be documented in their respective
documents rather than here.

---
