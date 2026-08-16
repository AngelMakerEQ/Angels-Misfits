-- ============================================================
-- Faction Reconciliation Infrastructure
-- ============================================================
-- Creates the reference tables, comparison views, and staging
-- table needed for the faction reconciliation project.
--
-- See: docs/development/FACTION_RECONCILIATION_ROADMAP.md
-- ADR: docs/decisions/ADR-025_FACTION_RECONCILIATION.md
--
-- Run against the Angels Misfits database via HeidiSQL.
-- All objects are additive (CREATE IF NOT EXISTS / CREATE OR REPLACE).
-- No existing data is modified.
-- ============================================================

-- ------------------------------------------------------------
-- 1. Reference Tables (populated by parser scripts or wiki fetch)
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS p99_reference_npc_factions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  wiki_title VARCHAR(255) NOT NULL,
  emu_id INT DEFAULT NULL,
  faction_name VARCHAR(255) NOT NULL,
  faction_value INT NOT NULL,
  UNIQUE KEY uq_npc_faction (wiki_title, faction_name),
  KEY idx_emu_id (emu_id),
  KEY idx_faction_name (faction_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS p99_reference_factions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  wiki_title VARCHAR(255) NOT NULL COMMENT 'Wiki page title for this faction',
  faction_name VARCHAR(255) NOT NULL COMMENT 'Faction name as displayed',
  npc_name VARCHAR(255) DEFAULT NULL COMMENT 'NPC name that affects this faction',
  hit_value INT DEFAULT NULL COMMENT 'Faction change value on kill',
  is_member TINYINT(1) DEFAULT 0 COMMENT 'Whether the NPC belongs to this faction',
  notes TEXT DEFAULT NULL,
  UNIQUE KEY uq_faction_npc (faction_name, npc_name),
  KEY idx_faction_name (faction_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS p99_reference_starting_factions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  race VARCHAR(50) NOT NULL,
  class VARCHAR(50) NOT NULL,
  deity VARCHAR(50) DEFAULT NULL,
  faction_name VARCHAR(255) NOT NULL,
  standing_value INT NOT NULL,
  standing_label VARCHAR(50) DEFAULT NULL COMMENT 'e.g., Warmly, Indifferent',
  UNIQUE KEY uq_start_faction (race, class, faction_name),
  KEY idx_faction_name (faction_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- 2. Faction Name Mapping
-- ------------------------------------------------------------
-- Maps P99 wiki faction names to faction_list.id.
-- Handles case/whitespace differences automatically.
-- Unmatched names need manual resolution (add to this table).

CREATE TABLE IF NOT EXISTS faction_name_aliases (
  id INT AUTO_INCREMENT PRIMARY KEY,
  wiki_name VARCHAR(255) NOT NULL COMMENT 'Name as it appears on the P99 wiki',
  db_faction_id INT NOT NULL COMMENT 'FK to faction_list.id',
  UNIQUE KEY uq_alias (wiki_name),
  KEY idx_db_faction (db_faction_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- 3. Comparison Views
-- ------------------------------------------------------------

-- 3a. Match P99 wiki faction names to faction_list entries
CREATE OR REPLACE VIEW faction_reconciliation_name_match AS
SELECT
  src.faction_name AS wiki_faction_name,
  COALESCE(fna.db_faction_id, fl_exact.id, fl_lower.id) AS faction_list_id,
  COALESCE(fl_alias.name, fl_exact.name, fl_lower.name) AS db_faction_name,
  CASE
    WHEN fna.db_faction_id IS NOT NULL THEN 'alias_match'
    WHEN fl_exact.id IS NOT NULL THEN 'exact_match'
    WHEN fl_lower.id IS NOT NULL THEN 'case_insensitive_match'
    ELSE 'unmatched'
  END AS match_status
FROM (
  SELECT DISTINCT faction_name
  FROM p99_reference_npc_factions
  UNION
  SELECT DISTINCT faction_name
  FROM p99_reference_factions
) src
LEFT JOIN faction_name_aliases fna
  ON fna.wiki_name = src.faction_name
LEFT JOIN faction_list fl_alias
  ON fl_alias.id = fna.db_faction_id
LEFT JOIN faction_list fl_exact
  ON fl_exact.name = src.faction_name
  AND fna.db_faction_id IS NULL
LEFT JOIN faction_list fl_lower
  ON LOWER(TRIM(fl_lower.name)) = LOWER(TRIM(src.faction_name))
  AND fl_exact.id IS NULL
  AND fna.db_faction_id IS NULL;

-- 3b. Compare NPC faction hits: wiki vs. database
CREATE OR REPLACE VIEW faction_reconciliation_hit_diff AS
SELECT
  prnf.wiki_title,
  prnf.emu_id,
  nt.name AS db_npc_name,
  nt.npc_faction_id AS db_npc_faction_id,
  prnf.faction_name AS wiki_faction_name,
  prnf.faction_value AS wiki_hit_value,
  frnm.faction_list_id AS db_faction_list_id,
  nfe.value AS db_hit_value,
  CASE
    WHEN frnm.faction_list_id IS NULL THEN 'FACTION_NAME_UNMATCHED'
    WHEN nt.npc_faction_id = 0 THEN 'NPC_HAS_NO_FACTION_GROUP'
    WHEN nfe.value IS NULL THEN 'MISSING_IN_DB'
    WHEN nfe.value != prnf.faction_value THEN 'VALUE_MISMATCH'
    ELSE 'MATCH'
  END AS diff_status,
  CASE
    WHEN nfe.value IS NOT NULL AND nfe.value != prnf.faction_value
    THEN ABS(nfe.value - prnf.faction_value)
    ELSE NULL
  END AS value_delta
FROM p99_reference_npc_factions prnf
LEFT JOIN npc_types nt ON nt.id = prnf.emu_id
LEFT JOIN faction_reconciliation_name_match frnm
  ON frnm.wiki_faction_name = prnf.faction_name
LEFT JOIN npc_faction_entries nfe
  ON nfe.npc_faction_id = nt.npc_faction_id
  AND nfe.faction_list_id = frnm.faction_list_id
WHERE prnf.emu_id IS NOT NULL;

-- 3c. DB faction hits with no corresponding wiki entry
CREATE OR REPLACE VIEW faction_reconciliation_extra_db_hits AS
SELECT
  nt.id AS npc_id,
  nt.name AS npc_name,
  nt.npc_faction_id,
  fl.id AS faction_list_id,
  fl.name AS faction_name,
  nfe.value AS db_hit_value
FROM npc_types nt
JOIN npc_faction_entries nfe ON nfe.npc_faction_id = nt.npc_faction_id
JOIN faction_list fl ON fl.id = nfe.faction_list_id
WHERE nt.id IN (SELECT DISTINCT emu_id FROM p99_reference_npc_factions WHERE emu_id IS NOT NULL)
  AND NOT EXISTS (
    SELECT 1 FROM p99_reference_npc_factions prnf
    JOIN faction_reconciliation_name_match frnm
      ON frnm.wiki_faction_name = prnf.faction_name
    WHERE prnf.emu_id = nt.id
      AND frnm.faction_list_id = fl.id
  );

-- 3d. Summary: discrepancy counts by status
CREATE OR REPLACE VIEW faction_reconciliation_summary AS
SELECT
  diff_status,
  COUNT(*) AS hit_count,
  COUNT(DISTINCT emu_id) AS npc_count
FROM faction_reconciliation_hit_diff
GROUP BY diff_status;

-- 3e. NPCs with faction data on wiki but no faction group in DB
CREATE OR REPLACE VIEW faction_reconciliation_no_group AS
SELECT DISTINCT
  prnf.wiki_title,
  prnf.emu_id,
  nt.name AS db_npc_name,
  nt.npc_faction_id,
  GROUP_CONCAT(
    CONCAT(prnf.faction_name, ':', prnf.faction_value)
    ORDER BY prnf.faction_name SEPARATOR '; '
  ) AS wiki_faction_hits
FROM p99_reference_npc_factions prnf
JOIN npc_types nt ON nt.id = prnf.emu_id
WHERE nt.npc_faction_id = 0
GROUP BY prnf.emu_id;

-- 3f. Starting faction comparison
CREATE OR REPLACE VIEW faction_reconciliation_starting_diff AS
SELECT
  prsf.race,
  prsf.class,
  prsf.deity,
  prsf.faction_name AS wiki_faction_name,
  prsf.standing_value AS wiki_standing,
  prsf.standing_label AS wiki_label,
  frnm.faction_list_id AS db_faction_id,
  frnm.db_faction_name,
  fl.base AS db_base_value,
  CASE
    WHEN frnm.faction_list_id IS NULL THEN 'FACTION_NOT_FOUND'
    ELSE 'FOUND'
  END AS match_status
FROM p99_reference_starting_factions prsf
LEFT JOIN faction_reconciliation_name_match frnm
  ON frnm.wiki_faction_name = prsf.faction_name;

-- ------------------------------------------------------------
-- 4. Staging Table
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS faction_reconciliation_staging (
  id INT AUTO_INCREMENT PRIMARY KEY,
  npc_id INT NOT NULL,
  npc_name VARCHAR(255) NOT NULL,
  zone_short_name VARCHAR(32) DEFAULT NULL,
  wiki_title VARCHAR(255) DEFAULT NULL,

  -- Current DB state
  db_npc_faction_id INT DEFAULT NULL,
  db_primary_faction_name VARCHAR(255) DEFAULT NULL,
  db_faction_hits TEXT DEFAULT NULL COMMENT 'Current DB faction hits as name:value pairs',

  -- P99 reference state
  wiki_faction_hits TEXT DEFAULT NULL COMMENT 'P99 wiki faction hits as name:value pairs',

  -- Discrepancy summary
  has_missing_hits TINYINT(1) DEFAULT 0,
  has_extra_hits TINYINT(1) DEFAULT 0,
  has_value_mismatches TINYINT(1) DEFAULT 0,
  has_affiliation_mismatch TINYINT(1) DEFAULT 0,

  -- Reconciliation decision
  status ENUM(
    'pending',
    'reviewed',
    'fix_staged',
    'accepted_as_is',
    'deferred',
    'applied'
  ) NOT NULL DEFAULT 'pending',

  priority ENUM('P0', 'P1', 'P2', 'P3', 'P4') DEFAULT NULL,

  resolution_notes TEXT DEFAULT NULL,
  migration_sql TEXT DEFAULT NULL,
  reviewed_by VARCHAR(100) DEFAULT NULL,
  reviewed_at DATETIME DEFAULT NULL,

  UNIQUE KEY uq_npc (npc_id),
  KEY idx_status (status),
  KEY idx_priority (priority),
  KEY idx_zone (zone_short_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- 5. Utility: Shared npc_faction group membership
-- ------------------------------------------------------------
-- Use this before modifying any npc_faction_entries row to see
-- all NPCs that share the same faction group.

CREATE OR REPLACE VIEW faction_reconciliation_shared_groups AS
SELECT
  nf.id AS npc_faction_id,
  nf.name AS faction_group_name,
  nf.primaryfaction,
  fl.name AS primary_faction_name,
  COUNT(nt.id) AS npc_count,
  GROUP_CONCAT(CONCAT(nt.id, ':', nt.name) ORDER BY nt.id SEPARATOR ', ') AS npc_list
FROM npc_faction nf
JOIN npc_types nt ON nt.npc_faction_id = nf.id
LEFT JOIN faction_list fl ON fl.id = nf.primaryfaction
GROUP BY nf.id
HAVING COUNT(nt.id) > 1
ORDER BY npc_count DESC;

-- ============================================================
-- Done. Verify with:
--   SELECT * FROM faction_reconciliation_summary;
--   SELECT * FROM faction_reconciliation_name_match WHERE match_status = 'unmatched';
--   SELECT * FROM faction_reconciliation_no_group;
-- ============================================================
