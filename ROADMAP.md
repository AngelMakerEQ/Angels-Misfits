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

See ADR-008 for full detail on work completed and outstanding.

Completed:

- Luclin player models disabled (per-race settings)
- Classic zone files applied (FV Project source, 14 zones)
- Spell icons, gems, effects, and skeleton models updated
- UI selected (TaipoUI, after evaluating and rejecting Defiance, SARS, and Default Old Interface by Drakah)

Outstanding:

- Loading screen restoration (not yet researched)
- Velious-era zone visual research (not yet started)
- Spell icon mismatch diagnosis (known issue)
- Formal in-client verification pass (deferred)

Player model philosophy (unchanged):

- Allow optional Luclin player models — currently all off; Troll/Ogre exception under consideration
- Prefer classic-era NPC appearances — achieved by default for non-playable NPC races; not achievable for NPCs sharing playable race IDs (confirmed engine limitation)

---

# Phase 3: Database Baseline and Gameplay Foundation — SUBSTANTIALLY COMPLETE

Completed via ADR-001 through ADR-007:

- Compared Angels Misfits database against PEQ and TAKP
- Documented imported systems and server rules
- Corrected NPC combat stats, spell mechanics, pet stats, starting items, and NPC model data
- Established database change tracking via the ADR series

Outstanding:

- Item and spell-level expansion scoping (ongoing, incremental per ADR-001)
- Broader itemization and quest content review
