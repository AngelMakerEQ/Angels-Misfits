-- Angels Misfits: Necromancer Pet Model Race Correction (485 -> 85)
-- Date: 2026-08-02
-- Reference: docs/decisions/ADR-012_NECROMANCER_ILLUSION_AND_PET_MODEL_CORRECTIONS.md, Part 2
-- Purpose:
--   Correct npc_types.race from 485 (Luclin-era "Spectre" duplicate model) to
--   85 (classic/Kunark-appropriate "Spectre" model, already in live use
--   elsewhere in the database) across the necromancer's late-game skeletal
--   pet line (levels 59-70).
--
-- Prerequisite: take a HeidiSQL database backup before executing this file.
-- Scope: DML only; no table or schema changes. npc_types is read live by
-- zone processes at zone boot -- a Spire restart is sufficient to pick this
-- up, no shared_memory.exe rebuild required (unlike spells_new changes).
--
-- Expected preflight state on the reviewed live database:
--   37 rows across 6 pet chains at race = 485 (id 793 already corrected to
--   race = 85 in a prior, incomplete pass and is intentionally excluded).

-- ---------------------------------------------------------------------------
-- PREFLIGHT: inspect these results before running the UPDATE statement.
-- ---------------------------------------------------------------------------

SELECT p.type, n.id, n.name, n.race, n.texture, n.size
FROM pets p
JOIN npc_types n ON n.id = p.NPCID
WHERE p.type IN ('skel_pet_47_','skel_pet_61_','skel_pet_63_',
                  'skel_pet_65_','skel_pet_67_','skel_pet_70_')
ORDER BY p.type, n.size;

-- ---------------------------------------------------------------------------
-- APPLY: execute as one transaction.
-- ---------------------------------------------------------------------------

START TRANSACTION;

-- Race 85's texture = 1 was confirmed present and valid on the live database
-- before committing to reuse the same texture value across these rows.
-- Size values are left untouched: every affected row already carries an
-- explicit npc_types.size (not a default-table fallback), so this swap has
-- no bearing on displayed height.
UPDATE npc_types
SET race = 85
WHERE race = 485
AND id IN (
    -- Emissary of Thule (skel_pet_47_)
    628, 905, 907, 906,
    -- Legacy of Zek (skel_pet_61_)
    629, 908, 909, 910, 911, 912,
    -- Saryrn's Companion (skel_pet_63_)
    630, 913, 914, 915, 916, 917,
    -- Child of Bertoxxulous (skel_pet_65_)
    631, 918, 919, 920, 921, 922,
    -- Lost Soul (skel_pet_67_) -- id 793 excluded, already at race 85
    632, 789, 790, 791, 792, 840, 841,
    -- Dark Assassin (skel_pet_70_)
    843, 633, 784, 785, 786, 787, 788, 842
);

-- ---------------------------------------------------------------------------
-- VERIFY: expected result is all 38 rows in the chain (37 updated + id 793,
-- already correct) showing race = 85.
-- The transaction is deliberately left open after this query. Inspect the
-- results, then execute COMMIT manually only when they match expectations;
-- otherwise execute ROLLBACK.
-- ---------------------------------------------------------------------------

SELECT p.type, n.id, n.name, n.race, n.texture, n.size
FROM pets p
JOIN npc_types n ON n.id = p.NPCID
WHERE p.type IN ('skel_pet_47_','skel_pet_61_','skel_pet_63_',
                  'skel_pet_65_','skel_pet_67_','skel_pet_70_')
ORDER BY p.type, n.size;

-- On successful verification, run this manually in the same HeidiSQL session:
-- COMMIT;
--
-- On any discrepancy, run instead:
-- ROLLBACK;
