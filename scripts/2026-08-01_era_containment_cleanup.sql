-- Angels Misfits: Era-Containment Cleanup
-- Date: 2026-08-01
-- Purpose:
--   1. Enforce ADR-009's exclusion of Beastlord and Berserker spell grants.
--   2. Disable the unused Dragons of Norrath content flag, consistent with
--      ADR-001's Velious-and-earlier content boundary.
--
-- Prerequisite: take a HeidiSQL database backup before executing this file.
-- Scope: DML only; no table or schema changes.
--
-- Expected preflight state on the reviewed live database:
--   Beastlord grants (classes15 BETWEEN 1 AND 254): 1157
--   Berserker grants  (classes16 BETWEEN 1 AND 254):  735
--   don_nest_unlocked: exactly one row, enabled = 1

-- ---------------------------------------------------------------------------
-- PREFLIGHT: inspect these results before running the UPDATE statements.
-- ---------------------------------------------------------------------------

SELECT
  SUM(classes15 BETWEEN 1 AND 254) AS beastlord_grants,
  SUM(classes16 BETWEEN 1 AND 254) AS berserker_grants,
  COUNT(*) AS rows_with_either_grant
FROM spells_new
WHERE classes15 BETWEEN 1 AND 254
   OR classes16 BETWEEN 1 AND 254;

SELECT id, flag_name, enabled, notes
FROM content_flags
WHERE flag_name = 'don_nest_unlocked';

-- ---------------------------------------------------------------------------
-- APPLY: execute as one transaction.
-- ---------------------------------------------------------------------------

START TRANSACTION;

-- Classes 15 and 16 are Beastlord and Berserker respectively. 255 is the
-- standard disabled/unlearnable sentinel used throughout spells_new.
-- This intentionally does not touch any of the 14 Velious-playable columns.
UPDATE spells_new
SET classes15 = 255
WHERE classes15 BETWEEN 1 AND 254;

UPDATE spells_new
SET classes16 = 255
WHERE classes16 BETWEEN 1 AND 254;

-- ADR-001's expansion rules are still the primary gate. This removes an
-- unnecessary post-Velious content exception from the live configuration.
UPDATE content_flags
SET enabled = 0
WHERE flag_name = 'don_nest_unlocked'
  AND enabled <> 0;

-- ---------------------------------------------------------------------------
-- VERIFY: expected results are 0 / 0 and enabled = 0.
-- The transaction is deliberately left open after these queries. Inspect the
-- results, then execute COMMIT manually only when they match expectations;
-- otherwise execute ROLLBACK.
-- ---------------------------------------------------------------------------

SELECT
  SUM(classes15 BETWEEN 1 AND 254) AS beastlord_grants_remaining,
  SUM(classes16 BETWEEN 1 AND 254) AS berserker_grants_remaining
FROM spells_new;

SELECT id, flag_name, enabled, notes
FROM content_flags
WHERE flag_name = 'don_nest_unlocked';

-- On successful verification, run this manually in the same HeidiSQL session:
-- COMMIT;
--
-- On any discrepancy, run instead:
-- ROLLBACK;

-- Post-commit regression check: confirms the active SoV gate remains intact.
SELECT rule_name, rule_value
FROM rule_values
WHERE ruleset_id = 1
  AND rule_name IN (
    'World:ExpansionSettings',
    'Expansion:CurrentExpansion',
    'World:CharacterSelectExpansionSettings',
    'World:UseClientBasedExpansionSettings'
  )
ORDER BY rule_name;
