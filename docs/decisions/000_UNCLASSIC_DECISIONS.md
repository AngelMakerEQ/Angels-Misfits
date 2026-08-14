# Intentional Non-Classic Decisions

This document is the standing record of places where Angels Misfits **deliberately chose not to match classic-era behavior**, as distinct from the project's default posture (era accuracy, per `docs/architecture/DESIGN_PHILOSOPHY.md`'s "authentic where players notice" priority). Every entry here represents a conscious trade-off, not a defect, a research gap, or an oversight — those belong in `docs/database/PEQ_CHANGES.md`, `docs/decisions/ADR-NNN_*.md`, or `CHANGELOG.md` instead.

Per `docs/architecture/DESIGN_PHILOSOPHY.md`: *"This is a solo/private, multibox-friendly server — quality-of-life deviations from strict historical pacing (death penalty, exp rate, downtime) are acceptable if they preserve the feeling of progression rather than just speeding through it."* That principle is the umbrella justification for most entries below; each still states its own specific reasoning.

**Filename note:** this file is prefixed `000_` rather than `ADR-NNN_` so it sorts above the ADR series in directory listings — it's an index of a *category* of decision spanning many ADRs and standalone rule changes, not a single decision itself.

---

## Item power retention (2026-08-06)

Three items where the documented Velious-era nerf/replacement is **not** applied, keeping the more powerful Kunark-era version live instead — the opposite direction from ADR-016/017's era-accuracy gating.

| Item | Classic/documented behavior | Decision | Mechanism |
|---|---|---|---|
| **Circlet of Shadow** (14730) vs. **Circlet of Shadows** (29400) | P99: nerfed from instant-cast to 5-second-cast Gather Shadows ~6 months into Velious (June 2001) | Keep the instant-cast original live | `content_flags` — `VeliousNerfs_Suppressed`, disabled by default (nerf not applied) |
| **Earring of Grachnist** (10587) | P99: "apparently replaced by Shrunken Goblin Skull Earring somewhere in the timeline" | Restore the original alongside its replacement (which stays too) | Same flag |
| **Donal's Chestplate of Mourning** (4565) | P99: Complete Heal click effect "nerfed in Velious and eventually removed" | Keep the full, un-nerfed Complete Heal effect | No DB change needed — this database's copy was never nerfed to begin with; decision recorded here so it isn't "fixed" by a future era-accuracy pass |

Migration: `scripts/2026-08-06_kunark_item_power_retention.sql` (Circlet of Shadow and Earring of Grachnist only — Donal's Chestplate required no data change).

---

## Server rules and pacing (ADR-002, `docs/database/PEQ_CHANGES.md`)

| Setting | Classic value | This server | Reason |
|---|---|---|---|
| `Character:UseOldClassExpPenalties` | true | false | Removes classic class-based exp penalties; solo play |
| `Character:UseOldRaceExpPenalties` | true | false | Removes classic race-based exp penalties; solo play |
| `Character:BindAnywhere` | false | true | Explicitly labeled in ADR-002 as a deliberate non-classic deviation |
| `Character:DeathKeepLevel` | false (classic allowed de-leveling on death) | true | No de-leveling on death |
| `Character:DeathExpLossLevel` / `DeathItemLossLevel` | 10 (PEQ) / 5 or 90 (TAKP-claimed comparison database) | 15 (custom) | A deliberate compromise value matching neither source |

## NPC combat tuning (ADR-003)

| Field | Comparison-database value | This server | Reason |
|---|---|---|---|
| `aggroradius` | Full widening per the TAKP-claimed comparison database (unverified provenance — see `docs/research/TAKP.md`; not necessarily "era-accurate," just the comparison database's value) | Arithmetic midpoint of PEQ/comparison-database values, **for NPCs not yet individually reconciled under ADR-018** | Full widening was "too punishing for multibox play" — a deliberate reduction below what the comparison database suggested |

**Superseded per-NPC by the active NPC reconciliation process (verified 2026-08-12):** ADR-003's midpoint formula was a bulk, comparison-database-derived approximation — reasonable as a starting point, but the comparison database is not an authoritative source (`docs/research/TAKP.md`). ADR-018 (itself marked Superseded 2026-08-10 — its own forward-looking process is retired, retained only as Phase 1's historical record) named the origin of this work; the actual current, sole process is `docs/development/wip/NPC_RECONCILIATION_REMAINING_ZONE_ROADMAP.md`, which cross-references the live database directly against P99's wiki (this project's top-priority historical source) NPC by NPC and overrides the midpoint value where the primary source disagrees — **168 NPCs already carry a P99-sourced `aggroradius` different from their ADR-003 midpoint value**, per `npc_reconciliation_staging.target_aggroradius`, as reconciliation continues. This is not itself a second non-classic decision (this process pursues era accuracy, the opposite direction from this document's purpose) — it's noted here only so the row above isn't read as a still-universal, still-current policy. Neither ADR-003 nor ADR-018 currently cross-references this process; that gap should be closed in both documents.

## Standalone rule/behavior decisions (logged directly in `CHANGELOG.md`, no ADR)

| Decision | Classic behavior | This server | Reason | Date |
|---|---|---|---|---|
| `Character:EnableBardMelody` | Disabled in later-era-accurate configs | Left enabled | "A conscious deviation, not an oversight" — player convenience | 2026-07-28 |
| Epic weapon equip-level requirement | P99: gated at level 46 (anti-twink) | Left ungated | Server is currently single-player; the twinking scenario the gate guards against doesn't apply. Revisit if a second character reaches endgame | 2026-08-05 |

## Content placed on inferred rather than documented coordinates

Distinct from the rows above: these are not gameplay preferences but
**sourcing** deviations — content positioned from evidence weaker than this
project's normal historical-source bar, recorded so a later era-accuracy pass
knows the placement was inferred and can revisit it if better data appears.

| Content | What the era sources say | This server | Reason | Date |
|---|---|---|---|---|
| Western Wastes named dragons — Bufa, Makala, Mav/Rak/Zil Sapara, Yal (ADR-023) | **No source records their spawn location.** P99's roster gives `Location = ?`; the FV Project 2001 ShowEQ dataset contains no Velious zones; the archived 2001 gameznet pages read "Submit this Info!" | Spawned at coordinates derived from Brewall's **live-EQ** map POIs, via a transform validated to 7u median across 9 zones | They existed as correct `npc_types` templates with matching levels and full loot tables but had never had a spawn point, so six documented encounters were unreachable. Approximate placement judged better than absence; all six roam within a 2500u box, so exact origin matters less | 2026-08-14 |
| Seven orphaned NPCs across Ak'Anon, Everfrost, Great Divide, Plane of Growth, The Hole, Iceclad and Rathe Mountains (ADR-024) | P99 documents the NPCs but records no spawn location | Same method — Brewall live-EQ POI coordinates, each validated in-bounds and against its nearest existing spawn | Same reasoning as above. Several landed beside thematically matching neighbours (elder spearguard 173u from a Snowfang spearguard; Coldain war wolf 308u from a Coldain tracking wolf), which corroborates the derivation | 2026-08-14 |
| Sivar spawn-share dilution (ADR-024) | P99 documents Sivar as a Myga placeholder pop, not a fixed spawn | Added to Myga's existing rotation (spawngroup 16324) at equal weight, reducing the other five members from 20% to ~16.7% each | Making Sivar reachable required joining that rotation. Diluting five NPCs' spawn share was judged a smaller misrepresentation than inventing a separate fixed spawn point P99 does not document | 2026-08-14 |

---

## Review note

This list was compiled 2026-08-06 by cross-referencing `CHANGELOG.md`, `docs/database/PEQ_CHANGES.md`, and ADR-002/003 for entries explicitly self-labeled as "deliberate," "deviation," or a stated trade-off. It does not include:
- **Corrections toward classic accuracy** (the large majority of this project's work) — those are era-accuracy fixes, not the intentional deviations this document tracks.
- **Open/unresolved research items** (e.g. `MECHANICS_REVIEW.md` open items) — those aren't decisions yet.
- **Infrastructure/tooling choices** unrelated to gameplay authenticity (e.g. rejecting EQEmu's `Bots:*` system in favor of VV MQ multiboxing) — neither option is "classic," so there's no classic-vs-non-classic trade-off to record.

Add new entries here whenever a future decision explicitly chooses a non-classic outcome over an available classic-accurate one — that's the trigger for this document, not the ADR trigger in `CLAUDE.md`. A decision can warrant both an ADR (for the mechanism/implementation) and an entry here (for the classic-vs-chosen trade-off) if it's substantial enough.

**2026-08-12 verification pass:** every table entry above was checked directly against live database state (rule_values, content_flags, lootdrop_entries, items, character levels) rather than re-derivation from memory. All held up except the `aggroradius` row, which was stale in a way that mattered — see the note added under "NPC combat tuning" above. Everything else (item power retention's content_flags/lootdrop rows, all `Character:*` rule values, the epic-weapon single-character-endgame premise) matches live state exactly as documented.
