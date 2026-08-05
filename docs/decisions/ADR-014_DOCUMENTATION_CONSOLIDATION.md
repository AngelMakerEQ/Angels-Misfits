# ADR-014: Documentation Consolidation (Mechanics & Epic Quest Tracking)

**Status:** Accepted — Implemented
**Date:** 2026-08-02

---

## Context

By early August 2026 the project's mechanics and epic-quest tracking had spread across six documents, several of them point-in-time dated assessments rather than living references:

- `docs/development/WIP/MECHANICS_REVIEW.md` — the original standing checklist.
- `docs/development/assessments/HP_MANA_REGEN_RUNTIME_REVIEW_2026-08-01.md`
- `docs/development/assessments/SPELL_COMPONENT_CONSUMPTION_REVIEW_2026-08-01.md`
- `docs/development/assessments/MECHANICS_REVIEW_FINAL_RECOMMENDATIONS_2026-08-01.md`
- `docs/development/assessments/EPIC_QUEST_IMPLEMENTATION_AUDIT_2026-08-02.md`
- `docs/research/CLASS_EPIC_QUEST_REFERENCE.md`

Each was internally sound, but reading current status required cross-referencing all six against each other and against `PROJECT_STATUS.md`/`CURRENT_STATE.md`, which had themselves fallen out of sync (see Findings below). This is the specific failure mode the project's own `CODEX_ASSESSMENT_7_30_26.md` had already flagged as "documentation drift — high," and it had gotten worse, not better, since that assessment.

This ADR is scoped narrowly to the mechanics/epic-quest tracking cluster. It does not attempt the full remediation `CODEX_ASSESSMENT_7_30_26.md` recommends (reproducibility ledger, client asset provenance, etc.) — that document remains a separate, standing artifact and is not superseded by this ADR.

## Decision

1. Retire the six documents listed above. Their content is fully absorbed into two new standing documents:
   - **`docs/development/MECHANICS_REVIEW.md`** — replaces the WIP checklist and the three dated mechanics assessments.
   - **`docs/gameplay/EPIC_QUESTS_REVIEW.md`** — replaces the research reference and the epic quest audit.
2. Delete `docs/development/WIP/` entirely (it contained only the retired checklist). No other document in the repository lived in that directory.
3. Both new documents use an explicit status legend (closed-confirmed / closed-accepted / closed-deviation / open-actionable / open-unresearched) and are the single place future mechanics or epic-quest work is tracked. Do not create a new parallel WIP or assessment document for this category of work again — update the two standing documents in place.
4. Every item carried forward from the retired documents was re-audited against the evidence actually on record (not carried forward by assumption). Two miscategorizations were found and corrected during that audit:
   - **ZEM (Zone Experience Modifiers)** was listed as still-actionable in the WIP checklist despite `PROJECT_STATUS.md` explicitly deprioritizing it. Now correctly closed as a deliberate deprioritization in `MECHANICS_REVIEW.md`.
   - **Skill cap enforcement edge cases** was listed as open in the WIP checklist; ADR-013 (2026-08-02) already closed the ceiling defect across 8 classes. Now correctly marked closed in `MECHANICS_REVIEW.md`.
5. `docs/development/assessments/CODEX_ASSESSMENT_7_30_26.md` is explicitly **not** retired — its scope (full project architecture and roadmap) is broader than this ADR's mechanics/epic-quest focus, and it remains a useful standing artifact in its own right.

## Findings: Status-Document Drift

Reviewing `PROJECT_STATUS.md` and `CURRENT_STATE.md` against the full ADR series and the retired documents surfaced drift beyond the mechanics-tracking cluster itself:

1. **Character level claim is materially wrong.** `PROJECT_STATUS.md`'s "Known Issues / Blockers" section states "the six existing characters are level 10 or below, so none of the corrections made to date have caused any loss of previously-learned content." This is contradicted by ADR-012 and ADR-013, both of which work directly against **Angel, a level 40 Iksar Necromancer**, and ADR-013 specifically corrected seven of Angel's already-trained skills (1H/2H Blunt, Bind Wound, Defense, Dodge, Hand to Hand, 1H Piercing, Throwing, Alcohol Tolerance) plus a specialization that had drifted above the true cap — i.e., a real character genuinely lost trained skill values as a direct result of a correction made to date. This claim is corrected in `PROJECT_STATUS.md` and `CURRENT_STATE.md` as part of this ADR.
2. **`PROJECT_STATUS.md`'s "Last Updated" date (2026-07-31) predates ADR-011, ADR-012, and ADR-013 (2026-08-01 through 2026-08-02)**, none of which were reflected in its Current Priorities, Completed, or Recent Major Decisions sections despite the file having been edited after those ADRs were accepted. Corrected as part of this ADR.
3. **Neither status document mentioned the era-containment cleanup script, the mana-regen fix, or their application status** — both are now tracked in `MECHANICS_REVIEW.md` (items 2 and 5) rather than left implicit.

These are documentation corrections, not new decisions — no gameplay or database state changes as a result of this item.

## Findings: Action Status Ratified as Open or Closed

This section is the actual answer to "review whether actions are truly open or closed," consolidated from the audit that produced `MECHANICS_REVIEW.md` and `EPIC_QUESTS_REVIEW.md`. Full detail and evidence live in those two documents; this is the summary record.

**Confirmed closed, no further action:**
- Mana regen minimum floor (`Character:OldMinMana`) — applied.
- Spell component consumption — data and cast-path logic both confirmed correct; no SQL change needed.
- Skill cap ceiling (all 8 audited classes) — ADR-013.
- NPC leash/training-distance — confirmed still disabled.
- Charm break mechanic, social aggro/assist-radius fallback, Feign Death re-aggro percentages, Bind Wound formula, resurrection window, NPC empty/minor corpse decay — all confirmed correct against source or live database.
- ZEM correction — deliberately deprioritized, not abandoned by oversight.
- Fizzle rate, resist scaling, stun mechanics, riposte/dodge/parry, charm duration/CHA, sneak-social-aggro interaction, FD resisted-spell interaction — accepted as current behavior; each is genuinely contested even within P99's own community, and further research time on any of them has a demonstrated low return.
- All 7 audited epic 1.0 quests (Warrior, Shaman, Enchanter, Monk, Cleric, Bard, Necromancer) — database and quest-script structure verified; no update required.

**Genuinely still open, now tracked with a defined next step:**
- HP regeneration racial bonus (`Character:BaseHPRegenBonusRaces`) — credible engineering defect in `CalcHPRegen()`, not yet runtime-tested; may require a server-source patch, not a database change. `MECHANICS_REVIEW.md` item 1.
- Mana regen fix — applied but not yet runtime-verified in-game. `MECHANICS_REVIEW.md` item 2.
- Era-containment cleanup SQL (Beastlord/Berserker grants, `don_nest_unlocked` flag) — **drafted, but no document or commit confirms it was committed against the live database.** Explicitly not assumed applied. `MECHANICS_REVIEW.md` item 5.
- ADR-012 Part 2 (necromancer pet race 485→85, 37 rows) — that ADR's own status section already records this as "Pending... not yet applied," unchanged by this review.
- Casting and combat categories with no research pass at all (spell interruption, recast/recovery enforcement, LoS, critical hit chance, bash/kick). `MECHANICS_REVIEW.md` items 3–4.
- 7 of 14 classes' epic quests entirely unresearched (Paladin, Ranger, Shadow Knight, Druid, Magician, Wizard, Rogue). `EPIC_QUESTS_REVIEW.md`.
- Epic weapon equip-level requirement (adopt P99's level 46 or decide otherwise) — flagged as requiring an explicit project-lead decision, not resolved by this ADR.

## Consequences

- Six documents removed; two created. Net reduction in standing documents for this tracking category, and every remaining item has a single authoritative location.
- No gameplay, database, or client state changes result from this ADR — it is a documentation-architecture decision only, except for the two factual corrections to `PROJECT_STATUS.md`/`CURRENT_STATE.md` described above.
- Future mechanics or epic-quest research must update `docs/development/MECHANICS_REVIEW.md` or `docs/gameplay/EPIC_QUESTS_REVIEW.md` directly. A new dated assessment document for this category should not be created; if a one-off investigation is still useful as a standalone artifact (as `CODEX_ASSESSMENT_7_30_26.md` is, being broader than mechanics), fold its actionable findings into the relevant standing document rather than leaving the investigation as the only record.
- `docs/research/GAME_MECHANICS_REFERENCE.md` and `docs/development/assessments/CODEX_ASSESSMENT_7_30_26.md` are unaffected and remain in place.

## Spire Compatibility

Not applicable — documentation-only change, no schema or data modification.

## Implementation Status

**Implemented 2026-08-02.** `docs/development/MECHANICS_REVIEW.md` and `docs/gameplay/EPIC_QUESTS_REVIEW.md` created. `docs/development/WIP/MECHANICS_REVIEW.md`, the three dated mechanics assessments, the epic quest audit, and `docs/research/CLASS_EPIC_QUEST_REFERENCE.md` removed. `PROJECT_STATUS.md`, `CURRENT_STATE.md`, `README.md`, and `CHANGELOG.md` updated to reflect the new document locations and the character-level correction.
