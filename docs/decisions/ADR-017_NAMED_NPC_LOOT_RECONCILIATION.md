# ADR-017: Named-NPC Loot Reconciliation (Classic/Kunark/Velious, Phase 1)

**Status:** Accepted — Implemented
**Date:** 2026-08-06

---

## Context

Following ADR-016's item-drop era gating, a broader pass compared every
Classic/Kunark/Velious named NPC (in-database name starting with `#`, loot
table not shared with any other NPC — 745 NPCs total) against the P99 wiki's
documented loot lists, via three parallel background reviews plus follow-up
reconciliation. Method: MediaWiki batch `action=query` API (confirmed this
session as a reliable, low-cost fetch method for `wiki.project1999.com`,
superseding `WebFetch`, which fails on this domain with a persistent
TLS cert-chain error) to pull `{{Namedmobpage}}` `known_loot` fields, then
direct live-database cross-reference via `mcp__eqemu__run_query`.

Two significant methodology corrections were required and are recorded here
so they aren't rediscovered:

1. **Zone-version contamination.** The initial NPC-selection queries didn't
   filter by `spawn2.version`. Several zones (`citymist`, `droga`, `nurga`,
   `lavastorm`, `paw`) have a second `zone.version = 1` row representing a
   *later* zone revamp with an entirely different named-NPC population.
   `ZoneStore::GetZoneWithFallback` (`common/zone_store.cpp`) hard-falls-back
   to version 0 for any zone request without an explicit version, which is
   what normal `zone_points`-based zoning always does — so version-1
   content is already engine-guaranteed unreachable. Per FV Project's
   Historical Zone Release and Revamp Timeline, all five of these revamps
   date to **Legacy of Ykesha (2003) or Omens of War (2005)** — both *after*
   Planes of Power (October 2002). Per the project's scope policy (below),
   this content is disregarded entirely, not reviewed or flagged.
   `sirens` (Siren's Grotto) is a partial exception — its version-0
   population is real, distinct, mostly-matching content and remains in
   scope; its version-1 population's era is genuinely ambiguous (even P99's
   own wiki editors flag uncertainty on one NPC) and is excluded from this
   migration pending further evidence.
2. **"Replacement ID doesn't exist" is not evidence of a defect** (carried
   forward from ADR-016) — always check actual field/loot values before
   concluding something needs fixing.

**Scope policy adopted this session (added to `CLAUDE.md`):** content-flag
and review effort is only justified for content from Planes of Power or
earlier. Later-expansion content (Legacy of Ykesha onward) is disregarded
entirely — not reviewed, not flagged. This also puts the parallel
NPC-stat-reconciliation effort's staged `GatesOfDiscord_GlobalDrops` /
`SecretsOfFaydwer_GlobalDrops` content flags (both well past PoP) out of
scope; that script should not be applied as currently drafted.

## Decision

Fix the confirmed high-confidence findings by **adding the missing
`lootdrop_entries` rows** (the inverse of ADR-016 — these are documented
classic-era drops currently *absent* from live loot, not later-era drops
that should be absent) into the same `lootdrop_id` that already holds each
NPC's other wiki-confirmed items, inferred from existing sibling-item
placement where the wiki source doesn't give an exact chance. One finding
(Chief RokGus / Eye of RokGus) is the ADR-016 pattern in reverse — a
documented-removed item still live — and is gated via `content_flags`,
consistent with that ADR's mechanism and this project's
gate-don't-delete policy.

Two NPCs (Lhranc, High Scale Kirn) have **no loot table at all**
(`npc_types.loottable_id = 0`) despite the wiki documenting a 100%-rate
drop for each — these require creating a new `loottable`/`lootdrop`
pair, not just a `lootdrop_entries` row.

## Scope: Phase 1 (this migration)

Only **high-confidence, unambiguous** findings are included — a wiki-
documented item cleanly absent from an otherwise-matching loot table, with
an obvious existing sibling lootdrop to add it to. Findings requiring a
design judgment call (large-scale set replacements, possible
mis-assignment between two NPCs, wiki-flagged uncertain rarity/source) are
explicitly deferred to Phase 2 — see below.

### Classic

| NPC | Zone | Item(s) added | Lootdrop | Chance | Source |
|---|---|---|---|---|---|
| `#Avatar_of_Abhorrence` (186163) | hateplaneb | Scaled Hierophant Boots (5182) | 22827 | 11.0% | Wiki-sourced |
| `#Lord_of_Ire` (186154) | hateplaneb | Shield of the Immaculate (11551) | 3735 | 23.8% | Wiki-sourced |
| `#Lord_of_Loathing` (186155) | hateplaneb | Beckon (11559) | 141036 | 23.8% | Wiki-sourced |
| `#Master_of_Spite` (186165) | hateplaneb | Tunarian Scimitar (11563), Scaled Hierophant Breastplate (5187), Scaled Hierophant Helm (5188) | 141057 | 15.0% each | Inferred — matches sibling gem/named tier in same lootdrop |
| `#Sentry_Alechin` (14036) | southkarana | Fine Steel Dagger (7350) | 9378 | 12.5% | Inferred — wiki: alternate to Fine Steel Long Sword in the same slot, matched to its rate |
| `#Battlelord_Paluk` (11015) | runnyeye | Blackened Alloy Boots (3610), Blackened Alloy Waistband (3605), Mithril Amulet (10047) | 1974 | 8.25% each | Wiki-sourced range (8.2-8.5%) |
| `#Lord_Pickclaw` (11017) | runnyeye | Black Alloy Girdle (3611) | 165432 | 18.2% | Wiki-sourced |
| `#Lord_Pickclaw` (11017) | runnyeye | Emerald Ring (10045) | 165432 | 10.0% | Inferred — no wiki rate given, matched to lootdrop's gem tier |
| `#a_zombie` (45126) | qcat | Zombie Skin (13074), Embalming Dust (16990) | 23498 | 50.0% each | Inferred — no wiki rate given, common-tier default |
| `#High_Scale_Kirn_` (39161) | hole | Engraved Ring (1681) | *(new loottable/lootdrop)* | 100.0% | Wiki-sourced ("Always") |

### Kunark

| NPC | Zone | Item(s) added | Lootdrop | Chance | Source |
|---|---|---|---|---|---|
| `#Embalming_Fluid` (105075) | charasis | Enshrouded Veil (1625) | 830 | 50.0% | Inferred — midpoint of sibling items (45%/55%) |
| `#Gorgul_Paclock` (87113) | burningwood | Straw Spun Belt (11545), Giant Grub Digger (11537) | 158825 | 25.0% each | Wiki-sourced |
| `#Korocust` (103219) | chardok | Incarnadine Greaves (4137), Incarnadine Legplates (5711) | 2093 | 20.0% each | Inferred — matches flat 20% sibling tier |
| `#Reanimated_Plaguebone` (105013) | charasis | Gem Inlaid Band (14752), Kunzar Hex Amulet (10344) | 124227 | 25.0% each | Inferred — no wiki rate given |
| `#Sentient_Bile` (105091) | charasis | Mucilaginous Girdle (2737), Acid Etched War Sword (5656), Stein of Tears (14748), Melodious Truncheon (6609) | 16850 | 25.0% each | Inferred — matches sibling Burnished Helm's 25% |
| `#The_Undertaker_Lord` (105160) | charasis | Kylong Gauntlets (3217) | 1850 | 2.0% | Inferred — matches sibling Thorny Blackjack's rare-tier rate |
| `Captain_of_the_Guard` (90220, v0) | citymist | Rune of Al`Kabor (11746), Words of Projection (11855) | 178602 | 0.2% each | Inferred — matches the generic Rune/Words filler tier already in this lootdrop |
| `Lhranc` (90221, v0) | citymist | Innoruuk's Curse (14383) | *(new loottable/lootdrop)* | 100.0% | Wiki-sourced ("Always") — **Shadow Knight Epic 1.0 quest-blocking fix** |
| `Chief_RokGus` (81187, v0) | droga | **Gate** Eye of RokGus (12881, lootdrop 178455) | — | — | Wiki: "No longer drops" — same pattern as ADR-016 |

### Velious

| NPC | Zone | Item(s) added | Lootdrop | Chance | Source |
|---|---|---|---|---|---|
| `#Ulth_the_Enraged` (125097, v0) | sirens | Gold Ring (10008), Silver Earring (10006) | 178678 | 50.0% each | Inferred — wiki tags these "common_loot" vs. the 20-30% "rare" tier already present |
| `#Travala` (120063) | westwastes | Huge Drake Wing (27264) | 12583 | 15.0% | Inferred — no wiki rate recorded, signature-drop default |
| `#a_dracnid_retainer` (121087) | crystal | Crystal Lined Slippers (25649) | 23091 | 22.0% | Inferred — matches sibling Crystallized Two Handed Sword's rate |
| `#Zorglim_the_Dead` (111132) | frozenshadow | Beer Stained Coldain Tunic (29117) | 19465 | 2.0% | Inferred — matches the full Crystallized Shadow set's flat 2% tier |
| `#Watch_Sergeant_Vedravik` (113485) | kael | Frost Giant Meat (22800), Frost Giant Toes (29125), Giant Scalemail Boots (25016) | 126957 | 40%/40%/15% | Inferred — no exact peer rate recorded; loot table was nearly empty (only Rock Fern) vs. every peer Watch Sergeant having 3-4 items |

**Item ID note:** `Gold Ring` exists under 3 separate IDs in this database
(10008, 13732, 22282); 10008 was selected as it's the dominant generic
version (719 existing loot-table uses, level range 1-50, covering Ulth's
level 50) — 13732 is a lower-level variant (avg level ~13) and 22282 is
currently unused by any loot table.

## Deferred to Phase 2 (documented, not migrated)

Requires further research or a design decision before a mechanical fix is
appropriate:

- **Oglard / Eldriaks Fe`Dhar** (skyshrine) — missing ~32-item signature
  set, near-total non-overlap. Too large to blindly restore without
  confirming this wasn't an intentional redesign.
- **9 "lesser" Temple of Veeshan dragons** — wiki documents a shared
  wearable set; live DB uses an entirely different rune/symbol itemization
  scheme. Needs a design decision: intentional redesign or genuine gap.
- **Final Arbiter / Progenitor / Master of the Guard** (sleeper) — wiki's
  weapon set is a boilerplate pool shared across pages, and the same set
  *is* already correctly assigned to the tier-below "Warder" trio — likely
  not a bug.
- **Possible mis-assignments, not simple additions:** `#War_Priestess_T`zan`
  (Two Handed Sword currently on `#Brigadier_G`tav`'s table instead),
  `Amcilla` (Greater Dragon's Head currently on sibling `Nintal`'s table).
- **Wiki-flagged uncertain items:** `#Yymp_the_Infernal` (Golden Earring,
  wiki tags rarity "Unknown"), `#Shaman_Ren`Rex` (all three items marked "?"
  on wiki), `#Watchman_Tylem` (kael — wiki's Frost Giant flavor is the
  outlier vs. every peer's Storm Giant flavor; likely a wiki error, not a
  DB bug).
- **Non-existent target item:** `#Brother_Qwinn`'s "Torn Cloth Tunic" isn't
  in the `items` table under that name at all — needs identification
  (possible rename) before any fix.
- **Small/low-value, low priority:** `#Guard_Delrenderak` (generic Diamond),
  the 7-NPC "Giant Scalemail Boots" cluster and 3-NPC "Kromrif Head"
  cluster in Kael, `#Icecrafter_Leyreon`, the `stonebrunt` 4-NPC set,
  `#a_focus_gem`/`#a_gem_collector`/`#a_life_leech` (crystal, generic
  gems), `Yvolcarn`/`Azureake` (cobaltscar), `#The_Head_Usher`
  (frozenshadow), `#Tpos_Icepaw`/`#Ular_Icepaw` (velketor), `Gozzrem`
  (templeveeshan), `#The_Sporali_Moldmaster`'s Grimoire page,
  `#Interrogator_Gi`mok`'s two Ultra Rare spells,
  `#an_Iksar_manslayer` (looks like a broader table swap, not a
  targeted removal), `#froglok_krup_knight` (tradeskill reagents, not
  gear), `Midnight`'s tiered cougarskin drops.
- **`sirens` version-1 population** — genuinely ambiguous era (see
  Context); excluded pending better dating evidence.
- **`Mistress_Latazura`'s "Drums of the Beast" gap** — real finding, but
  the NPC's own wiki page carries an unresolved P99-editor doubt about
  whether it predates the zone revamp at all; deferred alongside the
  version-1 question above rather than fixed in isolation.

Full source detail for every finding above (wiki text, live-loot dumps,
confidence rationale) remains in the three source review documents pending
cleanup: `docs/development/assessments/TEMP_2026-08-06_named_npc_loot_review_{classic,kunark,velious}.md`.

## Mechanism / Implementation

Standard `lootdrop_entries` INSERT for the missing-item cases (existing,
documented EQEmu mechanism — no schema change). Chief RokGus's Eye of
RokGus follows ADR-016's `content_flags` gating pattern exactly, using a
new flag scoped to Kunark item-drop corrections. Lhranc and High Scale
Kirn require a new `loottable` + `lootdrop` row each (via
`LAST_INSERT_ID()` chaining within the transaction) since their
`npc_types.loottable_id` is currently 0 — both are documented 100%/Always
drops, so no probabilistic design judgment is needed there.

Migration: `scripts/2026-08-06_named_npc_loot_reconciliation_phase_1.sql`.

## Consequences

- 22 NPCs across Classic/Kunark/Velious gain their documented classic-era
  loot; one (Lhranc) fixes a Shadow Knight Epic 1.0 quest-blocking defect
  (a required 100%-drop component was completely unobtainable).
- One item (Eye of RokGus) stops dropping, matching its documented removal,
  reversible via the same one-row `content_flags` toggle as ADR-016.
- Several "inferred" chance values are approximations grounded in sibling-
  item rates within the same lootdrop, not primary-sourced — flagged
  individually in both this table and the migration script's comments so
  they can be corrected later if better data surfaces. This is a
  deliberate trade-off to keep Phase 1 bounded and shippable rather than
  blocking on percentage precision for items whose *presence* is the real
  finding.
- Phase 2's ~25 deferred findings remain documented but unapplied — future
  work, not lost.

## Spire Compatibility

No schema changes — `loottable`, `lootdrop`, `loottable_entries`,
`lootdrop_entries`, and `content_flags` are all existing PEQ tables Spire
already supports. DML only (plus two new parent rows via standard
auto-increment inserts, not a schema change).

## Implementation Status

**Implemented and verified 2026-08-06.** Applied manually (MCP connection is
read-only) and confirmed live via direct post-run query:

- All 37 individual `lootdrop_entries` additions present with the correct
  item and chance values (spot-checked against the migration's own list,
  zero discrepancies).
- Lhranc (new `loottable_id` 110870) and High Scale Kirn (new
  `loottable_id` 110869) both now resolve to a real loot table with exactly
  their one documented 100%-drop item.
- Eye of RokGus (item 12881, lootdrop 178455) correctly shows
  `content_flags = 'Kunark_LegacyItemDrops'`; no other row in this
  migration's scope was flagged.

**Note (unrelated to this ADR):** the same application pass also applied
`scripts/2026-08-06_npc_reconciliation_content_flags_phase_1.sql` (Codex's
Gates of Discord / Secrets of Faydwer content flags), which this ADR's
Context section flags as out of scope under the project's PoP-or-earlier
policy. Both flags are `enabled = 0` so there's no live gameplay impact,
but this is a pending decision for the user: leave as harmless-but-
out-of-policy, or roll back for consistency.
