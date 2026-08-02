-- Angel inventory and bank replacement migration (MariaDB)
--
-- Replaces Section 5 (GENERAL INVENTORY & BANK) of
-- scripts/angel_full_migration_compiled.sql.
--
-- Confirmed live child-location rules:
--   General bags: base 5000 + ((parent slot - 23) * 35)
--   Bank bags:    base 6210 + ((parent bank slot - 2000) * 200)
--
-- Tested against server-created containers:
--   General slot 29, first child -> 5210
--   Bank slot 2000, first child -> 6210
--
-- Run only while Angel (character_id 1) is fully logged out.
-- This intentionally resets Angel's listed general and bank inventory to the
-- contents from the full migration. Back up the database first.

START TRANSACTION;

-- Remove parent rows, obsolete legacy child locations, and current live-format
-- child locations owned by Angel's eight general and eight bank bag slots.
DELETE FROM inventory WHERE character_id = 1 AND slot_id BETWEEN 23 AND 30;
DELETE FROM inventory WHERE character_id = 1 AND slot_id BETWEEN 251 AND 1658;
DELETE FROM inventory WHERE character_id = 1 AND slot_id BETWEEN 5000 AND 5279;
DELETE FROM inventory WHERE character_id = 1 AND slot_id BETWEEN 2000 AND 2007;
DELETE FROM inventory WHERE character_id = 1 AND slot_id BETWEEN 2031 AND 3438;
DELETE FROM inventory WHERE character_id = 1 AND slot_id BETWEEN 6210 AND 7809;

-- General inventory parent items (slots 23-30)
INSERT INTO inventory (character_id, slot_id, item_id, charges, color) VALUES
(1, 23, 17354, 0,  0), -- General Slot 1: Bag of Sewn Evil-Eye
(1, 24, 17353, 0,  0), -- General Slot 2: Light Burlap Sack (empty)
(1, 25, 17350, 0,  0), -- General Slot 3: Lionhide Backpack (empty)
(1, 26, 14534, 10, 0), -- General Slot 4: 10 Dose Blood of the Wolf
(1, 27, 17401, 0,  0), -- General Slot 5: Shralok Pack (empty)
(1, 28, 17401, 0,  0), -- General Slot 6: Shralok Pack (empty)
(1, 29, 17401, 0,  0), -- General Slot 7: Shralok Pack
(1, 30, 30221, 0,  0); -- General Slot 8: Kromzek Surveyor Scope

-- General Slot 1 contents: Bag of Sewn Evil-Eye (base 5000)
INSERT INTO inventory (character_id, slot_id, item_id, charges, color) VALUES
(1, 5000, 9010, 0, 0), (1, 5001, 7003, 0, 0), (1, 5002, 9010, 0, 0), (1, 5003, 7003, 0, 0),
(1, 5004, 9010, 0, 0), (1, 5005, 7003, 0, 0), (1, 5006, 9010, 0, 0), (1, 5007, 7003, 0, 0);

-- General Slot 7 contents: Shralok Pack (base 5210). Empty indexes 4 and 5
-- are intentionally retained from the original migration layout.
INSERT INTO inventory (character_id, slot_id, item_id, charges, color) VALUES
(1, 5210, 13073, 17, 0), (1, 5211, 13073, 20, 0), (1, 5212, 13073, 20, 0), (1, 5213, 13073, 20, 0),
(1, 5216, 13006, 20, 0), (1, 5217, 13005, 19, 0);

-- Bank parent containers (slots 2000-2007)
INSERT INTO inventory (character_id, slot_id, item_id, charges, color) VALUES
(1, 2000, 17081, 0, 0), -- Bank Bag 1: Dusty Ransacker's Pack
(1, 2001, 17901, 0, 0), -- Bank Bag 2: Medicine Bag
(1, 2002, 17005, 0, 0), -- Bank Bag 3: Backpack
(1, 2003, 17005, 0, 0), -- Bank Bag 4: Backpack
(1, 2004, 17901, 0, 0), -- Bank Bag 5: Medicine Bag
(1, 2005, 17969, 0, 0), -- Bank Bag 6: Hand Made Backpack
(1, 2006, 17901, 0, 0), -- Bank Bag 7: Medicine Bag
(1, 2007, 17901, 0, 0); -- Bank Bag 8: Medicine Bag

-- Bank Bag 1 contents (bank slot 2000; base 6210)
INSERT INTO inventory (character_id, slot_id, item_id, charges, color) VALUES
(1, 6210, 11848, 1, 0), (1, 6211, 11843, 1, 0), (1, 6212, 11836, 1, 0),
(1, 6213, 11799, 1, 0), (1, 6214, 11847, 1, 0);

-- Bank Bag 2 contents (bank slot 2001; base 6410)
INSERT INTO inventory (character_id, slot_id, item_id, charges, color) VALUES
(1, 6410, 3082, 0, 0), (1, 6411, 3084, 0, 0), (1, 6412, 3085, 0, 0), (1, 6413, 3079, 0, 0),
(1, 6414, 3085, 0, 0), (1, 6415, 3087, 0, 0), (1, 6416, 3077, 0, 0);

-- Bank Bag 3 contents (bank slot 2002; base 6610)
INSERT INTO inventory (character_id, slot_id, item_id, charges, color) VALUES
(1, 6610, 16039, 2, 0), (1, 6611, 11834, 3, 0), (1, 6612, 11861, 4, 0), (1, 6613, 11826, 6, 0),
(1, 6614, 11825, 2, 0), (1, 6615, 11861, 1, 0), (1, 6616, 11835, 1, 0), (1, 6617, 11817, 4, 0);

-- Bank Bag 4 contents (bank slot 2003; base 6810)
INSERT INTO inventory (character_id, slot_id, item_id, charges, color) VALUES
(1, 6810, 11825, 1, 0), (1, 6811, 11862, 1, 0), (1, 6812, 11857, 1, 0), (1, 6813, 11827, 2, 0),
(1, 6814, 11821, 1, 0), (1, 6815, 11837, 1, 0), (1, 6816, 11812, 3, 0), (1, 6817, 11810, 3, 0);

-- Bank Bag 5 contents (bank slot 2004; base 7010). Index 3 is intentionally empty.
INSERT INTO inventory (character_id, slot_id, item_id, charges, color) VALUES
(1, 7010, 12862, 0, 0), (1, 7011, 16542, 1, 0), (1, 7012, 16540, 0, 0),
(1, 7014, 19297, 1, 0), (1, 7015, 15644, 1, 0), (1, 7016, 29207, 0, 0), (1, 7017, 14745, 0, 0);

-- Bank Bag 6 contents (bank slot 2005; base 7210). Index 0 is intentionally empty.
INSERT INTO inventory (character_id, slot_id, item_id, charges, color) VALUES
(1, 7211, 13073, 20, 0), (1, 7212, 13073, 20, 0), (1, 7213, 13073, 20, 0), (1, 7214, 13073, 20, 0),
(1, 7215, 13073, 20, 0), (1, 7216, 13073, 20, 0), (1, 7217, 13073, 20, 0), (1, 7218, 13073, 20, 0),
(1, 7219, 13073, 20, 0);

-- Bank Bag 7 contents (bank slot 2006; base 7410)
INSERT INTO inventory (character_id, slot_id, item_id, charges, color) VALUES
(1, 7410, 13790, 2, 0), (1, 7411, 13319, 0, 0), (1, 7412, 14690, 0, 0), (1, 7413, 14690, 0, 0),
(1, 7414, 30414, 1, 0), (1, 7415, 13791, 5, 0), (1, 7416, 13318, 0, 0), (1, 7417, 13318, 0, 0);

-- Bank Bag 8 contents (bank slot 2007; base 7610). Indexes 2 and 5 are intentionally empty.
INSERT INTO inventory (character_id, slot_id, item_id, charges, color) VALUES
(1, 7610, 25835, 1, 0), (1, 7611, 25831, 1, 0),
(1, 7613, 25840, 1, 0), (1, 7614, 14746, 0, 0),
(1, 7616, 31602, 0, 0), (1, 7617, 28602, 0, 0);

-- Post-run verification: no legacy child rows should remain; the inserted
-- personal and bank children should total 72 rows.
SELECT COUNT(*) AS legacy_child_rows_remaining
FROM inventory
WHERE character_id = 1
  AND (slot_id BETWEEN 251 AND 1658 OR slot_id BETWEEN 2031 AND 3438);

SELECT COUNT(*) AS live_child_rows_inserted
FROM inventory
WHERE character_id = 1
  AND (slot_id BETWEEN 5000 AND 5279 OR slot_id BETWEEN 6210 AND 7809);

COMMIT;
