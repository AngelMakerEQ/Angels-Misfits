# Angels Misfits Architecture Assessment

**Review date:** 2026-07-30  
**Scope:** All ADRs in `docs/decisions`, all entries in `CHANGELOG.md` and `PROJECT_STATUS.md`, `docs/development/WIP/MECHANICS_REVIEW.md`, and all files in `docs/research`.

## Executive Assessment

Angels Misfits is a well-documented, configuration-first EQEmu project. Its core design is coherent: preserve Velious-era gameplay and class identity while allowing intentional solo-multibox quality-of-life deviations. It relies on stock EQEmu, a PEQ-compatible MariaDB schema, documented data/rule corrections, RoF2 client restoration, and VV MQ compatibility rather than a server-code fork.

The completed correction work is substantial and generally well validated: expansion gating, level-cap correction to 60, classic spell mechanics, class spell availability, NPC and pet tuning, starting inventory, skeleton models, faction boundaries, skill behavior, bard mechanics, merchant pricing, and NPC chase behavior. The project’s database verification standard is particularly strong: direct live queries, targeted checks, random samples, exclusion checks, and anomaly investigation.

The central architectural weakness is reproducibility. The live database currently contains the real implementation, while the repository primarily documents it. **Update (2026-08-05):** since this review, applied migrations have increasingly been captured as versioned, committed SQL scripts under `scripts/` — this is no longer accurate as an absolute claim. A full rule-value export and a client patch manifest still do not exist, so the underlying gap (not everything needed to deterministically rebuild the live state is versioned) remains real, just narrower than originally assessed.

## Architecture Map

```text
RoF2 client + TaipoUI + VV MQ
        |
EQEmu server (stock engine; no fork)
        |
MariaDB live database
  |- PEQ schema/current-era content baseline
  |- TAKP-claimed-database/classic-client-derived mechanical corrections
  `- rule_values, NPCs, spells, starting items, factions
        |
Administration: Spire, HeidiSQL, MCP
        |
Repository: ADRs, research, status, and standards
```

| System | Current State | Principal Risk |
|---|---|---|
| Content scope | Velious gate implemented through expansion rules | Items and NPC spell/loot content have no complete era-scoping strategy |
| Combat | NPC/pet data tuned; classic spell data adopted | Some outcomes are tuning derived from the unverified TAKP-claimed comparison database rather than independently historical values (see `docs/research/TAKP.md`) |
| Spells/classes | 37,729 spell records restored; 14-class availability audit complete | NPC spells and post-era residual data still need auditing |
| Character progression | Level 60, faster XP, no race/class penalties | Deliberate QoL deviations need periodic balance validation |
| Faction/economy | Global faction tiers and classic price formula corrected | Per-faction data, starting standings, vendor greed, and inventories remain largely unaudited |
| Quests/content | Seven epic quest references researched | No end-to-end database/script/drop verification; seven classes unresearched |
| Client | Classic assets/UI mostly applied | Asset provenance, loading screens, icon mismatch, Velious visuals, and visual regression testing remain open |
| Operations | MCP, Spire, HeidiSQL; no custom schema | Live changes are not reproducibly represented in versioned migrations |

## Completed Architectural Decisions

- **ADR-001:** Restricts normal player access to Classic, Kunark, and Velious through `World:ExpansionSettings = 3`, `Expansion:CurrentExpansion = 2`, character-select gating, and disabled client-based expansion settings. The full PEQ dataset is intentionally retained.
- **ADR-002:** Establishes a PEQ/TAKP-claimed-comparison-database-informed rules baseline; restores selected classic mechanics while deliberately retaining faster XP, no race/class XP penalties, bind-anywhere, no de-leveling, and very long item-corpse persistence. The cap was corrected from 50 to the historically correct 60.
- **ADR-003:** Applies NPC HP, damage, AC, resists, and regeneration derived from the TAKP-claimed comparison database (unverified provenance — internal self-consistency with that file's own claims, not primary-source verification; see `docs/research/TAKP.md`); uses a custom PEQ/comparison-database midpoint for aggro radius to account for multibox play.
- **ADR-004:** Replaces 37,729 `spells_new` records with values verified byte-for-byte against a classic client spell file — genuine primary-source verification, independent of the comparison database's own provenance.
- **ADR-005:** Applies mixed pet-template tuning from the TAKP-claimed comparison database (same unverified-provenance caveat as ADR-003): weaker damage/regen, altered resists, and faster movement.
- **ADR-006:** Removes the non-classic Gloomingdeep Lantern and starting backpack while retaining classic notes, food, weapons, bandages, and starter spells.
- **ADR-007:** Corrects skeleton-family NPC model IDs while preserving genuine Iksar-identity NPCs; acknowledges the unsolved client limitation around playable-race NPC models.
- **ADR-008:** Partially restores classic RoF2 presentation with classic zone overrides, spell assets, skeleton assets, Luclin-model configuration, and TaipoUI.
- **ADR-009:** Audits all 14 Velious-playable classes, disables non-legacy spells/disciplines, fixes wrong levels/duplicates, restores omissions, and resolves Harm Touch duplicate behavior.
- **ADR-010:** Corrects eight global faction-tier boundaries and verifies the core faction-hit mechanism against a documented example.

**Update (2026-08-05):** five further ADRs have been accepted since this list was written — ADR-011 (RoF2 inventory container location format), ADR-012 (necromancer illusion-height and pet-model race corrections), ADR-013 (skill cap ceiling correction, all 8 relevant classes), ADR-014 (mechanics/epic-quest documentation consolidation), and ADR-015 (spell particle texture restoration — a defect not yet discovered at the time this assessment was written). Not individually detailed here — see `CHANGELOG.md` and `docs/decisions/` for full detail on each.

## Unfinished Work

### Mechanics verification

The active priority is correctly the mechanics sweep. Its remaining work should be consolidated into a single definitive checklist:

- Aggro and spell-casting line-of-sight.
- Snare stacking, item stacking, skill-cap edge cases, critical-hit chance, bash/kick mechanics, and pet attack/leash range.
- Spell interruption, reagent consumption, and recast/recovery enforcement.
- Corpse summoning/range and item-loss mechanics beyond configured thresholds.
- Levitate interactions and pet command responsiveness.
- Foundational source checks: HP/mana formulas, racial regeneration, meditation, weapon caps, encumbrance, Bind Wound, tradeskill success behavior, and selected NPC AI behavior.
- Confirmation that AA/veteran rewards and guild mechanics are inaccessible under the Velious gate.
- Explicit final disposition for contested subjects such as fizzle rate, resists, sneak social aggro, charm/CHA, and Feign Death resisted-spell behavior.

### Content and progression

- Complete per-faction verification across 2,105 factions, including starting standings, kill/quest increments, and social-assist relationships.
- Resolve the documented P99 faction-tier source conflict or record the current ADR-010 values as an accepted evidence-based decision.
- Audit item era/stat budgets, item/loot exposure, tradeskill recipe and trivial-value data, and out-of-era NPCs.
- Continue merchant inventory verification outside Cabilis and Field of Bone; begin per-vendor `greed` calibration.
- Finish epic research for Paladin, Ranger, Shadow Knight, Druid, Magician, Wizard, and Rogue.
- **Update (2026-08-05):** the other 7 classes (Warrior, Shaman, Enchanter, Monk, Cleric, Bard, Necromancer) have since passed a database/quest-script structural audit — see `docs/gameplay/EPIC_QUESTS_REVIEW.md`. Live end-to-end player verification (GM-assisted walkthroughs) remains outstanding for those 7; the other 7 classes remain entirely unresearched as originally noted.
- Complete deep content reviews of the eleven identified external repositories only where they fill a specific project gap.

### Client and operations

- Isolate the spell-icon mismatch between FV assets and TaipoUI.
- Research or replace RoF2 loading-screen art.
- Research Velious-era zone visual restoration.
- Run a formal in-client visual and VV MQ compatibility pass.
- Verify Krono is absent from the database.
- Run the planned VV MQ subscription-lapse behavior test.

## Technical Debt

### 1. Reproducibility debt — critical at the time, partially resolved since

**Update (2026-08-05):** `scripts/` is no longer effectively empty — several transactional, committed migration scripts now exist (e.g. era-containment cleanup, classic minimum mana regen, necromancer pet race correction, RoF2 inventory/personal-bag repairs). The core gap this item identified — no comprehensive rule-value export and no client patch manifest — is still real and still worth solving, but the specific claim that no migrations are versioned at all is now out of date.

### 2. Documentation drift — high (as of this review's date)

**Update (2026-08-05):** every specific item originally listed here has since been resolved — ADR-004 reads `Implemented` outright; the WIP progress log (and the leash-behavior contradiction it caused) no longer exists, retired via ADR-014; `PROJECT_STATUS.md`'s character-level claim was corrected via ADR-014 (Angel is level 40, and ADR-013 measurably reduced several of her trained skills); `ROADMAP.md` has been brought current through ADR-015 and `CURRENT_STATE.md` was retired into `PROJECT_STATUS.md` to remove the duplication that caused this drift in the first place; ZEM's WIP-vs-status contradiction no longer exists, also retired via ADR-014. This item is left in place as a record of a real, now-closed problem, not as an open action item.

### 3. Evidence-quality debt — high

The project appropriately distinguishes source strength, but high-impact decisions span classic-client evidence, EQEmu behavior, tuning derived from the TAKP-claimed comparison database, P99 research, and intentional house rules. Future work should consistently label each conclusion as verified historical behavior, verified EQEmu behavior, community consensus, inference, or deliberate deviation. **Update (2026-08-06):** this specific gap was acted on — the comparison database's unverified provenance is now explicitly documented in `docs/research/TAKP.md`, and `CLAUDE.md`/`AGENTS.md` no longer treat it as an authoritative source in the research priority hierarchy.

### 4. Era-containment debt — high

The expansion rules prevent ordinary post-Velious access, but the retained PEQ dataset still contains later-era items, spells, loot, scripts, and NPC data. Item, loot, quest, and NPC-spell exposure needs a repeatable audit approach before broader progression reaches those edges.

### 5. Client supply-chain debt — medium

FV Project assets were applied selectively without version pinning, checksums, or independently verified original provenance. That impedes reproducible client rebuilds and diagnosis of visual defects.

### 6. Testing debt — medium

Database verification is excellent, but the formal testing standard does not yet cover client restoration, quest scripts, or player-facing gameplay regression scenarios.

## Development Roadmap

### Phase 1: Stabilize the project record

1. Reconcile `PROJECT_STATUS.md`, `ROADMAP.md`, `CURRENT_STATE.md`, ADR implementation headers, WIP logs, and character records. **Update (2026-08-05): done** — ADR-014 reconciled the mechanics/epic-quest tracking cluster and corrected the character-level claim; `CURRENT_STATE.md` has since been retired (its unique content folded into `PROJECT_STATUS.md`) and `ROADMAP.md` brought current through ADR-015, removing the exact duplication that caused this drift.
2. Create a live-state ledger recording each decision, migration ID, expected final state, evidence, verification date, and intentional deviations. Still outstanding.
3. Version all applied migrations and rule changes, with rollback/rebuild guidance where practical. **Partially done** — recent migrations are captured as committed, transactional SQL scripts under `scripts/`; a comprehensive rule-value export/ledger still does not exist.
4. Create a RoF2 patch manifest with file paths, sources, checksums, dates, and rollback location. Still outstanding.

### Phase 2: Close the mechanics baseline

1. Resolve high-confidence, player-visible checks first: line-of-sight, stacking, skill caps, special attacks, pet command/range.
2. Verify HP/mana/meditation, weapon caps, encumbrance, Bind Wound, tradeskill behavior, and selected NPC AI.
3. Confirm AA/guild gating and address the faction-tier evidence conflict.
4. Mark contested mechanics as accepted EQEmu behavior unless stronger primary evidence appears.

### Phase 3: Build a zone-driven content audit

1. Audit zones actually used for progression first: Kurn’s Tower, the Kunark leveling path, then Velious progression.
2. For each zone, record NPC era validity, spawns, loot, merchants, faction hits, quest hooks, and relevant itemization.
3. Use a shared audit matrix with `verified`, `discrepancy`, `intentional deviation`, and `unverified` dispositions.
4. Prioritize itemization and tradeskills ahead of world-wide vendor coverage.

### Phase 4: Verify epics through a vertical slice

1. Finish research for the remaining seven epics.
2. Select one active class epic, preferably Shaman or Monk, and verify it end-to-end in the live database.
3. Turn the first pass into a reusable epic-validation checklist, then apply it to all fourteen classes.
4. Make an explicit decision on epic equip-level requirements rather than inheriting P99 behavior without evidence.

### Phase 5: Finish client restoration as a release

1. Diagnose spell icons using default RoF2 UI versus TaipoUI.
2. Resolve loading screens and research Velious visual assets.
3. Add a visual/VV MQ regression matrix covering races, humanoid NPCs, skeletons, zone loads, spell casting, gems/icons, UI windows, and target information.
4. Treat client changes as versioned release artifacts rather than informal asset copies.

### Phase 6: Ongoing maintenance

1. Run periodic live-database-versus-repository drift checks.
2. Continue faction, vendor, and out-of-era NPC verification opportunistically through zone audits.
3. Evaluate external repositories only against named roadmap gaps and import nothing without evidence, reversible migrations, and verification.

## Final Recommendation

The project has a strong design philosophy and unusually careful research/verification discipline for an EQEmu customization effort. Before the next large content pass, prioritize reproducible migrations and status-document reconciliation. This will preserve the value of the work already completed and make future mechanics, itemization, quest, and client corrections safer to implement and easier to maintain.
