-- Angel personal-bag location repair (MariaDB)
--
-- Root cause:
-- The full migration inserted container children using the legacy locations
-- (251... and 1451...).  This server persists RoF2 personal-container
-- children in the live-format range beginning at 5000, with 35 locations per
-- general slot.  A server-created Testchar Backpack in general slot 29 placed
-- its first child at 5210, confirming the mapping.
--
-- Scope:
-- * Character 1 (Angel) only.
-- * Repairs PERSONAL bag children only.  Bank locations are intentionally not
--   changed by this file; they require a separate bank-specific confirmation.
-- * Preserves Angel's currently saved main-inventory arrangement: the food and
--   drink formerly at legacy 1451...1458 are placed in the Shralok Pack at
--   general slot 26 (live range 5105...).
--
-- Preconditions:
-- 1. Angel is fully logged out.
-- 2. Take a database backup/snapshot.
-- 3. Do not run angel_full_migration_compiled.sql again afterwards; it will
--    recreate the obsolete legacy rows until that migration is corrected.

START TRANSACTION;

-- Safety checks. Both values must be 0 before the UPDATE is executed.
SELECT COUNT(*) AS unexpected_live_destination_rows
FROM inventory
WHERE character_id = 1
  AND slot_id IN (5000,5001,5002,5003,5004,5005,5006,5007,
                  5105,5106,5107,5108,5111,5112);

SELECT COUNT(*) AS required_legacy_source_rows
FROM inventory
WHERE character_id = 1
  AND slot_id IN (251,252,253,254,255,256,257,258,
                  1451,1452,1453,1454,1457,1458);
-- Expected value: 14.  If it is not 14, ROLLBACK rather than continue.

-- 251...258 were contents of Angel's bag in general slot 23.
-- Live slot 23 base = 5000.
-- 1451...1458 were intended for a Shralok Pack.  Angel's current saved
-- Shralok Pack is in general slot 26; live slot 26 base = 5105.
UPDATE inventory
SET slot_id = CASE slot_id
    WHEN 251  THEN 5000
    WHEN 252  THEN 5001
    WHEN 253  THEN 5002
    WHEN 254  THEN 5003
    WHEN 255  THEN 5004
    WHEN 256  THEN 5005
    WHEN 257  THEN 5006
    WHEN 258  THEN 5007
    WHEN 1451 THEN 5105
    WHEN 1452 THEN 5106
    WHEN 1453 THEN 5107
    WHEN 1454 THEN 5108
    WHEN 1457 THEN 5111
    WHEN 1458 THEN 5112
END
WHERE character_id = 1
  AND slot_id IN (251,252,253,254,255,256,257,258,
                  1451,1452,1453,1454,1457,1458)
  AND (SELECT COUNT(*)
       FROM inventory AS source_rows
       WHERE source_rows.character_id = 1
         AND source_rows.slot_id IN (251,252,253,254,255,256,257,258,
                                     1451,1452,1453,1454,1457,1458)) = 14
  AND (SELECT COUNT(*)
       FROM inventory AS destination_rows
       WHERE destination_rows.character_id = 1
         AND destination_rows.slot_id IN (5000,5001,5002,5003,5004,5005,5006,5007,
                                          5105,5106,5107,5108,5111,5112)) = 0;

SELECT slot_id, item_id, charges
FROM inventory
WHERE character_id = 1
  AND slot_id IN (5000,5001,5002,5003,5004,5005,5006,5007,
                  5105,5106,5107,5108,5111,5112)
ORDER BY slot_id;

COMMIT;
