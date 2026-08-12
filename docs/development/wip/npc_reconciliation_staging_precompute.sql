-- NPC reconciliation staging table: bulk precompute for rules 5 and 8
-- (docs/development/wip/NPC_RECONCILIATION_REMAINING_ZONE_ROADMAP.md).
--
-- Both checks are pure mechanical SQL lookups with no judgment involved —
-- the roadmap doc's own rules 5/8 already define them as one-query-per-NPC
-- steps. This runs the identical logic once for the whole remaining table
-- instead of once per NPC during review, removing repeated round-trips
-- without changing what gets decided per row. Judgment on what to DO with
-- a sibling or out-of-era match still happens per-row during review.
--
-- Touches ONLY npc_reconciliation_staging (a working/staging table this
-- process owns). Does not write to npc_types, spawn2, or any other live
-- game table — consistent with rule 10 (never apply SQL to the live game
-- database as part of this process).
--
-- Both UPDATEs are guarded by a "not yet checked" WHERE clause, so this is
-- safe to run once now and safe to re-run later (e.g. after a staging
-- table reseed) without re-touching rows already covered.
--
-- Validated against live data before writing this script (2026-08-11):
-- the out-of-era query reproduced real out-of-era matches (e.g.
-- #Adjutant_* names also active in kaelshard, a GoD zone), and the
-- sibling query exactly reproduced the roadmap doc's own emu_id 12016
-- ("a_bandit") example — two level-9 siblings (12056, 12062), matching
-- the doc's stated "5 of 6 pages report the same level/hp/ac" case.
-- Spot-check a handful of newly-populated rows against a manual query
-- after running, per this project's verification standard
-- (docs/development/TESTING.md) — a script completing without error is
-- not verification.

-- ============================================================
-- Rule 5: level-variant sibling precompute
-- ============================================================
-- Adds two columns and populates, for every not-yet-checked row, every
-- OTHER npc_types.id sharing the exact same name with at least one
-- shared in-scope active zone (COALESCE(spawn2.version,0)=0,
-- zone.expansion <= 2 or NULL) — i.e. exactly what rule 5 asks the
-- reviewer to query for by hand, precomputed for the whole table.

ALTER TABLE npc_reconciliation_staging
  ADD COLUMN IF NOT EXISTS level_variant_sibling_ids TEXT NULL,
  ADD COLUMN IF NOT EXISTS level_variant_siblings_checked TINYINT(1) NOT NULL DEFAULT 0;

UPDATE npc_reconciliation_staging s
JOIN npc_types nt ON nt.id = s.npc_id
LEFT JOIN (
    SELECT
        a.npc_id,
        GROUP_CONCAT(DISTINCT CONCAT(nt2.id, ' (lvl ', nt2.level, ', hp ', nt2.hp, ', ac ', nt2.AC, ')')
                      ORDER BY nt2.level SEPARATOR '; ') AS sibling_summary
    FROM (
        SELECT DISTINCT se.npcID AS npc_id, z.short_name AS zone, nt0.name AS name
        FROM spawnentry se
        JOIN spawn2 sp ON sp.spawngroupID = se.spawngroupID
        JOIN zone z ON z.short_name = sp.zone
        JOIN npc_types nt0 ON nt0.id = se.npcID
        WHERE COALESCE(sp.version,0) = 0
          AND (z.expansion IS NULL OR z.expansion <= 2)
    ) a
    JOIN (
        SELECT DISTINCT se.npcID AS npc_id, z.short_name AS zone, nt0.name AS name
        FROM spawnentry se
        JOIN spawn2 sp ON sp.spawngroupID = se.spawngroupID
        JOIN zone z ON z.short_name = sp.zone
        JOIN npc_types nt0 ON nt0.id = se.npcID
        WHERE COALESCE(sp.version,0) = 0
          AND (z.expansion IS NULL OR z.expansion <= 2)
    ) b ON b.zone = a.zone AND b.name = a.name AND b.npc_id <> a.npc_id
    JOIN npc_types nt2 ON nt2.id = b.npc_id
    GROUP BY a.npc_id
) sib ON sib.npc_id = nt.id
SET
    s.level_variant_sibling_ids = sib.sibling_summary,
    s.level_variant_siblings_checked = 1
WHERE COALESCE(s.level_variant_siblings_checked, 0) = 0;

-- ============================================================
-- Rule 8: out-of-era same-name sibling precompute
-- ============================================================
-- For every not-yet-checked row, checks whether any npc_types row
-- sharing the exact same name has an active in-scope-version spawn in
-- an out-of-era zone (zone.expansion > 2) — the roadmap doc's rule 8
-- query, run once for the whole table instead of once per NPC.

UPDATE npc_reconciliation_staging s
JOIN npc_types nt ON nt.id = s.npc_id
LEFT JOIN (
    SELECT
        nt2.name AS npc_name,
        GROUP_CONCAT(DISTINCT CONCAT(z2.short_name, ' (exp ', z2.expansion, ')') ORDER BY z2.short_name SEPARATOR '; ') AS zones_note
    FROM npc_types nt2
    JOIN spawnentry se2 ON se2.npcID = nt2.id
    JOIN spawn2 s22 ON s22.spawngroupID = se2.spawngroupID
    JOIN zone z2 ON z2.short_name = s22.zone
    WHERE COALESCE(s22.version, 0) = 0
      AND NOT (z2.expansion IS NULL OR z2.expansion <= 2)
    GROUP BY nt2.name
) oe ON oe.npc_name = nt.name
SET
    s.out_of_era_sibling_checked = 1,
    s.out_of_era_sibling_found = IF(oe.npc_name IS NOT NULL, 1, 0),
    s.out_of_era_notes = CASE
        WHEN oe.npc_name IS NOT NULL THEN CONCAT('Out-of-era sibling(s): ', oe.zones_note)
        ELSE s.out_of_era_notes
    END
WHERE COALESCE(s.out_of_era_sibling_checked, 0) = 0;

-- ============================================================
-- Post-run sanity checks (run these, don't just trust "0 rows affected")
-- ============================================================
-- SELECT COUNT(*) FROM npc_reconciliation_staging WHERE level_variant_siblings_checked = 0;  -- expect 0
-- SELECT COUNT(*) FROM npc_reconciliation_staging WHERE out_of_era_sibling_checked = 0;        -- expect 0
-- SELECT npc_id, level_variant_sibling_ids FROM npc_reconciliation_staging WHERE npc_id = 12016; -- expect siblings 12056, 12062
-- SELECT COUNT(*) FROM npc_reconciliation_staging WHERE out_of_era_sibling_found = 1;           -- compare against prior manual-checked count as a plausibility check
