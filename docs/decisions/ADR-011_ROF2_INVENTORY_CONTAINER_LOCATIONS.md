# ADR-011: RoF2 Inventory Container Location Format

**Status:** Accepted — personal inventory implemented; bank mapping pending live confirmation

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

No future SQL may insert **bank bag-child rows** until this server's live bank mapping has been measured with the same method. The existing legacy rows (`2031...`, `2231...`, etc.) are not evidence that those are correct for the active server.

The EQEmu inventory reference documents server-recognized modern bank ranges beginning at `6210` for bank slot 2000, but the personal mapping above was established from this server's actual persistence behavior. A Testchar bank-container test must therefore confirm the deployed mapping before a bank migration or repair is written. Until then, a migration may insert parent bank bags (`2000...`) but must leave their child contents out.

## Consequences

- The original Angel migration must be amended before it is ever rerun; its legacy child inserts recreate the corruption.
- Personal bag migration SQL must validate that destination rows are empty and that every target parent is a valid container before changing data.
- Any inventory-related disconnect is triaged first by comparing the affected character's persisted slot locations with a server-created control character, rather than assuming the item itself is invalid.
- Bank contents remain a separate, deliberately bounded follow-up to avoid moving stored player items on an inferred mapping.

## Related Decisions

- ADR-008 establishes RoF2 as the target client.
- ADR-006 records the project's starting-kit and bag policy; this ADR governs only database persistence locations for container children.
