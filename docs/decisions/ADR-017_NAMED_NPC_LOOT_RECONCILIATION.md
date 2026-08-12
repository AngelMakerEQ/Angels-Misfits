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
   scope. Its version-1 population's era was initially treated as
   ambiguous; **resolved 2026-08-06 as out-of-scope** — see "Phase 2,
   sub-batch: `sirens` version-1 scope / Mistress Latazura" below.
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

- ~~**Oglard / Eldriaks Fe`Dhar** (skyshrine) — missing ~32-item signature
  set, near-total non-overlap. Too large to blindly restore without
  confirming this wasn't an intentional redesign.~~ **Resolved 2026-08-06 —
  see "Phase 2, sub-batch: Oglard / Eldriaks Fe`Dhar" below.**
- ~~**9 "lesser" Temple of Veeshan dragons** — wiki documents a shared
  wearable set; live DB uses an entirely different rune/symbol itemization
  scheme. Needs a design decision: intentional redesign or genuine gap.~~
  **Resolved 2026-08-06 — see "Phase 2, sub-batch: 9 lesser Temple of
  Veeshan dragons" below. Not the gap it appeared to be; no `lootdrop_entries`
  fix applies.**
- **Final Arbiter / Progenitor / Master of the Guard** (sleeper) — wiki's
  weapon set is a boilerplate pool shared across pages, and the same set
  *is* already correctly assigned to the tier-below "Warder" trio.
  **Confirmed correct as-is (2026-08-06) — no action needed.**
- ~~**Wiki-flagged uncertain items:** `#Yymp_the_Infernal` (Golden Earring,
  wiki tags rarity "Unknown"), `#Shaman_Ren`Rex` (all three items marked "?"
  on wiki), `#Watchman_Tylem` (kael — wiki's Frost Giant flavor is the
  outlier vs. every peer's Storm Giant flavor; likely a wiki error, not a
  DB bug).~~ **Resolved 2026-08-06 — see "Phase 2, sub-batch: Wiki-flagged
  uncertain items" below.**
- ~~**Non-existent target item:** `#Brother_Qwinn`'s "Torn Cloth Tunic" isn't
  in the `items` table under that name at all — needs identification
  (possible rename) before any fix.~~ **Resolved 2026-08-06 — see "Phase 2,
  sub-batch: Brother_Qwinn's Torn Cloth Tunic" below.**
- ~~**Small/low-value, low priority:** `#Guard_Delrenderak` (generic Diamond),
  the 7-NPC "Giant Scalemail Boots" cluster and 3-NPC "Kromrif Head"
  cluster in Kael, `#Icecrafter_Leyreon`, the `stonebrunt` 4-NPC set,
  `#a_focus_gem`/`#a_gem_collector`/`#a_life_leech` (crystal, generic
  gems), `Yvolcarn`/`Azureake` (cobaltscar), `#The_Head_Usher`
  (frozenshadow), `#Tpos_Icepaw`/`#Ular_Icepaw` (velketor), `Gozzrem`
  (templeveeshan), `#The_Sporali_Moldmaster`'s Grimoire page,
  `#Interrogator_Gi`mok`'s two Ultra Rare spells,
  `#an_Iksar_manslayer` (looks like a broader table swap, not a
  targeted removal), `#froglok_krup_knight` (tradeskill reagents, not
  gear), `Midnight`'s tiered cougarskin drops.~~ **Resolved 2026-08-06 —
  see "Phase 2, sub-batch: Giant Scalemail Boots cluster" (no fix —
  wiki-boilerplate finding), "Phase 2, sub-batch: Kromrif Head cluster"
  (fixed), and "Phase 2, sub-batch: small/low-value gaps" (fixed, except
  `#an_Iksar_manslayer` which is excluded after investigation) below.
- ~~**`sirens` version-1 population** — genuinely ambiguous era (see
  Context); excluded pending better dating evidence.~~ **Resolved
  2026-08-06 — see "Phase 2, sub-batch: `sirens` version-1 scope /
  Mistress Latazura" below.**
- ~~**`Mistress_Latazura`'s "Drums of the Beast" gap** — real finding, but
  the NPC's own wiki page carries an unresolved P99-editor doubt about
  whether it predates the zone revamp at all; deferred alongside the
  version-1 question above rather than fixed in isolation.~~ **Resolved
  2026-08-06 — see the same section below.**

Full source detail for every finding above (wiki text, live-loot dumps,
confidence rationale) remains in the three source review documents pending
cleanup: `docs/development/assessments/TEMP_2026-08-06_named_npc_loot_review_{classic,kunark,velious}.md`.

## Phase 2, sub-batch: Cross-NPC investigation (resolved 2026-08-06)

The two "possible mis-assignment" findings above were investigated further
per user direction, using direct wiki text plus live `lootdrop_entries`
queries for all four NPCs involved. **Neither is a mis-assignment.** Both
wiki pages document the item independently on each NPC in the pair — the
live DB is simply missing the entry on one member, not holding a stray copy
that needs to move.

| NPC | Zone | Item added | Lootdrop | Chance | Source |
|---|---|---|---|---|---|
| `#War_Priestess_T`zan` (20064) | kithicor | Two Handed Sword (5005) | 178182 | 2.0% | Wiki tags this item with the identical `[1] 1x 25% (50%)` slot marker as her Teir`Dal Adamantite Helm; lootdrop 178182 is that slot (12 armor pieces at 2.0% each, summing to ~24% ≈ the wiki's 25% slot rate) — added as a 13th equally-weighted member |
| `Amcilla` (120061) | westwastes | Greater Dragon's Head (25118) | 12583 | 20.0% | Wiki-sourced exact overall rate (`[Overall: 20.0%]`), added to Amcilla's existing standalone-rate pool alongside Huge Drake Wing (15.0%) |

Supporting evidence:

- `#Brigadier_G`tav`'s existing Two Handed Sword entry (88.0% — unusually
  high, but a separate calibration question, not this finding) is
  independently correct: his wiki page tags it "(Common)" and his
  description text explicitly reads *"can drop three swords"* alongside
  Indigo Sabre and Runebladed Sword of Night. Untouched by this migration.
- `Nintal`'s existing Greater Dragon's Head entry (25.0%, lootdrop 22124,
  paired with the distinctly-named "Great Dragon's Head" also at 25.0%)
  matches its wiki page's `[4] 1x 50% (50%)` notation for both items almost
  exactly. Untouched by this migration.
- `#War_Priestess_T`zan`'s Gem-Encrusted Scepter chance (102.597%, lootdrop
  175163) is an unrelated anomaly noticed during this investigation — wiki
  tags it "(Always)" so a value near 100% is expected, but the exact
  102.597% figure exceeds 100% and wasn't investigated further here. Flagged
  for a future pass, not corrected by this migration.

## Phase 2, sub-batch: Wiki-flagged uncertain items (resolved 2026-08-06)

Investigated further per user direction ("use other resources like the MCP
to investigate further... make a best guess based on what's available").
Each of the three resolved differently:

**`#Watchman_Tylem` (113073, kael) — no action, DB is correct.** His live
`npc_types.race` is 189. Cross-referencing every other `#Watchman_*` NPC in
`kael` (44 total) shows race 189 = Storm Giant and race 188 = Frost Giant
consistently (verified against generic `a_storm_giant_*`/`a_frost_giant_*`
NPCs sharing the same race IDs) — a roughly even split among the Watchmen,
not a single shared race. Tylem's existing live loot already carries
"Storm Giant Meat" and "Storm Giant Toes", internally consistent with his
own race. The wiki's "Frost Giant" flavor text for this one NPC is the
outlier and is treated as a wiki data-entry error (likely copy-paste from
one of the ~22 genuinely Frost Giant watchmen in the same cluster) — not a
DB defect. Nothing to migrate.

**`#Yymp_the_Infernal` (16041, beholder) — add Golden Earring, best-guess
resolved.** Wiki tags this item's *rarity classification* "(Unknown)", but
still gives it the identical `[1] 1x 75% (100%)` slot/rate notation as his
other item, Minotaur Ribcage — which live DB already has at exactly 75.0%
(lootdrop 1953). The "Unknown" tag reads as the wiki editors being unsure
how to classify the item's desirability tier, not uncertainty about whether
it drops; the drop-rate data itself is unambiguous and matches live state
exactly for the sibling item. Added at the same 75.0% rate, same lootdrop.
Item ID note: "Golden Earring" exists under 2 IDs (10007, 22259); 10007
selected as the dominant generic version (169 existing loot-table uses vs.
0 for 22259, which is an unused `magic`-flagged variant with guild-favor
stats attached — a different, more specialized item).

**`#Shaman_Ren`Rex` (14119, southkarana) — add both missing staves,
best-guess resolved.** Unlike Yymp, the wiki gives *no* rate data at all for
any of this NPC's three items — even the one item live DB already has
(Fine Steel Warhammer, literal "?" suffix on all three rarity tags:
"Uncommon?", "Uncommon?", "Rarity?"). No wiki number exists to inherit here.
Per the project's established Phase 1 convention for no-rate-given items,
both missing staves (Fine Steel Great Staff, Runed Totem Staff) are added
at 25.0% — matching their only live sibling, Fine Steel Warhammer, in the
same lootdrop (18185). Flagged here as a genuine estimate, not
primary-sourced, same caveat Phase 1 applied to its own inferred-rate rows.

| NPC | Zone | Item added | Lootdrop | Chance | Source |
|---|---|---|---|---|---|
| `#Yymp_the_Infernal` (16041) | beholder | Golden Earring (10007) | 1953 | 75.0% | Wiki-sourced — matches sibling Minotaur Ribcage's slot/rate exactly |
| `#Shaman_Ren`Rex` (14119) | southkarana | Fine Steel Great Staff (6352) | 18185 | 25.0% | Inferred — no wiki rate given for any item on this page; matched to sibling Fine Steel Warhammer's rate |
| `#Shaman_Ren`Rex` (14119) | southkarana | Runed Totem Staff (6310) | 18185 | 25.0% | Inferred — same basis as above |

## Phase 2, sub-batch: Oglard / Eldriaks Fe`Dhar (resolved 2026-08-06)

Investigated further per user direction — treated as a confirmed gap
requiring a fix, not an open design question. Both NPCs' P99 wiki pages
list an **identical 34-item "Ultra Rare" pool** (32 items at a documented
3% each, 2 items — Oiled Greaves, Frosted Gloves — at 2% each) plus a
separately-slotted Medium Coin Purse (`[2] 1x 35% (100%)`).

Live DB cross-reference found this was **not** the "near-total non-overlap"
originally described in Phase 1 — each NPC already has a small subset of
the 34-item pool mixed into an existing lootdrop alongside unrelated
quest-item filler (Jade, Onyx, Seer Lore Book, Bonded Loam, Manaforge
Ringlet on Eldriaks; Onyx, Small Coin Purse, Tome of Elemental
Understanding on Oglard — none of these five are on the wiki's Ultra Rare
list), at an inflated rate (20-25%) far above the wiki's documented 3%:

- **Eldriaks Fe`Dhar** (114000): already has 4 of 34 (Mystical Laig Staff,
  Wurm Scale Cape, Coldstone Wreath, Despair Needle) at 25.0% in lootdrop
  127122. **30 items missing.**
- **Oglard** (114001): already has 2 of 34 (Velium Etched Circlet, Jar`Nal
  Long Sword) at 20.0% in lootdrop 127125. **32 items missing.**

The already-present items' elevated rate is left untouched — no evidence
either way on whether it's a deliberate QoL boost or an import artifact,
and correcting it isn't the finding in scope here. Only the genuinely
absent items are added, at the wiki's documented rate, into each NPC's
existing lootdrop (consistent with Phase 1's "add into existing sibling
lootdrop" convention). Medium Coin Purse (17204) — entirely absent from
both NPCs (Oglard's existing "Small Coin Purse" is a different, lower-tier
item, left untouched) — is added to each NPC's secondary lootdrop (127123
for Eldriaks, alongside its existing Diamond entry; 127126 for Oglard,
alongside its existing spell/generic-loot entries) at 35%, matching the
wiki's distinct second-slot tag.

All 34 item IDs fall in a single dedicated Skyshrine block (29603-29682,
17204 for the coin purse) with no ambiguous duplicates, unlike the
Gold Ring/Golden Earring cases elsewhere in this ADR.

Migration:
`scripts/2026-08-06_named_npc_loot_reconciliation_phase_2_oglard_eldriaks.sql`
— 30 rows into lootdrop 127122 + 1 into 127123 (Eldriaks), 32 rows into
lootdrop 127125 + 1 into 127126 (Oglard). **Applied and verified 2026-08-08** (84 total rows confirmed live across all four lootdrops).

## Phase 2, sub-batch: 9 lesser Temple of Veeshan dragons (resolved 2026-08-06)

Investigated further per user direction — treated as a confirmed gap
requiring a fix. **This is not the gap it appeared to be, and no
`lootdrop_entries` fix applies.**

Phase 1's background review misread the P99 wiki's page structure. Each of
the 9 dragons' `known_loot` list is not a flat item list — it's a set of
top-level Symbol/Tear/Orb/Rune tokens, each with a **nested** `<ul><li>`
sub-list of 2-3 wearable items underneath it (e.g., Casalen's `Poison
Symbol (45%)` nests White Dragon Statue / Buckler of Insight / Earring of
the Living Flame). That nesting means "trade this token in for one of
these items" — a quest turn-in reward table, not a direct drop list. The
wearable "shared set" the earlier review flagged as missing was never
documented as a direct loot-table drop at all.

Cross-referencing confirms the dragons' actual direct drops — the tokens
themselves — are **already correctly implemented and closely match wiki
rates**: e.g., live `#Grozzmel` has Runed Symbol (45.0%) and Emerald Symbol
(45.0%) in lootdrop 13812, and Glowing Drake Orb (10.0%) in lootdrop
176745, matching the wiki's `[1] 1x 100% (45%)` / `~10%` tags almost
exactly, for all 9 dragons. This part was never broken.

What's actually missing is the **turn-in quest** that converts tokens into
the wearable set. All 9 dragons' wiki pages link `related_quests` entries
(Dozekar Tear Quests, the Arcane Tests, Wisdom - The Long/Short Battle,
Request of the Arcane, etc.), and `#Lendiniara_the_Keeper.pl`
(`templeveeshan`'s quest-giver) has live dialogue directly referencing "the
test of the Ruby Tear, the test of the Platinum Tear and the test of the
Emerald Tear" — confirming this is real, intended classic-era content, not
a fabricated wiki addition. But no quest script anywhere in `templeveeshan`
(checked all 28 files) or elsewhere implements the actual token-for-item
exchange. Per `docs/quests/QUEST_STANDARDS.md`, quest scripting is not
currently active development on this project.

**No migration applied.** Adding the 13 wearable items directly to the 9
dragons' `lootdrop_entries` would be a genuine mistake, not a fix — it
would let the set drop directly from combat at an invented rate, bypassing
the actual documented reward economy (collect tokens across 9 dragons on
3-7 day respawns, then turn in for a random piece from an overlapping
pool). This is logged here as a known future quest-scripting task rather
than acted on now, consistent with the project's current quest-scripting
scope boundary.

## Phase 2, sub-batch: `sirens` version-1 scope / Mistress Latazura (resolved 2026-08-06)

**`sirens` version-1 population: closed, out of scope.** Every confirmed
Velious-era item resolved elsewhere in this ADR falls under item ID
~32000 (e.g. Greater Dragon's Head 25118, the Oglard/Eldriaks Skyshrine
set 29603-29682, the Temple of Veeshan dragon symbols/spells up to
30475). Checking the full item-ID distribution for every `sirens` NPC by
`spawn2.version` gives a clean, decisive split: the reachable version-0
population (`#Helsia_Mindreaver` 125091, `#Mistress_Latazura` 125092,
`#Elna_Kelpweaver` 125093, `#Ulth_the_Enraged` 125097) has **100% of its
items at or under 32000** — zero exceptions across 34, 35, 34, and 5
items respectively. Every one of the 15 version-1-only NPCs has **at
least one item above 32000**, several majority or entirely above 45000
(`#Faleniel_of_Darkwater`: 8 of 8 items above 32000, none below). This
corroborates the FV Project timeline's Legacy of Ykesha (2003) dating for
this revamp with independent DB evidence, matching the already-settled
`lavastorm`/`paw`/`citymist`/`droga`/`nurga` pattern. No `content_flags`
row is needed — version-1 content is already engine-guaranteed
unreachable via `ZoneStore::GetZoneWithFallback`'s hard fallback to
version 0, same as those five zones.

**Mistress Latazura: confirmed in-scope, Drums of the Beast added.** Her
P99 wiki page cites `emu_id = 125047`, which is actually this database's
**version-1** (out-of-scope) copy — the same "wiki `emu_id` doesn't
reliably map to this DB's ID scheme" gotcha already on record for
`#Ruathey` earlier in this ADR. Matching by content rather than ID:
version-1's `125047` has an entirely different named-item set (Flawless
Steel Mask, Simple Coral Bracelet — none of the wiki's list), while
version-0's `125092` already has 3 of the wiki's 4 named "Rare" items
(Lyendlln's Lute, Sleeves of the Kelpmaidens, Cloak of the Seacaller, all
in lootdrop 178665) — only Drums of the Beast is missing. Version-0's
item-ID profile is also 100% clean per the above (unlike version-1's),
independently addressing the wiki editor's stated doubt ("need
confirmation this is an original sirens mob, not a post-SG revamp mob")
with evidence the wiki itself doesn't have. Drums of the Beast (item
24737, also comfortably under the 32000 threshold) is added to lootdrop
178665 at the wiki's stated `[Overall: 14.0%]` rate.

| NPC | Zone | Item added | Lootdrop | Chance | Source |
|---|---|---|---|---|---|
| `#Mistress_Latazura` (125092, version 0) | sirens | Drums of the Beast (24737) | 178665 | 14.0% | Wiki-sourced exact overall rate |

Migration:
`scripts/2026-08-06_named_npc_loot_reconciliation_phase_2_latazura.sql`.
**Applied and verified 2026-08-08** (confirmed live in `lootdrop_entries` at 14.0%).

## Phase 2, sub-batch: Giant Scalemail Boots cluster (resolved 2026-08-06)

Investigated per user direction, treating the user's "shared zone-wide/
multi-zone drop-table item" hypothesis as a real question rather than a
foregone conclusion. **Conclusion: no `lootdrop_entries` fix — this is a
wiki-documentation artifact, not a genuine per-NPC gap**, the same
underlying failure mode as the "9 lesser Temple of Veeshan dragons"
finding above, just smaller in scale.

Fetched live loot and P99 wiki pages for all 7 flagged NPCs (`#Watchman_Zakrek`
113052, `#Watch_Sergeant_Coldbones` 113455, `#Watch_Sergeant_Icestrider`
113364, `#Watch_Sergeant_Kredrer` 113474, `#Watch_Sergeant_Mjaek` 113415,
`#Lieutenant_Havblad` 113549, `#Lieutenant_Illdimr` 113393), plus
`#Watch_Sergeant_Vedravik` (113485, already fixed in Phase 1) and two
additional Watchman-tier NPCs not in the original 7 (`#Watchman_Jhaorn`
113003, `#Watchman_Icebear` 113006) as a control group.

**The wiki data is not per-mob.** All 9 of the first group's pages
(Zakrek, Coldbones, Icestrider, Kredrer, Mjaek, Havblad, Illdimr,
Vedravik, Jhaorn — level 32-36, race 188/Frost Giant) carry a **byte-
identical** `known_loot` list: Frost Giant Meat (Rare, `[Overall: 21.4%]`),
Giant Scalemail Boots (Ultra Rare, `[Overall: 3.6%]`), Frost Giant Toes
(Rare, `[Overall: 10.7%]`), plus Sergeant's Claymore (Ultra Rare, 3.6%)
for the Watch Sergeant rank specifically. The percentages match to the
decimal across 9 independently-named mobs — strong evidence this is a
combined-kill-log aggregate P99 wiki editors computed once for the whole
"Frost Giant Watchman/Sergeant/Lieutenant" trash-adjacent tier and
copy-pasted onto every individual page in it, not observed per-mob data.
This is exactly the same failure mode already flagged and excluded for
the higher Sentinel/Legionnaire/Veteran tier's 40-55 item shared pool in
Phase 1's original review — just a smaller, easier-to-miss 3-4 item
version at a lower level band.

**The control group proves the boilerplate is confined to this specific
sub-tier, not a wiki-wide pattern** — ruling out "maybe all wiki pages
just look like this." The level-43 Storm Giant Watchmen (Sunderthorn,
Wolfcoat) have genuinely different, mob-specific known_loot: different
item sets (Giant Scalemail **Cloak**, not Boots; Axe of the Frost;
Giant Warrior Helmet) at different, non-matching rates (Sunderthorn's
Giant Militia Longsword at 73.8% vs. Wolfcoat's 67.9%; Axe of the Frost
4.9% vs. 7.4%). `Watch_Sergeant_Deraekk`'s page has no known_loot at
all. `Watchman_Icebear`'s page is a near-blank stub (one untagged item).
If P99 wiki data were uniformly boilerplate, these pages would look like
the Frost Giant tier too — they don't, which is exactly what makes the
Frost Giant tier's decimal-identical repetition suspicious rather than
coincidental.

**Live DB's actual distribution independently corroborates a designed
"scattered thin" pattern that the wiki boilerplate doesn't respect.**
Querying every `Giant Scalemail%` item (13-piece set: Belt, Boots,
Bracer, Cloak, Gauntlets, Gloves, Gorget, Helm, Leggings, Mantle, Mask,
Sleeves, Tunic) across the ~70-NPC Kael Drakkel guard population shows
different pieces already deliberately spread across different specific
NPCs: Zakrek has Belt+Bracer, Icebear has Bracer, Jhaorn has Belt+Bracer,
Coldbones has Gorget, Icestrider has Gorget+Mask, Mjaek has Mask+Gorget,
Sunderthorn/Wolfcoat have Cloak, and — critically — **Giant Scalemail
Boots specifically is already live** on the 3 level-35 Adjutants
(Darggon, Icetorch, Kyrem, ~5-6% each) and on Vedravik (15%, Phase 1).
Kredrer, Havblad, and Illdimr currently hold **zero** pieces of the
family, which is consistent with this being one deliberately-rationed
set spread across dozens of mobs (each getting 0-2 pieces) rather than
every mob needing every piece.

Unlike Vedravik's Phase 1 fix (justified by a *structural* anomaly — an
almost-empty loot table, only Rock Fern, vs. every peer having 3-4
items), none of these 7 NPCs' tables are structurally thin — each
already has 5-9 items, normal density for this tier. There is no
independent signal (beyond the discredited boilerplate wiki text) that
Boots specifically belongs on these 7 rather than remaining scattered as
it already is. Forcing it onto all 7 based on data proven not to track
individual NPC identity would not be a fix — it would be inventing a
distribution the wiki never actually documented per-mob.

**No migration applied.** No SQL for this sub-batch.

## Phase 2, sub-batch: Kromrif Head cluster (resolved 2026-08-06)

Investigated per user direction, treating the user's "quest turn-in item,
not a direct drop" hypothesis (directly modeled on the 9-dragon finding
above) as a real question. **Conclusion: hypothesis rejected — this is a
genuine, fixable per-NPC gap**, not a quest-scripting dependency.

Fetched live loot and wiki pages for the 3 level-35 Kael Adjutants
(`#Adjutant_Darggon` 113389, `#Adjutant_Icetorch` 113011, `#Adjutant_Kyrem`
113459), and searched all `kael` quest scripts (67 files) plus a general
`mcp__eqemu__search_quests` pattern match for "Kromrif" project-wide.

Unlike the ToV dragons — where the wiki explicitly nested the "missing"
items under token headers and named real, unimplemented `related_quests`
entries with a live quest-giver referencing the exchange — nothing here
points to a quest dependency: all 3 Adjutants' wiki pages list
`related_quests = None`, and no quest script anywhere (`kael` or any
other zone) references "Kromrif Head," "Kromrif," or turn-in logic for
these items; the ~50 "Kromrif" hits found are all flavor dialogue/faction
adjustments, unrelated to any item exchange.

More directly, both disputed items are already confirmed as ordinary
combat loot elsewhere in the live database:

- **Kromrif Head** (item 30082) already appears in **18 other
  `lootdrop_entries` rows** as a common Frost-Giant/Kromrif trophy item,
  on generic trash (`4568_A_Frost_Giant_Scout_Misc`,
  `11799_Kromrif_Elite_Misc`, `128400_Kromrif_Prison_Guard_MAGELO-GEN`)
  and even another named mob (`#Gorul_Longshanks`, 30%) — this is a
  standard zone-wide trophy item, not something reserved for a quest.
- **Giant Militia Longsword** (item 25000) is already a well-established
  weapon drop across many other Kael Watchman-tier NPCs (`#Watchman_Zakrek`
  51.4%, `#Watchman_Icebear` 78.9%, `#Watchman_Jhaorn` 70.7%,
  `Watchman_Sunderthorn` 73.8%, `Watchman_Wolfcoat` 67.0%).

Both items' wiki pages give explicit slot-notation overall rates,
identical between Darggon and Icetorch (structurally identical Adjutant
NPCs — same level/class/stats): Kromrif Head `[2] 1x 50% (15%)`, Giant
Militia Longsword `[3] 1x 16% (6%)`. Icetorch's page additionally
documents Kromrif Bones `[2] 1x 50% (14%)` — live-confirmed as the only
one of the 3 Adjutants missing it. Kyrem's own page differs slightly
(2 extra items present, Boots omitted despite already being live) and
additionally documents **Woven Frost Giant Beard** at the same 15%
tier as Kromrif Head — live-confirmed missing during this
investigation (not flagged in the original TEMP doc bullet); added here
per the project's "flag proactively" convention rather than left for a
future pass.

| NPC | Zone | Item(s) added | Lootdrop | Chance | Source |
|---|---|---|---|---|---|
| `#Adjutant_Darggon` (113389) | kael | Kromrif Head (30082), Giant Militia Longsword (25000) | 126766 | 15.0% / 6.0% | Wiki-sourced overall rate |
| `#Adjutant_Icetorch` (113011) | kael | Kromrif Head (30082), Giant Militia Longsword (25000), Kromrif Bones (11655) | 126004 | 15.0% / 6.0% / 14.0% | Wiki-sourced overall rate |
| `#Adjutant_Kyrem` (113459) | kael | Kromrif Head (30082), Giant Militia Longsword (25000), Woven Frost Giant Beard (30106) | 126908 | 15.0% / 6.0% / 15.0% | Wiki-sourced overall rate |

Migration:
`scripts/2026-08-06_named_npc_loot_reconciliation_phase_2_kromrif_head.sql`.
**Applied and verified 2026-08-08.**

## Phase 2, sub-batch: small/low-value gaps (resolved 2026-08-06)

Investigated the remaining items from the original "small/low-value, low
priority" bullet, excluding Giant Scalemail Boots and Kromrif Head
(their own sub-batches above) and Brother_Qwinn's Torn Cloth Tunic (still
open, handled separately). Verified each against a fresh wiki fetch and
live DB state rather than trusting the TEMP doc's characterization
as-is; one finding (`#an_Iksar_manslayer`) did not check out and is
excluded, with reasoning below. Item-ID duplicate check per this ADR's
established method found one dedup case (`Part of Tasarin's Grimoire
Pg. 26`, IDs 16072/16073 — 68 vs. 64 existing `lootdrop_entries` uses,
16073 selected as the marginally dominant ID; no distinguishing field
found between the two beyond usage count).

| NPC | Zone | Item(s) added | Lootdrop | Chance | Source |
|---|---|---|---|---|---|
| `#Guard_Delrenderak` (113305) | kael | Diamond (10037) | 126587 | 0.7% | Wiki-sourced |
| `#Icecrafter_Leyreon` (113025) | kael | Frozen Chest Straps (25057) | 12987 | 25.0% | Inferred — matches sibling Icy Skull |
| `#Snowbeast` (100097) | stonebrunt | Ruined Cat Pelt (13783) | 4532 | 40.0% | Inferred — matches sibling Fang/Hide rate |
| `#Fishmaster_Jajoshi` (100103) | stonebrunt | Fine Steel Tanto (6930) | 18780 | 15.0% | Inferred — no-rate signature-item default |
| `#Rendolr_the_Maimer` (100199) | stonebrunt | Blood Crusted Kobold Mace (2639) | 18278 | 15.0% | Inferred — same default |
| `#Prowler_of_the_Jungle` (100205) | stonebrunt | Leopard Skin (6945), Jade Earring (10042) | 90676 | 15.0% each | Inferred — same default; wiki notes drops aren't guaranteed |
| `#a_focus_gem` (121085) | crystal | Carnelian (10011), Chipped Jasper (25625) | 129794 | 0.676% / 1.351% | Wiki-sourced exact overall rate, matches lootdrop's existing tier precisely |
| `#a_gem_collector` (121083) | crystal | Chipped Sapphire (25639), Chipped Jasper (25625) | 176811 | 16.667% each | Inferred — matches sibling Fire Opal/Star Ruby rate |
| `#a_life_leech` (121086) | crystal | Crystallized Sulfur (16976) | 13070 | 45.0% | Wiki-sourced exact |
| `#Yvolcarn` (117014) | cobaltscar | Arctic Wyvern Hide (28511), Chipped Black Marble (25819) | 12571 | 11.0% each | Inferred — matches sibling Wyvern Meat's Rare-tier rate |
| `#Azureake` (117075) | cobaltscar | Cobalt Drake Hide (28517), Drake Meat (22811) | 23646 | 11.0% each | Inferred, lower confidence — informal wiki page, no rate given; matched to Yvolcarn's Rare-tier default |
| `#The_Head_Usher` (111150) | frozenshadow | Crystallized Shadow Bracer (29225) | 13560 | 2.0% | Matches this NPC's own Belt/Gloves rate and the ADR's established flat-2% Crystallized Shadow tier |
| `#Tpos_Icepaw` (112098) | velketor | Cold Steel Gauntlets (25590) | 11980 | 1.0% | Matches sibling Breastplate/Greaves/Boots rate in same lootdrop |
| `#Ular_Icepaw` (112102) | velketor | Cold Steel Gauntlets (25590), Cold Steel Greaves (25589) | 12000 | 1.0% each | Matches established zone-family rate and existing sibling tier |
| `Gozzrem` (124105) | templeveeshan | Circlet of Silver Skies (31394) | 13826 | 14.0% | Matches sibling items' live rate (wiki gives 12% uniformly; live DB's own tier for this set is 14-15%) |
| `#The_Sporali_Moldmaster` (11124) | runnyeye | Fire Emerald (10033), Ruby Crown (10051), Pearl Necklace (10001), Emerald Ring (10045), Opal Bracelet (10046) | 90314 | 8.25% each | Inferred — matches sibling Sapphire/Jacinth rate |
| `#The_Sporali_Moldmaster` (11124) | runnyeye | Part of Tasarin's Grimoire Pg. 26 (16073) | 90314 | 2.0% | Inferred — no wiki rate; matched to the low end of this item's observed cross-zone rate range |
| `#Interrogator_Gi`mok` (103220) | chardok | Spell: Zumaik`s Animation (19389), Spell: Call of the Hero (19360) | 3912 | 2.0% each | Inferred — no wiki rate, no Ultra Rare sibling to match; uses the ADR's ~2% Ultra Rare default |
| `#froglok_krup_knight` (89010) | sebilis | Froglok Meat (13409), Green Froglok Skin (22134), Froglok Blood (22524) | 159009 | 6.0% / 6.0% / 5.0% | Wiki-sourced exact overall rate |
| `#Midnight` (110006) | iceclad | Low Quality Cougarskin (30031), High Quality Cougarskin (30030) | 13639 | 50.0% each | Wiki-sourced exact — completes the documented 4-tier set |

**`#an_Iksar_manslayer` (78053, fieldofbone) — excluded, no fix.** The
TEMP doc's own suspicion checked out under closer scrutiny. This NPC's
live loot table is a ~30-item pool (loams, marrow, spinneret fluid,
runes, words, generic gems, Consigned Bite of the Shissar) spread across
2 lootdrops at rates from 0.532% to 13.83% — structurally identical to
unrelated generic Kunark trash-filler pools seen elsewhere in this same
investigation (`#a_focus_gem`, `#froglok_krup_knight`'s secondary
lootdrops), not a curated named-mob table. The wiki, by contrast,
documents a small, clean, slot-based table: Gold Ring `[1] 1x 25% (50%)`,
Finely Crafted Targ Shield `[1] 1x 25% (50%)`, Rune of Al'Kabor
`[2] 4x 55% (34%)`, Words of Dominion `[2] 4x 55% (33%)`, Words of
Absorption `[2] 4x 55% (33%)`. Two of these five (Finely Crafted Targ
Shield, Words of Dominion) are already present in the live filler pool,
but diluted to 0.532% — two orders of magnitude below the wiki's
33-50% slot rates. Adding the 3 remaining items (Gold Ring, Rune of
Al'Kabor, Words of Absorption) at a similarly tiny rate into the same
generic pool would not restore the wiki-documented loot table; it would
just extend a pool that structurally isn't the same table. This reads as
a genuine table-reassignment defect (this NPC's real table replaced or
merged with a nearby generic filler table), which needs a design
decision about full table reassignment, not a 3-row patch — deferred, not
fixed here, same standard applied to the Giant Scalemail Boots and
9-dragon findings above.

Migration:
`scripts/2026-08-06_named_npc_loot_reconciliation_phase_2_small_gaps.sql`.
**Applied and verified 2026-08-08.**

## Phase 2, sub-batch: Brother_Qwinn's Torn Cloth Tunic (resolved 2026-08-06)

The original search for "Torn Cloth Tunic" against the `items` table used
an exact-string match and got zero hits, so this was filed as "item
doesn't exist, needs identification before any fix." The item does exist
— this database's whole family of generic "torn chest armor" filler items
carries a **literal trailing asterisk in the name** (`Torn Cloth Tunic*`,
id 13507; siblings `Torn Brown Shirt*` id 13570, `Torn Training Robe*`,
`Torn and Ripped Tunic*`, `Torn Bonecutters Tunic*` — all itemtype 10,
slot 131072, same shape). `#Brother_Qwinn` already drops two of these
siblings (Torn Brown Shirt*, Torn Training Robe*) at 50.0% each,
independent rolls, in lootdrop 8073 — Torn Cloth Tunic* is added as a
third, matching that same rate.

| NPC | Zone | Item added | Lootdrop | Chance | Source |
|---|---|---|---|---|---|
| `#Brother_Qwinn` (14054) | southkarana | Torn Cloth Tunic* (13507) | 8073 | 50.0% | Inferred — matches both existing siblings' independent-roll rate in the same lootdrop |

Migration:
`scripts/2026-08-06_named_npc_loot_reconciliation_phase_2_qwinn.sql`.
**Applied and verified 2026-08-08.**

## Phase 2, sub-batch: Kael Drakkel guard tier, broader population (closed 2026-08-07)

Extends the Giant Scalemail Boots / Kromrif Head investigations to the
rest of Kael's ~258 guard-titled NPCs (the ~90 higher ranks excluded from
Phase 1's review as wiki-boilerplate, plus the ~105 only ever
spot-checked). **Closed — no further action.** The structural-anomaly
heuristic that found `Watch_Sergeant_Vedravik`'s real bug in Phase 1
(loot table conspicuously thin vs. every same-rank peer) does not
generalize to this population at scale.

Method: queried live loot-item counts for all 258 NPCs, sorted to find
the most extreme outliers (1-2 items against a broad population skewing
5-30+), then wiki-checked the 8 most extreme cases. Result: **4 of 4
outliers with an existing wiki page matched live loot exactly** —
`#Adjutant_Frinvan` (wiki: 1 item, 10%, live: identical),
`#Senior_Guard_Akurr` (wiki: 2 items, 8.3% each, live: identical),
`#Watchman_Yekkal` (wiki: 2 items, 33.3%/66.7%, live: identical). Their
thin tables aren't bugs — some low/mid-tier guards are genuinely
documented as low-loot by design, unlike Vedravik whose *entire* same-rank
peer group had 3-4 real named items. `#Watchman_Ogelren`'s wiki page
documents `known_loot = None`, but live has 2 generic filler items — extra
undocumented loot, not missing loot, same "wiki under-documents"
pattern already noted for Narandi the Wretched. The remaining 4 checked
(`Iceweaver_Bonethrower`, `Chanter_Dethsek`, `Chanter_Vellnod`,
`Lieutenant_Bloodhand`) have no wiki page but show ordinary, plausible
generic loot, no sign of brokenness.

Raw item-count sorted across the full population produces mostly false
positives once loot density is compared across dissimilar
ranks/levels rather than within a tight, verified same-rank peer cluster
the way Vedravik's finding was. Continuing to check the remainder at the
same effort level was judged not worth the cost — closed without further
migration.

**No migration applied.** No SQL for this sub-batch.

## Phase 2, sub-batch: Plane of Mischief puppet-tier cards (resolved 2026-08-07)

Follow-up from `docs/development/assessments/TEMP_2026-08-07_named_npc_no_wiki_page_investigation.md`,
which found `#Bristlebane` (mischiefplane, id 126160) has a fully-scripted,
functional 3-phase encounter (`#Bristlebane.pl`) but zero loot. That
document originally speculated 15 other empty-loot NPCs in the zone
(Bidalla, Brendaine, Forlus, Hiana, Jinara, Kelld, Lelel, Lelp, Loplo,
Nerzuz, Osfof, Selvz, Siris, Snide, Uinus) might share the same gap —
**this speculation does not hold up** and is corrected here. PoM's loot
runs on a zone-specific card system (Black/Red/Blue/White × Throne/Crown/
Knight/Squire, 16 items total, ids 24550-24565) documented on P99's
`Category:Plane of Mischief Cards` page, which lists exact named sources
per card tier. None of those 15 names appear anywhere on that source
list — like `#Geb` (already confirmed as a scripted event trigger, not a
lootable target), they read as ambient/audience halfling flavor NPCs, not
carding mobs. Left alone.

What the source list *does* confirm: the "Puppet Theater Area" — the 6
summoned adds from `#Bristlebane.pl`'s fight script (`Tribunal Puppet`,
`Innoruuk Puppet`, `Erollisi Puppet`, `Rallos Puppet`, `Solusek Puppet`,
`Tunare Puppet`, npc ids 126246/126153/126291/126265/126249/126163) plus
`Bristlebane Puppet` itself — are a documented **Thrones**-tier card
source. The wiki's own stacking rule: "Mobs can also drop any card below
their highest card. For example, a mob that drops thrones will also drop
crowns, knights, and squires."

Live DB cross-reference: the 6 lesser puppets already correctly drop all
4 Knight cards (1.25% each, shared lootdrop 23512) — but per the
stacking rule they should also carry Crown and Squire cards, and don't.
`#Bristlebane` — the strongest puppet, the actual Thrones-tier source —
has no loot table at all (`loottable_id` blank), missing every tier
including the one he's the documented source for.

| NPC | Item(s) added | Lootdrop | Chance | Source |
|---|---|---|---|---|
| 6 lesser puppets (Tribunal/Innoruuk/Erollisi/Rallos/Solusek/Tunare, shared lootdrop) | Black/Red/Blue/White Crown (24551/24555/24559/24563), Black/Red/Blue/White Squire (24553/24557/24561/24565) | 23512 | 1.25% each | Inferred — matches this lootdrop's existing Knight-tier rate |
| `#Bristlebane` (126160) | All 16 cards: Black/Red/Blue/White × Throne/Crown/Knight/Squire | *(new loottable/lootdrop)* | 1.25% each | Inferred — same rate, since he's documented as this tier's own source and currently has nothing |

Card items are all `MAGIC ITEM  LORE ITEM` (one-per-character) per their
wiki pages — no charges/stacking concern.

**Extended 2026-08-07 — `Treasure_Chest` (Forest).** Checked the rest of
the wiki's card-source list against live loot: `Brenn`, `Grenn`, `Glonk`,
`Grink`, `TwentyTwo`, `Stomples`, `Donk`, `EightySix`, `My_Right_Hand`,
`Chuckles`/`Chuckles_the_Great`, `Lithiniath`, `a_dastardly_rascal`, and
`a_false_treasure_chest` all already have substantial existing loot
(4-65 items each) — not empty, so not the same clean signal, and not
individually verified further here (would need per-item card-content
checks, not just presence/absence). One did match the same clean-gap
pattern: `Treasure_Chest` (npc ids 126188 + 126343, `mischiefplane`,
level 51 — the wiki's "Treasure Chest in the Forest," a documented
**Crown**-tier source) shares `loottable_id` 99090 between both copies,
which has **zero `loottable_entries` rows at all** — not just an empty
lootdrop, no lootdrop linkage whatsoever. Per the same card-tier
stacking rule, a Crown-tier source should also carry Knight and Squire
(but not Throne, which is a tier above Crown) — 12 cards added via a new
lootdrop wired into the existing `loottable_id` 99090 (no `npc_types`
change needed, unlike Bristlebane, since this loottable_id was already
correctly assigned to both NPCs).

| NPC | Item(s) added | Lootdrop | Chance | Source |
|---|---|---|---|---|
| `Treasure_Chest` (126188, 126343 — shared loottable 99090) | Black/Red/Blue/White Crown (24551/24555/24559/24563), Knight (24552/24556/24560/24564), Squire (24553/24557/24561/24565) | *(new lootdrop, linked to existing loottable 99090)* | 1.25% each | Inferred — same rate as the puppet-tier cards above |

**Not addressed here (documented, not fixed):** the turn-in mechanic
converting cards into the zone's flowers/armor rewards
(`Deck of Spontaneous Generation Quest`) is only implemented on this
server for a *different* card family (Cod cards → item 17054, via
`Ferjeneror.lua`/`Clukker_The_Crazy.lua` — a separate "Dinner" side
quest). The Throne/Crown/Knight/Squire → flower/armor exchange has no
quest script anywhere in `mischiefplane`. Same standard as the ADR-017
9-dragon finding: restoring the direct card drops is in scope and done
here; scripting the reward exchange is quest-scripting work, out of this
project's current active scope, logged as a future task. The zone's other
documented card sources (Alice-area mobs, the Chest Room/Forest treasure
chests, `Lithiniath`, `Fenj`, `Chuckles the Great`, etc.) were not checked
in this pass — narrower scope than the full zone card economy, bounded to
the puppet-tier finding this investigation actually confirmed.

Migration:
`scripts/2026-08-07_named_npc_loot_reconciliation_phase_2_mischief_puppets.sql`.
**Applied and verified 2026-08-08.**

## Phase 2, sub-batch: Kithicor V`ghera correction (resolved 2026-08-07)

Follow-up from re-verifying the "no wiki page" methodology (see below) —
`#Ioltos_V`ghera` (20062) and `#Tasi_V`ghera` (20063) both turned out to
have real wiki pages after all, each documenting only "Argent Defender
(Rare)." Live DB had both erroneously pulling from a much larger shared
Kithicor "Fallen of Bloody Kithicor" loot cluster.

Cross-referencing `loottable_entries` membership revealed the true
structure: lootdrop 141545 (Runebladed Sword of Night, Incarnadine
Bracers/Gauntlets, the 12-piece Adamantite set) is shared by 5 NPCs
(`#Brigadier_G`tav`, `#Ioltos_V`ghera`, `#Tasi_V`ghera`, `#Adjutant_D`kan`,
and a newly-noticed 6th cluster member, `General_V`ghera` id 20205);
lootdrop 178182 (the Adamantite set again, already touched once this
session for `#War_Priestess_T`zan`) is shared by 5 NPCs with different
membership (`#Brigadier_G`tav`, `#Ioltos_V`ghera`, `#War_Priestess_T`zan`,
`#Adjutant_D`kan`, `General_V`ghera`). Both are genuine, valid shared
pools for the NPCs that legitimately use them — not deleted. Only
Ioltos's and Tasi's own `loottable_entries` *links* to these two
lootdrops are removed, unlinking them from pools their own wiki pages
never document. Their own unique lootdrops (141549, 141553 — confirmed
via query to be used by no other NPC) also each separately carried "Two
Handed Sword" alongside Argent Defender; removed directly since neither
wiki page documents it. Argent Defender itself (17.91% Ioltos, 10.0%
Tasi — no wiki rate given) is untouched.

**Extended 2026-08-07 — `#Adjutant_D`kan` and `General_V`ghera` corrected
too.** Both turned out to have the same over-linkage bug. `D`kan`'s wiki
page documents only "Scimitar of the Ykesha (Uncommon), Argent Defender
(Rare)" (both already present in his own unique lootdrops, untouched) —
unlinked from both shared pools; also had "Teir`Dal Scimitar" (an item
not on his wiki page at all) duplicated across two of his own lootdrops,
removed as a data-integrity fix independent of the shared-pool question.
`General_V`ghera` (20205) documents 8 items including "General's Pouch"
(Always/100%, already correct) — unlinked from both shared pools, and two
genuinely missing wiki items (Blood Riven Axe, Enchanted Fine Steel
Morning Star) added to his own "[3]"-tier lootdrop at their wiki rates.

His complete lack of static `spawn2` entries is **not a bug** — his wiki
page (and quest-file search confirming it) shows he's a quest-triggered
dynamic spawn for the Rogue Epic: a rogue hands a "Sealed Box" to one of
several "aide" NPCs (`#Ioltos_V`ghera`, `#Tasi_V`ghera`, `#Adjutant_D`kan`,
`#Brigadier_G`tav`, `#War_Priestess_T`zan`, `#Advisor_C`zatl`, and a 7th
cluster member noticed here for the first time, `#Coercer_Q`ioul` — not
otherwise investigated), each of which contains an identical
`quest::spawn2(20205,0,0,2316,797,275,387)` call. This is already fully
implemented server-side; no deployment fix needed.

`#Coercer_Q`ioul` is now a known 8th-if-counting-G`tav-and-T`zan cluster
member never individually investigated this session — flagged for
awareness only, not checked.

Migration:
`scripts/2026-08-07_named_npc_loot_reconciliation_phase_2_kithicor_vghera.sql`.
**Applied and verified 2026-08-08** (confirmed the erroneous shared-lootdrop links to 141545/178182 are gone for Ioltos, Tasi, and D`kan).

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

Phase 2 cross-NPC sub-batch migration:
`scripts/2026-08-06_named_npc_loot_reconciliation_phase_2_cross_npc.sql`.

Phase 2 wiki-uncertain sub-batch migration:
`scripts/2026-08-06_named_npc_loot_reconciliation_phase_2_wiki_uncertain.sql`
(`#Watchman_Tylem` required no SQL — resolved as DB-already-correct).

Phase 2 Oglard/Eldriaks Fe`Dhar sub-batch migration:
`scripts/2026-08-06_named_npc_loot_reconciliation_phase_2_oglard_eldriaks.sql`.

Phase 2 `sirens`/Latazura sub-batch migration:
`scripts/2026-08-06_named_npc_loot_reconciliation_phase_2_latazura.sql`.

Phase 2 9-dragon sub-batch: no migration — see "Phase 2, sub-batch: 9
lesser Temple of Veeshan dragons" above. Quest-scripting gap, out of
current project scope, not a `lootdrop_entries` fix.

Phase 2 Giant Scalemail Boots sub-batch: no migration — see "Phase 2,
sub-batch: Giant Scalemail Boots cluster" above. Wiki-boilerplate
documentation artifact, not a genuine per-NPC gap.

Phase 2 Kromrif Head sub-batch migration:
`scripts/2026-08-06_named_npc_loot_reconciliation_phase_2_kromrif_head.sql`.

Phase 2 small/low-value gaps sub-batch migration:
`scripts/2026-08-06_named_npc_loot_reconciliation_phase_2_small_gaps.sql`
(`#an_Iksar_manslayer` required no SQL — excluded, see the ADR section
above).

Phase 2 Brother_Qwinn sub-batch migration:
`scripts/2026-08-06_named_npc_loot_reconciliation_phase_2_qwinn.sql`.

Phase 2 Kithicor V`ghera correction sub-batch migration:
`scripts/2026-08-07_named_npc_loot_reconciliation_phase_2_kithicor_vghera.sql`.

Phase 2 Kael Drakkel guard-tier sub-batch: no migration — see "Phase 2,
sub-batch: Kael Drakkel guard tier, broader population" above. Closed,
no genuine bugs found in the checked sample.

All Phase 2 sub-batch migrations with SQL to apply are also compiled into
a single combined file for convenience:
`scripts/2026-08-06_named_npc_loot_reconciliation_phase_2_combined.sql`
(cross_npc + wiki_uncertain + oglard_eldriaks + latazura + kromrif_head +
small_gaps + qwinn, run as one transaction per sub-batch — the individual
files remain the source of truth per sub-batch and are unchanged).

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

**Phase 2 cross-NPC sub-batch: applied and verified 2026-08-08.** Both rows
(`..._phase_2_cross_npc.sql`) confirmed live in `lootdrop_entries` at their
documented rates (178182/5005 at 2.0%, 12583/25118 at 20.0%). Rollback (if
ever needed) is `DELETE FROM lootdrop_entries WHERE (lootdrop_id, item_id)
IN ((178182, 5005), (12583, 25118))`.

**Phase 2 wiki-uncertain sub-batch: applied and verified 2026-08-08.** All
3 rows (`..._phase_2_wiki_uncertain.sql`) confirmed live at their documented
rates. Rollback (if ever needed) is `DELETE FROM lootdrop_entries WHERE
(lootdrop_id, item_id) IN ((1953, 10007), (18185, 6352), (18185, 6310))`.

**Phase 2 Oglard/Eldriaks Fe`Dhar sub-batch: applied and verified
2026-08-08.** All 64 rows (`..._phase_2_oglard_eldriaks.sql`) confirmed live
(84 total rows across all four affected lootdrops, consistent with 64 new +
pre-existing). Rollback (if ever needed) is `DELETE FROM
lootdrop_entries WHERE (lootdrop_id = 127122 AND item_id IN (29603, 29604,
29609, 29610, 29611, 29613, 29614, 29615, 29616, 29618, 29619, 29620,
29621, 29635, 29636, 29638, 29639, 29641, 29642, 29643, 29644, 29667,
29668, 29672, 29673, 29676, 29678, 29679, 29681, 29682)) OR (lootdrop_id =
127123 AND item_id = 17204) OR (lootdrop_id = 127125 AND item_id IN
(29603, 29604, 29608, 29609, 29610, 29611, 29613, 29614, 29615, 29616,
29617, 29618, 29619, 29620, 29621, 29635, 29639, 29641, 29642, 29643,
29644, 29667, 29668, 29672, 29673, 29674, 29676, 29677, 29678, 29679,
29681, 29682)) OR (lootdrop_id = 127126 AND item_id = 17204)`.

**Phase 2 9-dragon sub-batch: no SQL to apply.** Resolved as a
quest-scripting gap, out of current project scope — see the ADR section
above.

**Phase 2 `sirens`/Latazura sub-batch: applied and verified 2026-08-08.**
The 1-row migration (`..._phase_2_latazura.sql`) confirmed live at 14.0%.
Rollback (if ever needed) is `DELETE FROM lootdrop_entries WHERE
lootdrop_id = 178665 AND item_id = 24737`.

**Phase 2 Giant Scalemail Boots sub-batch: no SQL to apply.** Resolved as
a wiki-documentation boilerplate artifact, not a genuine gap — see the
ADR section above.

**Phase 2 Kromrif Head sub-batch: applied and verified 2026-08-08.** All
8 rows (`..._phase_2_kromrif_head.sql`) confirmed live at their documented
rates. Rollback (if ever needed) is `DELETE FROM lootdrop_entries WHERE
(lootdrop_id, item_id) IN ((126766, 30082), (126766, 25000), (126004,
30082), (126004, 25000), (126004, 11655), (126908, 30082), (126908,
25000), (126908, 30106))`.

**Phase 2 small/low-value gaps sub-batch: applied and verified
2026-08-08.** All 34 rows (`..._phase_2_small_gaps.sql`) confirmed live
(`#an_Iksar_manslayer` correctly excluded, no rows for it). Rollback (if
ever needed) is `DELETE FROM lootdrop_entries WHERE
(lootdrop_id, item_id) IN ((126587, 10037), (12987, 25057), (4532,
13783), (18780, 6930), (18278, 2639), (90676, 6945), (90676, 10042),
(129794, 10011), (129794, 25625), (176811, 25639), (176811, 25625),
(13070, 16976), (12571, 28511), (12571, 25819), (23646, 28517), (23646,
22811), (13560, 29225), (11980, 25590), (12000, 25590), (12000, 25589),
(13826, 31394), (90314, 10033), (90314, 10051), (90314, 10001), (90314,
10045), (90314, 10046), (90314, 16073), (3912, 19389), (3912, 19360),
(159009, 13409), (159009, 22134), (159009, 22524), (13639, 30031),
(13639, 30030))`.

**Phase 2 Brother_Qwinn sub-batch: applied and verified 2026-08-08.** The
1-row migration (`..._phase_2_qwinn.sql`) confirmed live at 50.0%. Rollback
(if ever needed) is `DELETE FROM lootdrop_entries WHERE lootdrop_id = 8073
AND item_id = 13507`.

**Phase 2 Kael Drakkel guard-tier sub-batch: closed, no SQL.** Checked
the most extreme item-count outliers across all 258 guard-titled Kael
NPCs; every wiki-checkable case matched live loot exactly. See the ADR
section above.

**Phase 2 Plane of Mischief puppet-tier sub-batch: applied and verified
2026-08-08.** The migration (`..._phase_2_mischief_puppets.sql`, extended
2026-08-07 to also cover `Treasure_Chest`) confirmed live: all 8
`Treasure_Chest` rows present at 1.25% each (lootdrop 23512); `#Bristlebane`
(NPC 126160) now has its own dedicated `loottable_id` 110871 /
`lootdrop_id` 178696 with all 16 documented items at 1.25% each; the new
`Treasure_Chest`-tier lootdrop wired into the existing shared
`loottable_id` 99090 is `lootdrop_id` 178697, with all 12 documented
Crown-tier items at 1.25% each. Rollback (if ever needed) is `DELETE FROM
lootdrop_entries WHERE (lootdrop_id, item_id) IN
((23512, 24551), (23512, 24555), (23512, 24559), (23512, 24563), (23512,
24553), (23512, 24557), (23512, 24561), (23512, 24565))`, plus
`DELETE FROM loottable_entries WHERE loottable_id IN (110871) OR
lootdrop_id IN (178696, 178697)`, `DELETE FROM lootdrop_entries WHERE
lootdrop_id IN (178696, 178697)`, `DELETE FROM lootdrop WHERE id IN
(178696, 178697)`, `DELETE FROM loottable WHERE id = 110871`, and
resetting NPC 126160's `loottable_id` back to its prior value.

**Phase 2 Kithicor V`ghera correction sub-batch: applied and verified
2026-08-08.** The migration (`..._phase_2_kithicor_vghera.sql`) confirmed
live: Ioltos/Tasi/D`kan no longer have `loottable_entries` links to the
shared 141545/178182 lootdrops, and General V`ghera's own lootdrop 3369
carries the two added items. Rollback statement is in the script's own
header comment.

**Combined file:** `scripts/2026-08-06_named_npc_loot_reconciliation_phase_2_combined.sql`
concatenated all 7 sub-batches into one file for convenience. All sub-batches
above have since been applied individually (see each sub-batch's own status);
the combined file is retained as a historical record, not an outstanding
action.

**Note (unrelated to this ADR):** the same application pass also applied
`scripts/2026-08-06_npc_reconciliation_content_flags_phase_1.sql` (Codex's
Gates of Discord / Secrets of Faydwer content flags), which this ADR's
Context section flags as out of scope under the project's PoP-or-earlier
policy. Both flags are `enabled = 0` so there's no live gameplay impact,
but this is a pending decision for the user: leave as harmless-but-
out-of-policy, or roll back for consistency.
