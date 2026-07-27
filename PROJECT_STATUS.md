# PROJECT_STATUS

**Purpose:** Record the current state of the project and active development priorities.

**Authority:** This document is the authoritative source for the current status of the Angels Misfits project.

**Last Updated:** 2026-07-26

---

# Current Objective

Continue database baseline correction and gameplay foundation work while advancing client-side classic visual restoration.

---

# Current Phase

**Phase 2/3 Overlap: Classic Experience Restoration + Database Baseline & Gameplay Foundation**

Foundational documentation and architecture planning (originally Phase 1) are complete. The project has moved into active database correction (Phase 3) and client-side visual restoration (Phase 2) concurrently.

---

# Overall Status

## Completed

- GitHub repository and documentation structure established.
- EQEmu MCP connected; in active use for direct live-database inspection and modification.
- Content scope restricted to Velious-and-earlier (ADR-001).
- Server rules baseline established, reconciled against PEQ/TAKP (ADR-002), including a corrected level cap (60, per 2026-07-26 revision).
- NPC combat stat tuning applied — HP, damage, AC, resists, regen, aggro radius (ADR-003).
- Spell mechanics fully replaced with verified classic data — 37,729 spells, 144,666 field changes (ADR-004).
- Pet NPC stat tuning applied (ADR-005).
- Starting item kit corrected to classic (ADR-006).
- NPC model race corrections applied — skeleton family (ADR-007).
- Client-side classic visual restoration underway: zone files, spell icons/gems/effects, skeleton models, Luclin-off configuration, and UI selection (ADR-008).

## In Progress

- Client-side verification pass (models, spells, Luclin-off behavior) — deferred by project lead, not yet run.
- Diagnosing a known spell icon mismatch (ADR-008 Known Issue #1).
- Velious-era zone visual research (not yet started, scoped in ADR-008).
- Loading screen restoration research.
- Item/spell/NPC-level expansion scoping (deferred per ADR-001, ongoing incremental work).

## Not Started

- Gameplay implementation (custom quests, encounters, content).
- Quest review and standardization.
- Broader historical content validation beyond what's covered in the ADR series so far.
- Formal in-client testing/verification pass.

---

# Current Priorities

1. Complete the deferred verification pass on models/spells/client config.
2. Diagnose and resolve the spell icon mismatch.
3. Continue client-side classic visual restoration (loading screens, Velious zone research).
4. Continue incremental item/spell/NPC expansion scoping.
5. Begin planning for Phase 4 (solo gameplay experience).

---

# Known Issues / Blockers

- Spell icon mismatch of unconfirmed origin (FV Project files vs. TaipoUI) — see ADR-008.
- Loading screens still show RoF2-era art rather than Classic/Kunark/Velious art — unresolved.
- Client/model verification pass has been explicitly deferred by project lead.

---

# Next Milestones

- Complete deferred verification pass.
- Resolve spell icon mismatch.
- Research and decide on loading screen restoration approach.
- Begin Velious-era zone visual research.
- Scope Phase 4 (solo gameplay experience) planning.

---

# Recent Major Decisions

- GitHub serves as the project's authoritative source of truth; documentation takes precedence over conversation history.
- Architectural decisions are documented as ADRs (`docs/decisions/`) — eight ADRs implemented to date.
- Long-term maintainability and historical authenticity are both prioritized, with tradeoffs documented explicitly per decision (see individual ADRs).
- Client-side changes are consolidated into a single ADR (ADR-008) unless a future change is large enough to warrant its own record.

---
