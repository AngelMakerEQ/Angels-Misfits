# ADR-016: Item Drop Era Gating (Classic/Kunark Legacy Drops)

**Status:** Accepted — Implemented
**Date:** 2026-08-06

---

## Context

Prompted by the observation that PEQ is a "live-like, all-era" database
rather than a classic-focused one (unlike P99 or TAKP), itemization was
checked for era drift. Spot-checking famous, heavily-scrutinized items
(`docs/gameplay/ITEMIZATION.md`) found no drift — the same pattern already
seen with NPC spot-checks (ADR-003) — so a structured changelog
cross-reference was used instead: FV Project's Content Flags page
(`https://fvproject.com/index.php/Content_Flags`), which documents specific
items that dropped in Classic/Kunark/Velious but were later changed,
replaced, or removed, each tied to a specific patch event or era.

Every item FVP lists under its Classic_OldWorldDrops and
Kunark_LegacyItemDrops sections was checked against the live database via
reverse loot-table lookup (`items` → `lootdrop_entries` → `loottable_entries`
→ `npc_types`), following the methodology established for the NPC/spell
audits (ADR-003, ADR-004). Two false-positive patterns were caught during
verification and are recorded here so the same mistake isn't repeated:

1. **"Replacement ID doesn't exist" is not evidence of a defect.** Four
   items (Axe of the Slayers 5365, Glowing Black Stone 10404, Cloak of
   Imperception 5729, Robe of Living Fungus 1268) were initially flagged
   because FVP's documented replacement item ID isn't present in this
   database — but in all four cases a prior maintainer had already applied
   the fix **in place on the original ID** instead of creating a new one.
   Caught by direct field inspection (`proclevel2`, `slots`, `maxcharges`,
   absence of regen fields respectively) before being included in scope.
2. **A live `lootdrop_entries` row is not evidence of a live drop.** Scale
   Hide Whip (10907) and 3 of Goblin Eye Poker's 4 loot rows appeared to be
   active sources on first query, but none of their `loottable_id` values
   are referenced by any `npc_types` row — they're orphaned loot tables,
   unreachable by any spawned NPC, and therefore already functionally
   equivalent to "removed" without needing a fix.

Two items (Cloak of Shadows 2408, Gem Encrusted Ring 11541) remain live
drops with no FVP-cited date or replacement — excluded from this pass for
insufficient evidence rather than acted on speculatively.

## Decision

Gate the confirmed still-live legacy drops using EQEmu's `content_flags`
mechanism rather than deleting the loot-table rows, per the CLAUDE.md
policy adopted alongside this investigation ("Era-inappropriate content
should be gated, not deleted"), consistent with ADR-001's precedent of
retaining the full PEQ dataset.

## Mechanism / Implementation

Confirmed against EQEmu source
(`common/content/world_content_service.cpp`,
`WorldContentService::DoesPassContentFiltering`): a `lootdrop_entries` row
with a non-null `content_flags` value only remains droppable while every
named flag has `content_flags.enabled = 1`. Two new flags are inserted at
`enabled = 0`, immediately disabling the affected drops while leaving a
single-row toggle (`UPDATE content_flags SET enabled = 1 ...`) to restore
them later without touching `lootdrop_entries` again.

Migration: `scripts/2026-08-06_itemization_content_flags_gating.sql`.

**`Classic_OldWorldDrops`** (30 `lootdrop_entries` rows):

| Item(s) | Live source(s) | Documented event |
|---|---|---|
| Rubicite armor set — 12 pieces (Helm/Mask/Collar/Breastplate/Pauldron/Cloak/Waistband/Vambraces/Bracers/Gauntlets/Greaves/Boots, ids 4161-4172) | a_lifestealer_mosquito ×6 NPCs (48000/48003/48065/48068/48112/48230) | Removed/disabled Oct 13, 1999 |
| Cryosilk armor set — 12 pieces (Cap/Veil/Choker/Robe/Amice/Cloak/Sash/Sleeves/Bracelet/Gloves/Pantaloons/Lined Shoes, ids 1211-1222) | a_spinechiller_spider ×5 (all pieces); Robe also 5 named raid NPCs at 100%; Sleeves also phoboplasm variants; Pantaloons also a_haunted_chest variants | "Fear Era" legacy set (FVP cites no exact date) |
| Boots of Brawn (12181) | Sir Lucan D`Lere (9018) | Dropped until Kunark released |
| Journeyman's Boots (2300) | #The_Fabled_Drelzna (44105) — zone confirmed live as `najena` via `spawn2`/`spawnentry`, matching FVP's note | Changed from Najena drop to Hasten Bootstrutter quest, Oct 13, 1999 |

**`Kunark_LegacyItemDrops`** (2 `lootdrop_entries` rows):

| Item | Live source | Documented event |
|---|---|---|
| Sarnak Liberator (11924) | a_Sarnak_flunkie ×3 NPCs (85001/85010/85025) | Removed shortly after Kunark, by Velious at latest |
| Goblin Eye Poker (10597) | #Scout_Charisa (120000) — only live/reachable row; 3 other rows for this item are orphaned, already unreachable | Removed — was an All/All weapon (design reason) |

## Scope decisions

- **In scope:** the 6 items/sets above — every case where FVP cites a
  specific removal/replacement event *and* the live database still has a
  reachable drop source contradicting it.
- **Excluded — no action needed (already correct):** the large majority of
  FVP's Classic_OldWorldDrops and Kunark_LegacyItemDrops lists. See
  `PEQ_CHANGES.md` for the full accounting; most have no drop source at
  all, and four (listed above) were already fixed in place on their
  original item ID.
- **Excluded — insufficient evidence:** Cloak of Shadows (2408), Gem
  Encrusted Ring (11541) — still live, but FVP cites no date or mechanism
  for either. Not acted on without a firmer source; candidates for a
  future pass if a P99 wiki page or other primary source confirms them.
- **Excluded — different category:** Emerald Armor Breastplate and Sash of
  Infinite Blows (FVP itself says these need to be created, not gated —
  absent from every source including PEQ); the ~30-entry
  `Classic_AlchemyPreRevamp` recipe list (not yet checked against the live
  DB at all).
- **Not yet checked, flagged for follow-up:** Kunark_HoleEra's raid-mob
  spawn gating (Talendor 91093, Faydedar 96089, Severilous 94009) and the
  Rallia Hapera / Hole Key (6379) merchant-flag item.

## Consequences

- The 6 gated items/sets stop dropping immediately once the migration is
  applied and the flags are confirmed `enabled = 0` — a real, visible
  change for anyone currently able to obtain them.
- Nothing is deleted. Both flags can be flipped back to `enabled = 1`
  individually if a future decision reverses this call, without needing to
  re-derive which `lootdrop_entries` rows were touched.
- This establishes `content_flags` (rather than row deletion) as the
  standard mechanism for future era-inappropriate content findings, per
  the CLAUDE.md policy this investigation prompted.

## Spire Compatibility

No schema changes — `content_flags` and `lootdrop_entries.content_flags`
are existing PEQ columns Spire already supports. DML only.

## Implementation Status

**Implemented and verified 2026-08-06.** Applied manually (MCP connection is
read-only) and confirmed live via direct post-run query:

- `Classic_OldWorldDrops`: 30 `lootdrop_entries` rows tagged, flag present
  at `enabled = 0`.
- `Kunark_LegacyItemDrops`: 2 rows tagged from this migration (Sarnak
  Liberator, Goblin Eye Poker) — a 3rd row was added later by ADR-017's
  Eye of RokGus gate, reusing this same flag.
- Exclusion check confirmed no unrelated items sharing `lootdrop_id` 151067
  or 376/369/371/374 were touched.
