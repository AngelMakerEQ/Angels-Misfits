# Faction Reconciliation Roadmap

**Purpose:** Authoritative process document for the Angels Misfits faction
reconciliation. Written so any LLM or human can start or resume the project
at any moment with no prior knowledge.

**Authority:** This document is the sole working process for faction
reconciliation. ADR-025 is the decision record; this document is the
execution plan.

**Last Updated:** 2026-08-16

---

## What This Project Is

Angels Misfits is an EverQuest emulator (EQEmu) server targeting the
Velious era. Its database was imported from PEQ (a modern all-era
database) and is being corrected toward classic accuracy using P99 wiki
as the primary reference. ADR-010 already corrected the 8 global faction
tier boundaries. This project reconciles the remaining faction data:

1. **NPC faction affiliations** — which faction group each NPC belongs to
2. **Faction hits on kill** — which factions change (and by how much)
   when an NPC is killed
3. **Faction list completeness** — are all classic-era factions present
4. **Starting faction standings** — race/class/deity modifiers at
   character creation

---

## How the Database Models Factions

Understanding these tables is essential. EQEmu uses a layered faction
system:

### Core Tables

```
faction_list          — Master list of all factions
  id                  — Faction ID (e.g., 262 = "Claws of Veeshan")
  name                — Faction name
  base                — Base value all players start at (before modifiers)

faction_list_mod      — Starting faction modifiers by race/class/deity
  faction_id          — FK → faction_list.id
  mod                 — Adjustment value (positive = friendlier)
  mod_name            — What triggers it: "r.X" (race), "c.X" (class), "d.X" (deity)

npc_faction           — Faction "groups" that NPCs belong to
  id                  — Group ID (referenced by npc_types.npc_faction_id)
  name                — Descriptive name
  primaryfaction      — FK → faction_list.id (the faction this group IS)
  ignore_primary_assist — Whether NPCs in this group assist each other

npc_faction_entries   — Faction hits triggered when NPCs in a group are killed
  npc_faction_id      — FK → npc_faction.id (the group)
  faction_list_id     — FK → faction_list.id (the faction affected)
  value               — Hit amount (positive = gain, negative = loss)
  npc_value           — NPC behavior modifier (typically 0)
  temp                — Temporary faction flag (typically 0)

npc_types             — NPC definitions
  id                  — NPC template ID
  npc_faction_id      — FK → npc_faction.id (which faction group this NPC is in)
```

### How It Works at Runtime

When a player kills an NPC:
1. Engine looks up `npc_types.npc_faction_id` → `npc_faction.id`
2. Engine reads all `npc_faction_entries` rows for that `npc_faction_id`
3. For each row, player's standing with `faction_list_id` is adjusted by
   `value` — applied directly, no scaling (`HateList::DoFactionHits`)
4. Player's effective standing with any faction =
   `faction_list.base` + sum(`faction_list_mod` for player's race/class/deity)
   + accumulated hits

### Example: Killing an Orc Pawn

```
npc_types: a_Orc_Pawn → npc_faction_id = 18
npc_faction: id=18, primaryfaction=24 (Orcs of Norrath)
npc_faction_entries for npc_faction_id=18:
  faction_list_id=24 (Orcs of Norrath), value=-1    → lose 1 orc faction
  faction_list_id=22 (Freeport Militia),  value=+1   → gain 1 militia faction
  faction_list_id=67 (Knights of Truth),  value=+1   → gain 1 knights faction
  faction_list_id=289 (Merchants of Qeynos), value=+1 → gain 1 merchant faction
```

This was verified against P99's documented Death Fist Orcs example and
matched almost exactly (ADR-010).

---

## Data Sources and Access

### Primary Source: P99 Wiki

**Source hierarchy (from HISTORICAL_SOURCES.md):**
client data > EQEmu source > P99 wiki > PEQ > archived Allakhazam/Lucy

**P99 wiki pages for faction data:**
- Individual NPC pages (`{{Namedmobpage}}` template) — contain `faction`
  field listing faction hits on kill
- Individual faction pages (e.g., `Claws_of_Veeshan_(faction)`) — list
  all NPCs that affect the faction and the hit values
- `Starting_Faction_Standings` — starting values by race/class
- `Category:Factions` — index of all documented factions
- `Category:Significant_Factions` — key progression factions

**Access method:** `wiki.project1999.com` is blocked from remote Claude
Code sessions (network egress restriction). Access works from:
- Local Claude Code CLI (runs in the machine's normal shell)
- EQEmu MCP (for database queries against the live server)
- The existing P99 wiki cache at `C:\Repository\p99-wiki-cache\`

Two fetch methods work from local sessions:
```bash
# Single page raw content
curl -s "https://wiki.project1999.com/index.php?title=<Page_Name>&action=raw"

# Batch query (up to ~50 pages per request)
curl -s "https://wiki.project1999.com/api.php?action=query&titles=A|B|C&prop=revisions&rvprop=content&format=json&redirects=1"
```

### Existing Infrastructure

The project already has NPC reconciliation tooling (built 2026-08-10):

- **`p99_reference_npcs`** — 6,442 parsed P99 wiki NPC pages, created by
  `C:\Repository\p99-wiki-cache\parse_npcs.py` from `{{Namedmobpage}}`
  template data. Contains stats fields. **May or may not contain faction
  hit data** — this must be checked first (see Phase 0).
- **`npc_reconciliation_staging`** — 9,860 rows for NPC stat decisions
- **`npc_reconciliation_match`/`_diff`** — SQL views for stat comparison
- **`npc_reconciliation_inactive_notes`** — 558 rows for dormant NPCs

### Live Database Access

The live database is MariaDB, managed via HeidiSQL on the local Windows
machine. The EQEmu MCP server provides read-only SQL access from Claude
sessions. All write operations are executed by the project lead via
HeidiSQL, following the established workflow (generate SQL → review →
apply in HeidiSQL).

---

## Phase 0: Assess Existing Data and Fill Gaps

**Goal:** Determine what faction data already exists in the reference
tables and what needs to be collected.

### Step 0.1: Check p99_reference_npcs for faction data

Run against the live database (via EQEmu MCP or HeidiSQL):
```sql
DESCRIBE p99_reference_npcs;
SELECT * FROM p99_reference_npcs LIMIT 5;
```

**If faction data exists** (a `faction` or `faction_hits` column):
proceed to Phase 1.

**If faction data is missing:** the `{{Namedmobpage}}` template's
`faction` field was not parsed by the original script. Proceed to
Step 0.2.

### Step 0.2: Parse faction data from cached wiki pages

The P99 wiki cache lives at `C:\Repository\p99-wiki-cache\`. The
`{{Namedmobpage}}` template includes a `faction` parameter with format:

```
| faction = {{Faction|Claws of Veeshan|+1}}{{Faction|Kromzek|-5}}
```

or plain-text format:

```
| faction = [[Claws of Veeshan]] (+1), [[Kromzek]] (-5)
```

**Option A (recommended): Extend the existing parser.**
Modify `C:\Repository\p99-wiki-cache\parse_npcs.py` to also extract the
`faction` field and store it. Create a companion table:

```sql
CREATE TABLE IF NOT EXISTS p99_reference_npc_factions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  wiki_title VARCHAR(255) NOT NULL,
  emu_id INT DEFAULT NULL,
  faction_name VARCHAR(255) NOT NULL,
  faction_value INT NOT NULL,
  UNIQUE KEY uq_npc_faction (wiki_title, faction_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**Option B: Standalone parser.** Use the script at
`scripts/parse_faction_data.py` (committed with this roadmap) to extract
faction data from the raw wiki page cache independently.

### Step 0.3: Build a P99 faction reference table

Fetch individual faction pages from the P99 wiki. Each faction page
(e.g., `Claws_of_Veeshan_(faction)`) lists:
- All NPCs that affect this faction
- The hit values (+/- per kill)
- Which NPCs belong to this faction
- Related quests that grant faction

Create a reference table:
```sql
CREATE TABLE IF NOT EXISTS p99_reference_factions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  wiki_title VARCHAR(255) NOT NULL,
  faction_name VARCHAR(255) NOT NULL,
  npc_name VARCHAR(255) DEFAULT NULL,
  hit_value INT DEFAULT NULL,
  is_member TINYINT(1) DEFAULT 0,
  notes TEXT DEFAULT NULL,
  UNIQUE KEY uq_faction_npc (faction_name, npc_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### Step 0.4: Fetch starting faction standings

From `https://wiki.project1999.com/Starting_Faction_Standings`:
```sql
CREATE TABLE IF NOT EXISTS p99_reference_starting_factions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  race VARCHAR(50) NOT NULL,
  class VARCHAR(50) NOT NULL,
  deity VARCHAR(50) DEFAULT NULL,
  faction_name VARCHAR(255) NOT NULL,
  standing_value INT NOT NULL,
  standing_label VARCHAR(50) DEFAULT NULL,
  UNIQUE KEY uq_start_faction (race, class, faction_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### Phase 0 Completion Criteria

- [ ] `p99_reference_npcs` faction data status confirmed
- [ ] `p99_reference_npc_factions` populated (or equivalent)
- [ ] `p99_reference_factions` populated from individual faction pages
- [ ] `p99_reference_starting_factions` populated
- [ ] All reference tables verified (spot-check 5+ entries against wiki)

---

## Phase 1: Infrastructure — Comparison Views and Staging

**Goal:** Build the SQL infrastructure to compare live database faction
data against P99 reference data, and stage corrections.

### Step 1.1: Faction name matching view

Map P99 wiki faction names to `faction_list.id` values:

```sql
CREATE OR REPLACE VIEW faction_reconciliation_name_match AS
SELECT
  prf.faction_name AS wiki_faction_name,
  fl.id AS faction_list_id,
  fl.name AS db_faction_name,
  CASE
    WHEN fl.id IS NOT NULL THEN 'matched'
    ELSE 'unmatched'
  END AS match_status
FROM (SELECT DISTINCT faction_name FROM p99_reference_factions) prf
LEFT JOIN faction_list fl
  ON LOWER(TRIM(prf.faction_name)) = LOWER(TRIM(fl.name));
```

### Step 1.2: NPC faction hit comparison view

Compare what P99 says each NPC's kill should produce vs. what the live
database has:

```sql
CREATE OR REPLACE VIEW faction_reconciliation_hit_diff AS
SELECT
  prnf.wiki_title,
  prnf.emu_id,
  nt.name AS db_npc_name,
  prnf.faction_name AS wiki_faction_name,
  prnf.faction_value AS wiki_hit_value,
  fl.id AS db_faction_list_id,
  nfe.value AS db_hit_value,
  CASE
    WHEN nfe.value IS NULL THEN 'MISSING_IN_DB'
    WHEN nfe.value != prnf.faction_value THEN 'VALUE_MISMATCH'
    ELSE 'MATCH'
  END AS diff_status
FROM p99_reference_npc_factions prnf
JOIN npc_types nt ON nt.id = prnf.emu_id
LEFT JOIN faction_list fl
  ON LOWER(TRIM(prnf.faction_name)) = LOWER(TRIM(fl.name))
LEFT JOIN npc_faction nf ON nf.id = nt.npc_faction_id
LEFT JOIN npc_faction_entries nfe
  ON nfe.npc_faction_id = nf.id
  AND nfe.faction_list_id = fl.id
WHERE prnf.emu_id IS NOT NULL;
```

### Step 1.3: Extra DB faction hits not on wiki

```sql
CREATE OR REPLACE VIEW faction_reconciliation_extra_db_hits AS
SELECT
  nt.id AS npc_id,
  nt.name AS npc_name,
  fl.name AS faction_name,
  nfe.value AS db_hit_value,
  prnf.faction_value AS wiki_hit_value
FROM npc_types nt
JOIN npc_faction nf ON nf.id = nt.npc_faction_id
JOIN npc_faction_entries nfe ON nfe.npc_faction_id = nf.id
JOIN faction_list fl ON fl.id = nfe.faction_list_id
LEFT JOIN p99_reference_npc_factions prnf
  ON prnf.emu_id = nt.id
  AND LOWER(TRIM(prnf.faction_name)) = LOWER(TRIM(fl.name))
WHERE prnf.faction_value IS NULL
  AND nt.id IN (SELECT emu_id FROM p99_reference_npc_factions WHERE emu_id IS NOT NULL);
```

### Step 1.4: Faction reconciliation staging table

```sql
CREATE TABLE IF NOT EXISTS faction_reconciliation_staging (
  id INT AUTO_INCREMENT PRIMARY KEY,
  npc_id INT NOT NULL,
  npc_name VARCHAR(255) NOT NULL,
  zone_short_name VARCHAR(32) DEFAULT NULL,
  wiki_title VARCHAR(255) DEFAULT NULL,

  -- Current DB state
  db_npc_faction_id INT DEFAULT NULL,
  db_primary_faction_name VARCHAR(255) DEFAULT NULL,

  -- P99 reference state
  wiki_faction_hits TEXT DEFAULT NULL,

  -- Reconciliation decision
  status ENUM(
    'pending',
    'reviewed',
    'fix_staged',
    'accepted_as_is',
    'deferred',
    'applied'
  ) NOT NULL DEFAULT 'pending',

  resolution_notes TEXT DEFAULT NULL,
  migration_sql TEXT DEFAULT NULL,
  reviewed_by VARCHAR(100) DEFAULT NULL,
  reviewed_at DATETIME DEFAULT NULL,

  UNIQUE KEY uq_npc (npc_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### Step 1.5: Starting faction comparison view

```sql
CREATE OR REPLACE VIEW faction_reconciliation_starting_diff AS
SELECT
  prsf.race,
  prsf.class,
  prsf.deity,
  prsf.faction_name AS wiki_faction_name,
  prsf.standing_value AS wiki_standing,
  fl.id AS db_faction_id,
  flm.mod AS db_modifier,
  flm.mod_name AS db_mod_key,
  CASE
    WHEN fl.id IS NULL THEN 'FACTION_NOT_FOUND'
    WHEN flm.mod IS NULL THEN 'MODIFIER_MISSING'
    WHEN flm.mod != prsf.standing_value THEN 'VALUE_MISMATCH'
    ELSE 'MATCH'
  END AS diff_status
FROM p99_reference_starting_factions prsf
LEFT JOIN faction_list fl
  ON LOWER(TRIM(prsf.faction_name)) = LOWER(TRIM(fl.name))
LEFT JOIN faction_list_mod flm
  ON flm.faction_id = fl.id;
```

### Phase 1 Completion Criteria

- [ ] All views created and returning results without errors
- [ ] Staging table created and seed query verified
- [ ] Spot-check: pick 3 well-known NPCs (e.g., an orc pawn, a Kael
      guard, a Claws of Veeshan dragon) and verify the comparison views
      produce correct/sensible output

---

## Phase 2: Automated Triage

**Goal:** Populate the staging table and classify discrepancies by
severity and confidence.

### Step 2.1: Seed the staging table

```sql
INSERT INTO faction_reconciliation_staging
  (npc_id, npc_name, zone_short_name, db_npc_faction_id, wiki_title)
SELECT DISTINCT
  nt.id,
  nt.name,
  sz.zone AS zone_short_name,
  nt.npc_faction_id,
  prn.wiki_title
FROM npc_types nt
JOIN spawnentry se ON se.npc_id = nt.id
JOIN spawn2 s2 ON s2.spawngroupid = se.spawngroupid
JOIN zone z ON z.short_name = s2.zone AND z.expansion <= 2
LEFT JOIN (SELECT DISTINCT zone AS zone, npc_id
           FROM spawnentry se2
           JOIN spawn2 s3 ON s3.spawngroupid = se2.spawngroupid
          ) sz ON sz.npc_id = nt.id
LEFT JOIN p99_reference_npc_factions prnf ON prnf.emu_id = nt.id
LEFT JOIN p99_reference_npcs prn ON prn.emu_id = nt.id
WHERE COALESCE(s2.version, 0) = 0
  AND s2.enabled = 1
GROUP BY nt.id
ON DUPLICATE KEY UPDATE wiki_title = VALUES(wiki_title);
```

### Step 2.2: Run the comparison queries

Populate `wiki_faction_hits` for each staged NPC:
```sql
UPDATE faction_reconciliation_staging frs
JOIN (
  SELECT emu_id,
    GROUP_CONCAT(
      CONCAT(faction_name, ':', faction_value)
      ORDER BY faction_name
      SEPARATOR '; '
    ) AS hits
  FROM p99_reference_npc_factions
  WHERE emu_id IS NOT NULL
  GROUP BY emu_id
) wiki ON wiki.emu_id = frs.npc_id
SET frs.wiki_faction_hits = wiki.hits;
```

### Step 2.3: Auto-classify discrepancies

```sql
-- Mark NPCs with no wiki faction data as deferred
UPDATE faction_reconciliation_staging
SET status = 'deferred',
    resolution_notes = 'No faction data on P99 wiki page'
WHERE wiki_faction_hits IS NULL OR wiki_faction_hits = '';

-- Mark NPCs where DB and wiki agree as accepted
-- (requires joining against the hit comparison view)
```

### Priority Classification

Triage findings into priority tiers:

| Priority | Description | Action |
|---|---|---|
| **P0 — Blocking** | NPC has no faction assignment at all (`npc_faction_id = 0`) but wiki documents faction hits | Fix immediately |
| **P1 — High** | Significant factions (Velious armor, epic quest, city access) with wrong hit values | Fix in first batch |
| **P2 — Medium** | Non-trivial faction hit value mismatches (delta > 2) | Fix in second batch |
| **P3 — Low** | Minor value discrepancies (delta 1-2), extra DB hits not on wiki | Review, may accept as-is |
| **P4 — Investigate** | Wiki/DB faction name doesn't match, ambiguous mapping | Research before deciding |

### Significant Factions to Prioritize

From P99 wiki's "Significant Factions" category and the project's
Velious focus:

| Faction | Why It Matters |
|---|---|
| Claws of Veeshan | Velious armor quests (Ally required) |
| Kromzek / Kromrif | Kael Drakkel access and armor quests |
| Coldain | Thurgadin access and armor quests (Kindly required) |
| Yelinak / Council of Wyrms | Temple of Veeshan progression |
| Knights of Truth | Freeport city access |
| Freeport Militia | Freeport city access |
| Merchants of Qeynos | Qeynos vendor access |
| Neriak factions | Dark elf city access |
| Oggok / Grobb factions | Ogre/Troll city access |
| Cabilis factions | Iksar city access |

### Phase 2 Completion Criteria

- [ ] Staging table fully seeded
- [ ] Wiki faction hits populated for all NPCs with wiki data
- [ ] Auto-classification applied
- [ ] Priority counts tallied and recorded in this document's
      Progress Tracking section

---

## Phase 3: Manual Review and Migration Staging

**Goal:** Review each discrepancy, record a decision, and generate SQL.

### Processing Rules

1. **One NPC at a time, ascending npc_id order.** Resume query:
   ```sql
   SELECT * FROM faction_reconciliation_staging
   WHERE status = 'pending'
   ORDER BY npc_id ASC
   LIMIT 1;
   ```

2. **P99 wiki is authoritative** for faction hit values and NPC faction
   affiliation within scope (Classic/Kunark/Velious, version 0).

3. **Shared `npc_faction` groups are common.** Many NPCs share the same
   `npc_faction_id` (and thus the same faction hits). A fix to
   `npc_faction_entries` for one NPC's group affects ALL NPCs in that
   group. Before changing any `npc_faction_entries` row:
   ```sql
   SELECT id, name FROM npc_types WHERE npc_faction_id = <the_group_id>;
   ```
   Verify the change is correct for every NPC in that group, not just
   the one currently under review.

4. **When P99 and DB disagree on which faction group an NPC belongs to:**
   check `npc_faction.primaryfaction` for the DB's assignment and compare
   against what the P99 wiki says the NPC's faction affiliation is. The
   NPC may need its `npc_types.npc_faction_id` changed to point to a
   different (or new) `npc_faction` group.

5. **When a needed `npc_faction` group doesn't exist:** create one. Use
   the next available ID (check `SELECT MAX(id) FROM npc_faction`).

6. **Record the migration SQL** in the staging row's `migration_sql`
   column. Use guarded updates:
   ```sql
   UPDATE npc_faction_entries
   SET value = <new_value>
   WHERE npc_faction_id = <group_id>
     AND faction_list_id = <faction_id>
     AND value = <old_value>;  -- guard against double-application
   ```

7. **Defer, don't guess.** If the wiki is ambiguous or the mapping is
   unclear, set `status = 'deferred'` with a note explaining why.

### Review Workflow per NPC

For each pending NPC:

1. Read the NPC's P99 wiki page (via cache or live fetch if accessible)
2. Compare wiki faction hits against DB faction hits:
   ```sql
   SELECT fl.name, nfe.value
   FROM npc_faction_entries nfe
   JOIN faction_list fl ON fl.id = nfe.faction_list_id
   WHERE nfe.npc_faction_id = (
     SELECT npc_faction_id FROM npc_types WHERE id = <npc_id>
   );
   ```
3. Compare wiki faction affiliation against DB affiliation:
   ```sql
   SELECT nf.primaryfaction, fl.name
   FROM npc_faction nf
   JOIN faction_list fl ON fl.id = nf.primaryfaction
   WHERE nf.id = (SELECT npc_faction_id FROM npc_types WHERE id = <npc_id>);
   ```
4. Record decision in staging table
5. If fix needed, record SQL in `migration_sql`

### Phase 3 Completion Criteria

- [ ] All P0 and P1 items reviewed and staged
- [ ] P2 items reviewed and staged
- [ ] All staged SQL validated (dry-run in a test transaction)

---

## Phase 4: Migration and Verification

**Goal:** Apply corrections to the live database and verify.

### Step 4.1: Generate consolidated migration

Concatenate all staged SQL into a single migration file:
```sql
-- scripts/YYYY-MM-DD_faction_reconciliation_batch_N.sql
BEGIN;

-- [Auto-generated from faction_reconciliation_staging]
-- Each UPDATE is guarded by the old value to prevent double-application

-- ... individual corrections ...

COMMIT;
```

### Step 4.2: Apply via HeidiSQL

Following the established workflow:
1. Back up affected tables (`mysqldump --single-transaction`)
2. Review the migration SQL
3. Execute in HeidiSQL
4. Verify via spot-check queries

### Step 4.3: Post-application verification

```sql
-- Verify no regressions on known-good faction hits
-- (reuse the Death Fist Orcs example from ADR-010)
SELECT fl.name, nfe.value
FROM npc_faction_entries nfe
JOIN faction_list fl ON fl.id = nfe.faction_list_id
WHERE nfe.npc_faction_id = (SELECT npc_faction_id FROM npc_types WHERE id = <orc_pawn_id>);

-- Count remaining discrepancies
SELECT diff_status, COUNT(*)
FROM faction_reconciliation_hit_diff
GROUP BY diff_status;
```

### Step 4.4: Update staging table

```sql
UPDATE faction_reconciliation_staging
SET status = 'applied'
WHERE status = 'fix_staged'
  AND npc_id IN (<list of applied npc_ids>);
```

### Phase 4 Completion Criteria

- [ ] Migration applied successfully
- [ ] Known-good examples verified
- [ ] Staging table updated
- [ ] CHANGELOG.md entry added
- [ ] PROJECT_STATUS.md updated

---

## Phase 5: Starting Faction Standings

**Goal:** Reconcile `faction_list_mod` against P99's documented starting
faction standings.

This is a separate, self-contained pass because starting standings are
player-side data (race/class/deity modifiers), not NPC-kill data, and
use a different P99 wiki source page.

### Step 5.1: Cross-reference

Compare `p99_reference_starting_factions` against `faction_list_mod`:
```sql
SELECT * FROM faction_reconciliation_starting_diff
WHERE diff_status != 'MATCH';
```

### Step 5.2: Stage and apply

Same workflow as Phases 3-4 but for `faction_list_mod` rows.

### Phase 5 Completion Criteria

- [ ] All starting faction standings compared
- [ ] Discrepancies classified and reviewed
- [ ] Migration applied and verified

---

## Progress Tracking

### Current Status

| Phase | Status | Notes |
|---|---|---|
| Phase 0 | Not started | Check existing data, fill gaps |
| Phase 1 | Not started | Build comparison infrastructure |
| Phase 2 | Not started | Automated triage |
| Phase 3 | Not started | Manual review |
| Phase 4 | Not started | Apply migrations |
| Phase 5 | Not started | Starting faction standings |

### Discrepancy Counts (populated during Phase 2)

| Priority | Count | Reviewed | Staged | Applied |
|---|---|---|---|---|
| P0 — Blocking | — | — | — | — |
| P1 — High | — | — | — | — |
| P2 — Medium | — | — | — | — |
| P3 — Low | — | — | — | — |
| P4 — Investigate | — | — | — | — |

### Batch History

| Batch | Date | NPCs | Migration File | Status |
|---|---|---|---|---|
| — | — | — | — | — |

---

## Known Risks and Mitigations

### Shared npc_faction groups

Many NPCs share the same `npc_faction_id`. A change to
`npc_faction_entries` for one NPC's group affects ALL NPCs in that group.
**Mitigation:** Always check all NPCs in a group before modifying it. If
only one NPC needs different hits, create a new `npc_faction` group for
it rather than modifying the shared one.

### Faction name mismatches

P99 wiki faction names may not exactly match `faction_list.name` values.
**Mitigation:** The `faction_reconciliation_name_match` view identifies
unmatched names. Build a manual mapping table for known aliases (e.g.,
"Claws of Veeshan" vs "ClawsOfVeeshan").

### Wiki data quality

P99 wiki faction data is community-maintained and may contain errors.
**Mitigation:** Cross-reference significant findings against multiple
wiki pages (the NPC page AND the faction page should agree). Flag
conflicts for manual investigation.

### P99 wiki access from remote sessions

`wiki.project1999.com` is blocked from remote Claude Code sessions.
**Mitigation:** All wiki data must be pre-fetched from a local session
or the existing cache. The parser scripts and reference tables are
designed to hold the data independently of live wiki access.

---

## Environment and Tools

- **Database:** MariaDB, managed via HeidiSQL (local Windows)
- **MCP:** `straps-eq/eqemu-mcp-server` — read-only SQL access
- **Wiki cache:** `C:\Repository\p99-wiki-cache\` (local Windows)
- **Parser:** `C:\Repository\p99-wiki-cache\parse_npcs.py` (existing)
- **New parser:** `scripts/parse_faction_data.py` (committed with this roadmap)
- **SQL scripts:** `scripts/` directory (gitignored until applied)
- **Applied scripts:** `scripts/Applied/` subdirectory

---

## Quick Start for a New Session

If you are picking this up with no prior context:

1. Read this document in full.
2. Read `docs/decisions/ADR-025_FACTION_RECONCILIATION.md` for the
   decision record.
3. Check the Progress Tracking section above for current status.
4. Check whether the EQEmu MCP is connected (try
   `mcp__eqemu__run_query` with `SELECT 1`).
5. Check whether P99 wiki is accessible (try `curl -s
   "https://wiki.project1999.com/index.php?title=Faction&action=raw"
   | head -5`).
6. Resume at the earliest incomplete phase.
7. After making progress, update the Progress Tracking section and
   commit.

### Key files to read for full context

- `PROJECT_STATUS.md` — current project state
- `docs/decisions/ADR-010_FACTION.md` — tier boundaries (already done)
- `docs/decisions/ADR-017_NAMED_NPC_LOOT_RECONCILIATION.md` — pattern
  for how reconciliation migrations are structured
- `docs/research/HISTORICAL_SOURCES.md` — source hierarchy and access
  methods
- `docs/research/GAME_MECHANICS_REFERENCE.md` — faction tier conflict
  note (still open)
