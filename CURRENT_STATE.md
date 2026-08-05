# Angels Misfits - Current State

## Overview

Angels Misfits is an operational local EverQuest Emulator server running on a Windows environment. The server has moved well beyond a stock PEQ baseline — substantial database correction, mechanical verification, and client-side visual restoration have been implemented and documented via the project's ADR series, changelog, and a growing body of research reference material.

**Current focus:** server-side zone geometry data (zone points, safe coordinates, zone flags) is being reviewed against the classic zone files restored client-side in ADR-008, since visual restoration alone doesn't guarantee the underlying server-side configuration is still consistent with the geometry it's meant to describe. Once that review is complete, work resumes on the mechanics sweep (see below), prioritizing combat, casting, HP regen, and mana regen specifically.

---

# Current Environment

## Server Platform

Current server environment:

- Local Windows installation
- EQEmu Windows Installer v23.10.3 (Akk Stack Docker)
- MariaDB database
- HeidiSQL database management
- Spire server management and configuration workflows
- Rain of Fear 2 (RoF2) client, base client sourced from AddictedDads' "RoF2_Full.zip" (used as a pristine base only; see ADR-008)
- EQEmu MCP — connected and in active use for direct database inspection and modification

## Database State

Current database:

- Originally imported as a pure PEQ database (Sept 2025 dump); has since undergone extensive, documented correction toward classic/Velious-era accuracy across mechanics, content, and pricing systems.

Applied corrections to date (see `docs/decisions/` for full ADR detail, `CHANGELOG.md` for smaller fixes):

- Content scope restricted to Velious-and-earlier (ADR-001).
- Server rules baseline corrected against PEQ/TAKP comparison, including level cap correction to 60 (ADR-002).
- NPC combat stats retuned — HP, damage, AC, resists, regen, aggro radius (ADR-003).
- Spell mechanics fully replaced with verified classic-era data (ADR-004).
- Pet NPC stats retuned (ADR-005).
- Starting item kit corrected (ADR-006).
- NPC model race data corrected — skeleton family (ADR-007).
- Full spell/discipline legacy audit completed across all 14 classes playable through Velious — non-legacy spells disabled, duplicates and wrong-level placements corrected, confirmed omissions restored (ADR-009).
- Faction tier boundaries corrected to match documented classic thresholds across all 8 tiers (ADR-010).
- RoF2 personal-bag and bank container child-slot location format corrected; Angel's affected inventory repaired (ADR-011).
- Necromancer illusion-height defect corrected via a targeted spell-effect override; pet-model race correction (485→85) drafted for 37 rows but not yet applied (ADR-012).
- Skill cap ceiling defect (uncapped linear climb past each class's true maximum) corrected across all 8 classes with characters or relevance to this project, plus 3 gaps found and closed during verification (ADR-013).
- Sense Heading and Swimming skill mechanics corrected to require guildmaster training and skill-up through use, rather than auto-maxing at character creation.
- Bard instrument-modifier mechanic verified correct against classic sources; one broken duplicate spell disabled and a non-classic post-Velious AE DoT restriction reverted.
- Merchant pricing switched from EQEmu's modern flat-markup default to the classic percentage-based/CHA-haggling calculation.
- Harm Touch (Shadow Knight) corrected — two duplicate entries with an incorrect 30-second recast disabled; the correctly-configured 72-minute version retained.
- NPC "leash"/training distance mechanic disabled, restoring classic chase-until-caught behavior rather than the modern distance-based aggro drop.

A systematic, category-by-category mechanics sweep (skills, combat, aggro, corpses, charm, tradeskills, and more) is ongoing and tracked as a living document — see `docs/development/MECHANICS_REVIEW.md` (consolidated and re-audited via ADR-014 on 2026-08-02, replacing the former WIP checklist and three dated point-in-time assessments). Most categories have been researched and checked against source/database; a handful remain genuinely unresolved even by the wider classic-research community and are treated as lower priority rather than open bugs. Two items previously misclassified as open in the retired checklist — ZEM (actually deprioritized) and skill cap enforcement (actually closed by ADR-013) — were corrected during that re-audit.

Remaining known-stock/open areas, in current priority order:

- Server-side zone architecture — zone points, safe coordinates, and zone flags not yet reviewed against the classic geometry restored client-side in ADR-008. Current top priority.
- Mechanics sweep resumption, prioritizing combat, casting, HP regen, and mana regen — see `docs/development/MECHANICS_REVIEW.md` for the specific open/undecided items.
- Item stat-budget conventions (era-appropriate scaling of AC/HP/mana/resists) not yet reviewed.
- Zone Experience Modifiers (ZEM) — likely inherited non-classic values from PEQ's original data; deprioritized, since base experience rate has already been separately adjusted.
- Broader faction system verification (2,105 factions total) beyond the tier-boundary fix — ongoing background item.
- Merchant/vendor inventory verification largely done for Cabilis and Field of Bone; the rest of the world (1,300+ merchants) remains an ongoing background item.
- Tradeskill recipe data (trivial values, component lists) not yet checked against classic sources, though the underlying success-rate formula has been researched and confirmed.
- Class epic quest content for Warrior/Shaman/Enchanter/Monk/Cleric/Bard/Necromancer has passed a live database and active-script audit; see `docs/gameplay/EPIC_QUESTS_REVIEW.md` (consolidated via ADR-014). GM-assisted end-to-end playthroughs remain a regression test, not an open data-verification task. The remaining seven classes (Paladin, Ranger, Shadow Knight, Druid, Magician, Wizard, Rogue) are entirely unresearched. The epic weapon equip-level requirement (P99 uses level 46, of uncertain universality) remains an explicit open decision.
- HP regeneration's Iksar/Troll racial bonus (`Character:BaseHPRegenBonusRaces`) has a credible engineering defect — the live `CalcHPRegen()` code path appears not to read this rule at all — identified 2026-08-01, not yet runtime-confirmed or fixed. See `docs/development/MECHANICS_REVIEW.md`, item 1.
- The classic minimum mana-regen floor (`Character:OldMinMana`) has been applied but not yet runtime-verified in-game. The era-containment cleanup script (Beastlord/Berserker spell-grant cleanup, unused DoN content flag) has been drafted but its application against the live database is unconfirmed. Both tracked in `docs/development/MECHANICS_REVIEW.md`.
- Active out-of-era NPCs (e.g., anachronistic race/NPC placements) not yet audited.

---

# Current Server Architecture

See `docs/architecture/SERVER_ARCHITECTURE.md` for the current architecture overview.

## Client Layer

### Rain of Fear 2 (RoF2)

Client-side classic visual restoration is underway per ADR-008: Luclin player models disabled (individual per-race settings), classic zone files applied (FV Project source), spell icons/gems/effects and skeleton models updated, and TaipoUI selected as the current UI. Two previously-open items have since closed: the Marketplace/Krono UI concern is substantially resolved under TaipoUI, and the Troll/Ogre Luclin-model exception was deliberately dropped from tracking as a low-stakes, reversible preference. Remaining open items include a spell icon mismatch, loading screen restoration (still RoF2-era art), and a deferred general verification pass — see ADR-008 and its addendum for full detail.

---

# Research Reference Material

Beyond the ADR series, the project maintains a set of research and status-tracking documents under `docs/research/`, `docs/development/`, and `docs/gameplay/`, built from systematic comparison against the P99 wiki and other classic-era sources:

- `docs/research/GAME_MECHANICS_REFERENCE.md` — synthesis of P99's core game mechanics documentation (HP/mana formulas, combat damage caps, faction structural mechanics, encumbrance, and more).
- `docs/gameplay/EPIC_QUESTS_REVIEW.md` — quest givers, key NPCs, items, zones, final weapon stats, and live-database verification status for seven of fourteen class epic quests. Consolidated via ADR-014 (2026-08-02).
- `docs/development/MECHANICS_REVIEW.md` — a living, actively-updated checklist tracking the systematic mechanics sweep referenced above, with an explicit open/closed status audit per item. Consolidated via ADR-014 (2026-08-02); not a finished document, intended to be added to across sessions.
