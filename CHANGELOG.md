# Angels Misfits Changelog

Lightweight chronological index of major project milestones. Each entry states what changed in plain terms. Full decision reasoning and implementation detail lives in the referenced ADR.

---

- **2026-07-22** — Project documentation structure established. (No ADR — foundational setup.)
- **2026-07-22 → 2026-07-23** — ADR-001: Content scope restricted to Velious-and-earlier. Later-expansion content is retained in the database but hidden from players.
- **2026-07-23** — ADR-002: Server rules rebaselined against PEQ/TAKP — restored several classic mechanics (hunger, Master Wu, no `/tgb`), removed class/race exp penalties, added faster exp rate and always-bindable for solo play.
- **2026-07-23** — ADR-003: NPC combat stats increased across ~12,574 Classic/Kunark/Velious NPCs — higher HP, damage, AC, resists, and regen; aggro radius widened moderately (not full TAKP widening, to preserve multibox viability).
- **2026-07-23** — ADR-004: Spell mechanics replaced wholesale (37,729 spells) with data verified against the real classic client — affects cast times, targeting, effects, and reagents across all classes.
- **2026-07-23** — ADR-005: Pet stats reduced to align with classic behavior — pets hit softer and self-heal slower, but resist magic/fire better and move faster.
- **2026-07-25** — ADR-006: Starting kit corrected — removed a non-classic backpack and Gloomingdeep lantern; all other starting items verified classic and kept.
- **2026-07-26** — ADR-002 correction: level cap corrected from 50 to 60 (Kunark, not Velious, raised the cap; earlier value was a factual error).
- **2026-07-26** — ADR-007: Skeleton-family NPCs (1,630 total) corrected to classic-style models; genuine Iksar-identity NPCs deliberately excluded.
- **2026-07-26 (ongoing)** — ADR-008: Client-side classic visual restoration — Luclin models disabled, classic zone files applied, spell icons/gems/effects and skeleton models updated, TaipoUI selected as current UI.

---

For full project history and reasoning, see `docs/decisions/`.
