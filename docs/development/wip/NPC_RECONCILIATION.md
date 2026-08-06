# P99 NPC Reconciliation: Fresh-Agent Handoff

## Objective

Build a repeatable, evidence-backed reconciliation process so ordinary NPCs
spawned in Classic, Kunark, and Velious zones align with P99 wiki records
where P99 records are available. Work against the live `angelsmisfits`
MariaDB through the **read-only EQEmu MCP** first. Do not modify the database
until findings have been reviewed and an explicit migration is requested.

This is not a request for a one-time, blanket `UPDATE npc_types` operation.
The desired outcome is an auditable pipeline that identifies, classifies,
and safely fixes deviations over time.

## Project Context and Constraints

- Target eras: Classic (expansion 0), Kunark (1), and Velious (2).
- Project intent: retain deliberate solo-server deviations, but distinguish
  them from unintended era drift.
- P99 wiki is the preferred acceptance reference for era inclusion, known
  loot, and explicitly documented NPC statistics.
- P99 pages are incomplete for many fields. Do not infer an exact historical
  value when the page does not supply one.
- Do not treat present-day Live EverQuest sites as classic evidence.
- Do not expose database credentials in output, commits, or documents.
- Produce read-only reports and reviewable SQL. Never apply SQL without an
  explicit user request.

## Required Tools and First Checks

The global Codex MCP configuration contains an `eqemu` server with
`EQEMU_ACCESS_MODE = read`. Confirm it is callable before analysis:

1. Run `list_tables` or `get_server_config` through `mcp__eqemu__`.
2. Run one harmless `SELECT` through `mcp__eqemu__run_query`.
3. Confirm the DB is `angelsmisfits` without printing credentials.
4. Use web research for P99 wiki pages and cite the individual page beside
   each comparison.

Useful EQEmu MCP tools:

- `search_zones`, `get_zone_spawns`, `search_npcs`, `get_npc`
- `run_query` (read-only SQL; use it for all bulk analysis)
- `describe_table`
- `get_npc_loot` is currently broken against this schema: it queries the
  nonexistent `lootdrop_entries.min_amount` column. Use direct joins instead.

Correct current loot-table columns:

- `loottable_entries`: `loottable_id`, `lootdrop_id`, `multiplier`,
  `droplimit`, `mindrop`, `probability`
- `lootdrop_entries`: `lootdrop_id`, `item_id`, `item_charges`,
  `equip_item`, `chance`, `disabled_chance`, `trivial_min_level`,
  `trivial_max_level`, `multiplier`, `npc_min_level`, `npc_max_level`,
  `min_expansion`, `max_expansion`, `content_flags`,
  `content_flags_disabled`

## Recommended Reconciliation Design

### 1. Create a versioned reference manifest

Do not scrape P99 and immediately write SQL. Create a committed CSV/JSON
manifest (or a small set of files) keyed by:

`zone_short_name + normalized_npc_name + level/race/class + P99 page URL`

Store only fields actually supported by evidence, with a value source and
confidence:

- identity: zone, spawn context, name, level, race, class, faction
- combat: HP, min/max hit, AC, attacks per round, special flags
- spells/abilities and resist fields
- loot items, grouped-drop structure, probabilities where P99 records them
- source URL/revision/date and notes
- `intentional_deviation` flag and rationale

Use exact zone/name/level matches automatically. Send duplicate names,
placeholder swaps, scaling templates, quest spawns, and missing evidence to a
manual-review queue.

### 2. Run systemic passes before per-NPC edits

Order of work:

1. Loot-era containment.
2. Spawn population/location/respawn.
3. NPC identity and faction.
4. Combat stats and special abilities/spells.
5. Aggro/assist behavior.
6. Named, quest, and conditional-spawn NPCs.

Each pass should emit: match count, uncertain count, discrepancies, proposed
SQL, exclusions, rollback, and post-run verification queries.

### 3. Preserve deliberate deviations

Maintain an allowlist, separate from raw P99 comparisons. Existing project
documentation records intentional NPC combat tuning. A difference from P99 is
not automatically a bug: classify it as one of:

- confirmed aligned
- confirmed unintentional drift
- documented intentional deviation
- insufficient evidence
- needs project-lead decision

## Confirmed Initial Spot Check (2026-08-06)

Three ordinary recurring mobs were examined using the live DB and P99 pages.
This is evidence of likely systemic problems, not sufficient grounds for a
bulk update by itself.

### Classic: Lower Guk — `a_froglok_shin_knight` (NPC 66047)

Live values: level 27; HP 999; damage 1-58; AC 115; regen 29; aggro radius
55; no configured special ability/spell list. It occurs at eleven Lower Guk
spawn locations.

P99: level 27-31; HP 970-1084; damage 13-62; AC 275; two attacks per round;
no special abilities.

Interpretation: HP is aligned; minimum and maximum damage plus AC differ.

P99 source: https://wiki.project1999.com/A_Froglok_Shin_Knight

### Kunark: City of Mist — `greater_spurbone` (NPC 90094)

Live values: level 36; HP 2454; damage 14-85; AC 156; regen 74; aggro radius
55; `see_invis=1`; special flag `f` / special-abilities string present.

P99: level 36-40; HP 2454-2534; damage 14-94; AC 253; two attacks per round;
immune to flee and see invis.

Interpretation: HP and basic behavior are aligned; maximum damage and AC
differ.

P99 source: https://wiki.project1999.com/Greater_Spurbone

### Velious: Crystal Caverns — `a_Ry\`Gorr_watchman` (NPC 121000)

Live values: level 29; HP 1580; damage 11-62; AC 131; regen 48; aggro radius
55; no configured spell/special ability list. Eight spawn locations.

P99: level 29-31; HP 1131; damage 11-58; AC 259; two attacks per round; no
special ability.

Interpretation: HP is about 40% above P99, maximum damage is above P99, and
AC is below P99.

P99 source: https://wiki.project1999.com/A_Ry%60Gorr_watchman

### Confirmed systemic loot-era-containment issue

All three sampled ordinary NPCs include a large generic lootdrop at 100%
table probability in addition to legitimate era loot:

- NPC 66047: lootdrops 155138 (60 items; 35 high-ID items) and 155139
- NPC 90094: lootdrops 159294 (34 items; 6 high-ID items) and 159295
- NPC 121000: lootdrops 129680 (47 items; 23 high-ID items) and 129681

Observed examples include Raw Nihilite, Froglok Egg Capsule, Pliant Loam,
Spinneret Fluid, Regurgitated Crystals, and other later-era items. These are
reachable from ordinary era mobs and therefore violate strict era containment.
Legitimate items coexist in the same chains (for example, Bottle of Karsin
Acid and Shimmering Velium Ruby on the Ry`Gorr watchman).

Do not delete generic lootdrops wholesale. First inventory every reachable
lootdrop, classify each item by first expansion, then clone/split shared pools
or populate existing expansion guards so each target era receives only its
allowed items. Test the resulting drop-chain cardinality and probabilities.

P99 confirms expected Crystal Caverns watchman items including Bottle of
Karsin Acid, Shimmering Velium Ruby, Frozen weapons, gems, and classic spell
research items:

- https://wiki.project1999.com/A_Ry%60Gorr_watchman
- https://wiki.project1999.com/Bottle_of_Karsin_Acid
- https://wiki.project1999.com/Shimmering_Velium_Ruby

## Query Pattern for Direct Loot Inspection

Use this pattern, adapted to a sample or an entire zone. Keep output bounded.

```sql
SELECT
  n.id, n.name, n.level, n.hp, n.hp_regen_rate, n.mindmg, n.maxdmg,
  n.AC, n.MR, n.CR, n.DR, n.FR, n.PR, n.aggroradius, n.assistradius,
  n.special_abilities, n.npc_spells_id, n.loottable_id,
  lte.lootdrop_id, lte.probability AS lootdrop_probability,
  lde.item_id, i.Name AS item_name, lde.chance AS item_chance,
  lde.min_expansion, lde.max_expansion
FROM npc_types n
LEFT JOIN loottable_entries lte ON lte.loottable_id = n.loottable_id
LEFT JOIN lootdrop_entries lde ON lde.lootdrop_id = lte.lootdrop_id
LEFT JOIN items i ON i.id = lde.item_id
WHERE n.id IN (...)
ORDER BY n.id, lte.lootdrop_id, lde.chance DESC;
```

## Verification Standard

Before proposing an update:

- Preserve the original values and source references in a migration manifest.
- Ensure a change is matched to the correct template and spawn context.
- Verify an item is truly out of era, rather than merely using a high ID.
- Inspect shared lootdrop reuse before editing; one pool can affect unrelated
  zones/eras.
- Include exclusion queries and zero-result checks for removed content.
- Use live post-run queries and in-game sampling after any approved change.
- Do not claim historical accuracy for aggro/assist radius without a
  field-specific source; P99 NPC pages usually do not publish that value.

## First Deliverables

1. Era-zone NPC/loot dependency inventory and shared-lootdrop reuse report.
2. Item-era classification manifest and a list of reachable post-Velious
   drops, ranked by number of affected NPC templates/spawns.
3. P99 matching coverage report: automatic matches, uncertain matches, and
   no-reference rows.
4. First review package for one zone per era, with no database write.
5. Only after approval: small, reversible SQL migrations with rollback and
   explicit post-run validation.
