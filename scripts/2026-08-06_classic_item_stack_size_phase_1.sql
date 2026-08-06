-- Angels Misfits: Classic item stack-size corrections, phase 1
--
-- Scope is intentionally narrow and evidence-backed. Do NOT replace this with
-- a blanket "all stackable items = 20" update: Classic arrows and other
-- ammunition legitimately stack to 100, and individual item histories differ.
--
-- Classic/P99 evidence:
--   * Bone Chips: one stack = 20.
--   * Spiderling Silk: one stack = 20 (and stackable by the Velious era).
--   * Peridots: one stack = 20.
--   * Bat Wings: classic stackable consumable/component; normalized to the
--     same 20-item Classic stack size.
--
-- The preflight query was run against Angels Misfits on 2026-08-06. Existing
-- inventory rows for these ids have no charge count above 20, so this change
-- does not create over-cap legacy stacks.

START TRANSACTION;

-- Preflight: all four rows should be stackable and currently show stacksize 100.
SELECT id, Name, stackable, stacksize
FROM items
WHERE id IN (10028, 13068, 13073, 13099)
ORDER BY id;

UPDATE items
SET stacksize = 20
WHERE id IN (
    10028, -- Peridot
    13068, -- Bat Wing
    13073, -- Bone Chips
    13099  -- Spiderling Silk
)
  AND stackable = 1
  AND stacksize > 20;

-- Postflight: each row must be stackable with a 20-item cap.
SELECT id, Name, stackable, stacksize
FROM items
WHERE id IN (10028, 13068, 13073, 13099)
ORDER BY id;

COMMIT;
