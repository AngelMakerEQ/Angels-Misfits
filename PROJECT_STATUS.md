# PROJECT_STATUS

**Purpose:** Record the current state of the project and active development priorities.

**Authority:** This document is the authoritative source for the current status of the Angels Misfits project.

**Last Updated:** 2026-07-31

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
2. **Resume the mechanics sweep** (`docs/development/WIP/
   MECHANICS_REVIEW.md`), prioritizing the still-open and undecided
   items specifically in combat, casting, HP regen, and mana regen —
   see that document for the full breakdown.
3. Continue the remaining standing research gaps as background work
   between the above: item stat-budget conventions, faction kill/quest
   increment verification, tradeskill recipe data, epic quest database
   verification, out-of-era NPC audit.

---

# Overall Status

## Completed

- GitHub repository and documentation structure established.
- Ten Architectural Decision Records accepted and implemented
  (ADR-001 through ADR-010), covering content scope, server rules and
  level cap, NPC combat stats, spell mechanics, pet stats, starting
  kit, NPC models, client visual restoration (Phase 1), the full
  spell/discipline legacy audit, and faction tier boundaries.
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
  skills, combat, aggro, corpses, charm, tradeskills, and more — see
  `docs/development/WIP/MECHANICS_REVIEW.md` for full detail.
- Research reference material built for class epic quests
  (`docs/research/CLASS_EPIC_QUEST_REFERENCE.md`) and core game
  mechanics (`docs/research/GAME_MECHANICS_REFERENCE.md`).
- Six multibox characters created, leveled, equipped, and bound.

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
- Epic quest database verification — research is complete, but
  checking actual quest NPCs, items, active scripting, and loot table
  drop rates against our live database has not started.
- Out-of-era NPC audit.
- Vendor greed/pricing calibration Phase 2 (per-vendor values).

---

# Known Issues / Blockers

Lavastorm was mistakenly believed to have zoneid=6039 but this was due to the query pulling tableid from "id" command. Correct command to pull zoneid is "zoneidnumber". Lavastorm zoneidnumber=27 confirmed. 

None blocking. All open items are individually scoped research or
verification gaps rather than active problems affecting current
gameplay. The six existing characters are level 10 or below, so none
of the corrections made to date have caused any loss of previously-
learned content.

---

# Next Milestones

- Complete the server-side zone architecture review.
- Resume and continue the mechanics sweep, working through the
  combat/casting/HP-regen/mana-regen items flagged as priority in
  `MECHANICS_REVIEW.md`.
- Begin epic quest database verification once zone/mechanics work
  reaches a natural pause point.
- Continue faction, merchant, and tradeskill verification incrementally
  as background work.

---

# Recent Major Decisions

- ADR-001 through ADR-010 — see `docs/decisions/` for full detail on
  each.
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
