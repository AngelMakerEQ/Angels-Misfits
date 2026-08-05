# PROJECT_STATUS

**Purpose:** Record the current state of the project and active development priorities.

**Authority:** This document is the authoritative source for the current status of the Angels Misfits project.

**Last Updated:** 2026-08-02

---

# Current Objective

Verify and correct server-side zone geometry data now that client-side
zone visuals have been reverted to classic-era files (ADR-008), then
resume the systematic mechanics sweep — prioritizing the open and
undecided items around combat, casting, HP regen, and mana regen.

---

# Current Phase

**Zone Architecture Correction, Mechanics Sweep Resuming Second**

The project has moved well past initial foundation work — ten ADRs are
implemented, a full spell/discipline legacy audit is complete across
all 14 classes playable through Velious, and a systematic mechanics
sweep is well underway. The immediate focus now shifts to a gap created
by that prior client-side work: restoring classic zone *visuals*
(ADR-008) means the client geometry no longer necessarily matches
whatever server-side zone data (zone points, safe coordinates, zone
flags) was originally set up against RoF2's modern geometry. This needs
to be reconciled before other work continues. Once that's in hand, the
mechanics sweep resumes, focused on the categories most central to
core gameplay feel: combat, spellcasting, and HP/mana regeneration.

---

# Current Priorities

1. **Server-side zone architecture review.** Audit zone-level data
   (zone points/teleporters, safe coordinates, zone flags, and any
   other server-side configuration tied to zone geometry) against the
   classic zone files restored client-side in ADR-008, to confirm the
   two are actually consistent rather than assumed to be.
2. **Resume the mechanics sweep** (`docs/development/MECHANICS_REVIEW.md`,
   consolidated and re-audited via ADR-014), prioritizing the still-open
   items: the HP regen racial-bonus defect (likely requires a small
   server-source patch), mana regen runtime verification, era-containment
   cleanup application confirmation, and the unresearched casting/combat
   categories — see that document for the full breakdown.
3. Continue the remaining standing research gaps as background work
   between the above: item stat-budget conventions, faction kill/quest
   increment verification, tradeskill recipe data, and the out-of-era NPC
   audit. The seven researched epic 1.0 quests passed database/script
   verification on 2026-08-02 (`docs/gameplay/EPIC_QUESTS_REVIEW.md`);
   the remaining seven classes' epics are unresearched.

---

# Overall Status

## Completed

- GitHub repository and documentation structure established.
- Fourteen Architectural Decision Records accepted (ADR-001 through
  ADR-014), covering content scope, server rules and level cap, NPC
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
- Seven of fourteen classes' epic 1.0 quests researched and verified
  against the live database and quest scripts — see
  `docs/gameplay/EPIC_QUESTS_REVIEW.md` (consolidated via ADR-014,
  replacing the former research reference and audit documents).
  Core game mechanics reference material remains at
  `docs/research/GAME_MECHANICS_REFERENCE.md`.
- Multibox characters created, leveled, equipped, and bound — see
  Known Issues below for the corrected current level range.

## In Progress

- Server-side zone architecture review (new, top priority — see above).
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

- Complete the server-side zone architecture review.
- Resume and continue the mechanics sweep, working through the
  combat/casting/HP-regen/mana-regen items flagged as priority in
  `MECHANICS_REVIEW.md`.
- Continue faction, merchant, and tradeskill verification incrementally
  as background work.

---

# Recent Major Decisions

- ADR-001 through ADR-014 — see `docs/decisions/` for full detail on
  each. ADR-011 through ADR-014 (RoF2 inventory container locations,
  necromancer illusion/pet-model corrections, skill cap ceiling
  correction, and this mechanics/epic-quest documentation
  consolidation) postdate this document's prior update and were not
  previously reflected here.
- P99 wiki adopted as the primary era-accuracy reference throughout,
  prioritized above TAKP for any question involving *when* content was
  introduced, since TAKP itself progressed through Luclin and PoP and
  cannot make that distinction.
- Client-side classic zone restoration (ADR-008) is treated as
  requiring a corresponding server-side zone data review — visual
  restoration alone does not guarantee the underlying zone
  configuration matches.
- Mechanics sweep work is treated as a living, cross-session document
  rather than a one-time pass — see `MECHANICS_REVIEW.md`.

---

# Notes

This document is intended to provide a high-level snapshot of the
project's current state.

Implementation details, research, architecture, gameplay decisions,
and historical analysis should be documented in their respective
documents rather than here.

---
