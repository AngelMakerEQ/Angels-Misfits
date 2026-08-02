# ADR-011: RoF2 Inventory Container Location Format

**Status:** Accepted — live personal and bank mappings confirmed; replacement migration available

**Date:** 2026-08-01

---

## Context

`angel_full_migration_compiled.sql` inserted the contents of Angel's general-inventory bags using the legacy location ranges `251...` and `1451...`. The rows remained present in the `inventory` table after login, but Angel's bag contents were not recognized by the running server. Looting a normal item then removed it from the NPC corpse, recorded a loot event, froze the client inventory UI, and disconnected the client before the item persisted to Angel's inventory.

The affected items were ordinary, unrelated items (`Rusty Long Sword` and `Onyx`), eliminating a malformed item record or loot-table entry as the common cause. Item GUIDs were also present and unique.

## Verification

A new level-one Iksar Shaman (`Testchar`) was used as a clean control:

1. A standard Backpack (item `17005`) was created through `#summonitem`.
2. Several NPCs were killed and looted.
3. Items were moved from main inventory into the Backpack.
4. No freeze, disconnect, or item loss occurred.
5. After the bag was emptied and one item was placed in its first visible cell, the server stored that child as `inventory.slot_id = 5210`. The Backpack was in general slot `29`.
6. A Backpack was placed in Testchar's first bank slot (`2000`) and one item was placed in its first visible cell. The server stored that child as `inventory.slot_id = 6210`.

This proves that this server's active RoF2 personal-container persistence format is not the legacy `251 + (parent offset * 200)` format used by the original migration.

## Decision

All future SQL which inserts an item inside a **personal general-inventory bag** must use the live-format child locations below. It must not use legacy personal bag locations such as `251`, `451`, `1451`, or `1651`.

The general-bag child formula is:

```text
child_slot_id = 5000 + ((parent_general_slot - 23) * 35) + child_index
```

Where:

- `parent_general_slot` is the parent bag's main inventory slot, `23` through `30`.
- `child_index` is zero-based and must be less than the parent item's `bagslots` value.
- An inserted child must have a container item in its corresponding parent slot. Do not attach child rows to a non-container item.

### Required personal-bag child ranges

| Parent general slot | First child row | Allowed child rows |
|---:|---:|---:|
| 23 | 5000 | 5000–5034 |
| 24 | 5035 | 5035–5069 |
| 25 | 5070 | 5070–5104 |
| 26 | 5105 | 5105–5139 |
| 27 | 5140 | 5140–5174 |
| 28 | 5175 | 5175–5209 |
| 29 | 5210 | 5210–5244 |
| 30 | 5245 | 5245–5279 |

The range is the storage address range. A specific bag can use only the first `bagslots` rows of its range. For example, an 8-slot Backpack in general slot 29 uses `5210` through `5217`; it must not receive a child in `5218` or later.

### Angel migration correction

The intended original layout maps as follows:

- legacy `251–258` (general slot 23) → `5000–5007`;
- legacy `1451–1458` (general slot 29) → `5210–5217`, preserving intentional empty cells.

Angel's current in-game arrangement had subsequently moved the Blood of the Wolf to slot 29 and a Shralok Pack to slot 26. Therefore the one-time repair script places the latter set in the actual current parent container at slot 26 (`5105...`), preserving all items without overwriting the user's in-game changes. See `scripts/2026-08-01_angel_personal_bag_slot_repair.sql`.

## Bank Containers

All future SQL which inserts an item inside a **bank bag** must use the live-format child locations below. It must not use legacy bank bag locations such as `2031`, `2231`, or `3431`.

The bank-bag child formula is:

```text
child_slot_id = 6210 + ((parent_bank_slot - 2000) * 200) + child_index
```

Where `parent_bank_slot` is `2000` through `2023`, and `child_index` is zero-based and less than the parent item's `bagslots` value. The 200-row stride is an address reservation; it does not permit placing an item beyond the actual size of the bag.

### Required bank-bag child ranges used by Angel's migration

| Parent bank slot | First child row | Address range |
|---:|---:|---:|
| 2000 | 6210 | 6210–6409 |
| 2001 | 6410 | 6410–6609 |
| 2002 | 6610 | 6610–6809 |
| 2003 | 6810 | 6810–7009 |
| 2004 | 7010 | 7010–7209 |
| 2005 | 7210 | 7210–7409 |
| 2006 | 7410 | 7410–7609 |
| 2007 | 7610 | 7610–7809 |

The complete corrected inventory replacement is `scripts/angel_inventory_rof2_locations.sql`.

## Consequences

- The original Angel migration must be amended before it is ever rerun; its legacy child inserts recreate the corruption.
- Personal bag migration SQL must validate that destination rows are empty and that every target parent is a valid container before changing data.
- Any inventory-related disconnect is triaged first by comparing the affected character's persisted slot locations with a server-created control character, rather than assuming the item itself is invalid.
- The complete replacement migration can now restore Angel's listed bank contents using verified live-format rows.

## Related Decisions

- ADR-008 establishes RoF2 as the target client.
- ADR-006 records the project's starting-kit and bag policy; this ADR governs only database persistence locations for container children.
