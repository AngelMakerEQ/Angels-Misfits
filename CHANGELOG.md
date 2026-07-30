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
- **2026-07-28** — ADR-008 addendum: Troll/Ogre Luclin-model question dropped from tracking (low-stakes, fluid preference); Marketplace/Krono UI item closed (confirmed resolved via TaipoUI; Krono database check spun off separately).
- **2026-07-28** — ADR-009: Full spell/discipline legacy audit across all 14 classes playable through Velious — non-classic spells disabled, duplicates and wrong-level placements corrected, confirmed omissions restored.
- **2026-07-28** — ADR-009 addendum: Throw Stone (Warrior/Monk/Rogue) and Death Peace (Necromancer) confirmed genuine classic content, no action needed. Harm Touch bug resolved — two duplicate entries with an incorrect 30-second recast (ids 88, 2821) disabled; the correctly-configured 72-minute-recast version (id 2774) confirmed active and matching P99 exactly.
- **2026-07-28** — ADR-010: Faction tier boundaries corrected across all 8 tiers to match P99-documented values (server was running on EQEmu's uncorrected compiled defaults).
- **2026-07-28** — Sense Heading and Swimming skill mechanics corrected: both now require guildmaster training and skill up through use, instead of auto-maxing (Sense Heading) or starting above their own level-1 skill cap (Swimming). (No ADR — logged directly.)
- **2026-07-28** — Bard instrument-modifier system verified end-to-end and confirmed correctly implemented; one broken duplicate spell disabled ("Angstlich's Appalling Screech," invalid skill value) and a non-classic post-Velious AE DoT restriction reverted (`Spells:PreNerfBardAEDoT`). `Character:EnableBardMelody` reviewed and deliberately left enabled for player convenience — a conscious deviation, not an oversight. (No ADR — logged directly.)
- **2026-07-28** — Merchant pricing switched from EQEmu's modern flat-markup system to the classic percentage-based formula (`Merchant:UseClassicPriceMod`), restoring CHA-based haggling. Per-vendor greedy/non-greedy calibration (`greed` values, currently all at default) remains a separate, larger follow-up item. (No ADR — logged directly.)
- **2026-07-28** — NPC "leash"/training-distance mechanic disabled (`Aggro:NPCAggroMaxDistanceEnabled` set to false): NPCs now chase indefinitely rather than giving up beyond a fixed distance, restoring classic behavior. A deliberate choice favoring authenticity, made with awareness of the added risk this introduces in a solo-multibox context. (No ADR — logged directly.)

---

For full project history and reasoning, see `docs/decisions/`.
