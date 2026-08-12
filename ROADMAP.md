# Current Development Phase

## Phase 1: Foundation and Documentation — COMPLETE

Goals achieved:

- Angels Misfits project structure established
- Server configuration documented
- Database baseline documented
- EQEmu installation verified
- Client compatibility verified
- GitHub documentation workflow established

---

# Phase 2: Classic Experience Restoration — IN PROGRESS

See ADR-008 (and its addenda) for full detail on work completed and outstanding.

Completed:

- Luclin player models disabled (per-race settings)
- Classic zone files applied (FV Project source, 14 zones)
- Spell icons, gems, effects, and skeleton models updated
- UI selected (TaipoUI, after evaluating and rejecting Defiance, SARS, and Default Old Interface by Drakah)
- Troll/Ogre Luclin-model question dropped from tracking — low-stakes, fluid preference (ADR-008 addendum)
- Marketplace UI cleanup substantially resolved under TaipoUI (ADR-008 addendum)
- Spell particle effects restored — root cause was 41 missing texture files from an incomplete original asset copy, not an engine limitation as first assumed (ADR-015, corrects ADR-008)

Outstanding:

- Loading screen restoration (replacement method identified but not yet tested
  against this client; see `docs/client/LOADING_SCREENS.md`)
- Velious-era zone visual research (not yet started)
- Spell icon mismatch diagnosis (known issue, distinct from the particle-texture issue resolved by ADR-015)
- Formal in-client verification pass (deferred)
- Krono database-absence check (small, low-priority)

Player model philosophy (unchanged):

- Allow optional Luclin player models — currently all off
- Prefer classic-era NPC appearances — achieved by default for non-playable NPC races; not achievable for NPCs sharing playable race IDs (confirmed engine limitation)

---

# Phase 3: Database Baseline and Gameplay Foundation — SUBSTANTIALLY COMPLETE

Completed via the database-correction ADR series (ADR-001–ADR-007, ADR-009–ADR-013):

- Compared Angels Misfits database against PEQ and a legacy comparison database (see `docs/research/TAKP.md` on why the latter is treated as unverified)
- Documented imported systems and server rules
- Corrected NPC combat stats, spell mechanics, pet stats, starting items, and NPC model data (ADR-001–ADR-007)
- Full spell/discipline legacy audit across all 14 Velious-playable classes (ADR-009)
- Faction tier boundaries corrected across all 8 tiers (ADR-010)
- RoF2 inventory container location format corrected (ADR-011)
- Necromancer illusion-height, race-60 skeleton-material, and pet-model race
  corrections (ADR-012, all implemented and verified)
- Skill cap ceiling defect corrected across 8 classes (ADR-013)
- Database change tracking established via the ADR series, with migrations increasingly captured as versioned, committed SQL scripts under `scripts/`

Outstanding:

- Item stat-budget conventions for era-appropriate itemization
- Broader itemization and quest content review
- Out-of-era NPC audit

---

# Phase 4: Systematic Mechanics & Epic Quest Verification Sweep — IN PROGRESS

Ongoing, living-document work — see `docs/development/MECHANICS_REVIEW.md`
and `docs/gameplay/EPIC_QUESTS_REVIEW.md` for current item-level status
rather than duplicating it here (both consolidated and re-audited via
ADR-014).

- Category-by-category mechanics sweep (combat, casting, regen, aggro,
  corpses, tradeskills, and more) — several categories closed; current
  priority is HP/mana regen and casting/combat.
- Class epic 1.0 quest research and database/script verification — all 14
  classes complete; see the standing review for scope and follow-ups.

---

For current priorities and active work, see `PROJECT_STATUS.md`.
