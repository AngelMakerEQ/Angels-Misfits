# NPC Reconciliation Process

**Status:** Active. Rewritten from scratch 2026-08-10 — this document
carries no prior zone-by-zone progress state, phase ordering, or task
checklist forward from any earlier iteration of this work. Treat this as
the starting point, not a continuation.

## What this is

Angels Misfits' Classic-through-Velious NPC population is checked against
`wiki.project1999.com` (the project's primary era-accuracy reference — see
`docs/architecture/DESIGN_PHILOSOPHY.md`'s historical source priority) using
a structured tool built directly from that wiki's local cache, rather than
by reading raw wiki pages by hand per zone. Confirmed discrepancies get
their resolved value recorded directly in a staging table (see below).
**No SQL is applied to the live game database as part of this process** —
turning the staging table into an actual migration is a separate, later
step, once its contents are reviewed.

Scope is Classic, Kunark, and Velious only — the three expansions this
server currently targets. This process does not expand to cover later
expansions; P99's own wiki doesn't document anything past Velious anyway,
so there would be no source data to work from even if it did. Out-of-era
NPCs are only ever tagged when they're incidentally encountered while
reviewing something in-scope (rule 8) — they are never a target of active
review in their own right.

## The Tool

- **`p99_reference_npcs`** (MariaDB table, 6,442 rows) — one row per
  `{{Namedmobpage}}` wiki page, parsed from the local wiki cache via
  `C:\Repository\p99-wiki-cache\parse_npcs.py`. Columns: `emu_id` (the
  wiki's own anchor into `npc_types.id`), `npc_name`, `race`, `class_raw`,
  `level`, `agro_radius`, `run_speed`, `zone_raw`, `location`,
  `respawn_time`, `ac`, `hp`, `hp_regen`, `mana_regen`,
  `attacks_per_round`, `attack_speed`, `damage_per_hit`, `special`,
  `description`, `known_loot`, `common_loot`, `factions`,
  `opposing_factions`, `related_quests`.

- **`npc_reconciliation_match`** (view) — for every wiki page with a
  resolvable `emu_id`, finds every live `npc_types.id` sharing that exact
  `name`, scoped to `COALESCE(spawn2.version, 0) = 0` and
  `zone.expansion <= 2` (or NULL) — Classic/Kunark/Velious only, the
  server's actual active scope. Carries spawn coordinates
  (`live_x`/`live_y`/`live_z`/`live_heading`) and any governing
  `spawn_condition` (see below) per spawn point. Depends on an index,
  `idx_npc_types_name` (added 2026-08-10, a prefix index on
  `npc_types.name(100)`) — without it, the `name`-based join is a full
  65k-row table scan per anchor and queries against this view or `diff`
  can take minutes instead of seconds. If this index is ever missing
  (dropped, or a schema restore), re-add it before relying on either view
  for anything beyond a single narrowly-filtered lookup.

- **`npc_reconciliation_diff`** (view) — joins the match view to live
  `npc_types` side by side with the wiki data: level, hp, ac, mindmg/maxdmg,
  runspeed (+ `wiki_run_speed_suspect`), class, bodytype, aggroradius (+
  `wiki_agro_radius_suspect`), attack speed (+ `wiki_attack_speed_suspect`),
  see_invis/see_invis_undead (+ `wiki_mentions_see_ivu`), a
  `wiki_mentions_social` flag, a `wiki_mentions_day_night` flag, respawn
  time, coordinates (`live_*` vs. raw `wiki_location_raw`), factions, loot,
  and related quests. Query it filtered to whatever scope is useful, e.g.
  `SELECT * FROM npc_reconciliation_diff WHERE zone = 'crushbone'`.

- **`npc_reconciliation_staging`** (real table, not a view) — a working
  snapshot, one row per in-scope `npc_id` (9,860 rows as of 2026-08-10),
  seeded from `diff`. This is the **only** thing this process writes to.
  For each field it has a `live_*` column (the value at snapshot time),
  a `wiki_*_raw` column (the source value/citation), and a `target_*`
  column (initially NULL) — fill in `target_*` with the confirmed correct
  value as NPCs get reviewed; leave it NULL where still unresolved. Also
  has `resolution_status` (`unresolved` / `confirmed_no_change` /
  `confirmed_needs_update` / `excluded_ambiguous`) and `resolution_notes`
  (free text — reasoning, citation detail, why a match was excluded) per
  row, and `out_of_era_sibling_checked`/`out_of_era_sibling_found`/
  `out_of_era_notes` for rule 8's incidental tagging. See "Working with
  the staging table" below for the actual field list and how it gets
  consumed later.

**`match` and `diff` are read-only SQL views — nothing ever writes to
them, and they need no maintenance.** They're auto-computed from
`p99_reference_npcs` and the live database every time they're queried, so
they're always current. `diff` is `match` with the live-vs-wiki comparison
columns joined on; in normal research use, query `diff` directly. The
staging table is different: it's a real, mutable table, deliberately
snapshotted rather than live, specifically so there's somewhere to write
resolved values without touching the live game database.

### Known limits (confirmed by direct measurement, not assumption)

- Reaches roughly 61% of the in-scope spawned NPC population (~9,860 of
  ~16,190 NPCs across ~123 of ~128 in-scope zones with any spawns) — the
  rest have no individual wiki page to match against at all (mostly
  generic trash, but some named NPCs too), not a matching failure.
- `respawn_time` is a clean structured value on only ~8% of pages — most
  respawn info is stated in body prose instead of the infobox field.
- Loot fields (`known_loot`/`common_loot`) carry raw wiki markup, not
  clean item names.
- Money/coin drops are essentially undocumented on the wiki (0.4% of
  pages) — not covered by this tool at all. For cash, compare
  `loottable.mincash`/`maxcash` directly against a real client data file
  instead, a separate task from this one.
- Coordinates: live-side is complete (`live_x`/`live_y`/`live_z`). The
  wiki side is captured as raw text only (`wiki_location_raw`, present on
  74% of pages, formatted as one or more `chance% @ (x, y)` entries) — not
  yet parsed into comparable numeric columns, since one NPC can have
  several weighted coordinate options and that needs its own table, not a
  single column. Compare by reading the raw text against `live_x`/`live_y`.
- `npc_reconciliation_inactive_notes` (real table, 558 rows) holds the
  findings target for the "NPCs P99 documents but our database doesn't
  actively use" check below — not part of the main staging workflow.
- 194 of the staging table's 9,860 rows have more than one wiki page
  pointing to the same `emu_id`, and it's a genuine mix of two different
  situations, confirmed by direct comparison, not assumed to be one or
  the other:
  - **Legitimate shared template.** Multiple distinct named/zone-flavor
    wiki pages that agree closely with each other — e.g. `emu_id 12016`
    ("A bandit"), where 5 of 6 pages report the same level/hp/ac. This is
    a real, common classic-EQ pattern: one stat template genuinely reused
    across many spawns. Not an error.
  - **Wiki tagging inconsistency.** Multiple wiki pages describing
    genuinely different NPCs (different levels, HP, AC) that can't
    legitimately share one live template — e.g. `emu_id 4149`, where the
    7 pages range from level 7 to level 38. Here the seed's arbitrary
    pick (alphabetically first title) has no principled basis; check
    every page sharing the id (`SELECT * FROM p99_reference_npcs WHERE
    emu_id = <npc_id>`), not just what got seeded.
  - **Either way, also check whether the live `npc_types` row actually
    matches any of the candidate pages at all** — it may not. In the
    `12016` example, none of the wiki pages' `level`/`AC` match what's
    currently live (`level=12`/`AC=40` live vs. `level=9`/`AC=97` on 5 of
    6 pages), even though the shared-template pages agree with each
    other. That mismatch is itself a real finding worth recording,
    independent of which wiki page "wins."
- `zone.expansion` is not fully reliable on its own — at least one zone
  (`citymist`) has two rows both tagged the same `expansion` value despite
  one being a genuinely much later revamp (identified via its `note`
  field, not `expansion`). Cross-check a zone's `note` field and the FV
  Project's Historical Zone Release/Revamp Timeline
  (`docs/research/HISTORICAL_SOURCES.md`) when era-scoping looks
  ambiguous, don't trust `expansion` alone.

### What this tool does not do, and never should be trusted to do alone

Confirm that a name-based match is actually the same NPC the wiki source
describes. It matches on the database's own `name` column, not on anything
the wiki text asserts — a shared name is a candidate, not a confirmed fact.
Concrete proof: a `southro` (South Desert of Ro) NPC named `a_spectre`
matched the "A Spectre" wiki page by name alone, even though that page's
text never mentions Southern Desert of Ro anywhere — a same-named NPC in a
genuinely in-scope zone the wiki never mentions would sail through
undetected just as easily. Every match still needs the judgment call
described in the working rules below.

## NPCs P99 documents but our database doesn't actively use

**Sequencing: this check happens after the main `npc_reconciliation_staging`
pass is complete, not concurrently with it.** The main pass (reconciling
the ~9,860 active NPCs) is the priority; treat this section as a follow-on
project once that finishes, not a second parallel workstream to interleave
with it NPC-by-NPC.

Everything above compares our *active* population against the wiki. This
is the opposite direction: P99-documented NPCs that don't show up as an
active, in-scope spawn in our database at all — a distinct, separate check,
not a stat-reconciliation task. **Important framing before treating any of
these as a bug: P99's own wiki spans the entire Classic-through-Velious
timeline, not one frozen point in it — a page can describe an NPC that was
legitimately superseded or removed partway through that range by a later
patch. Our database is one specific snapshot (closer to a Velious-era
end-state). "Inactive in our snapshot" is not automatically "wrong" or
"missing" — it needs actual triage, not an assumption either way.**

Two views cover the two distinct sub-cases (confirmed counts as of
2026-08-10):

- **`npc_reconciliation_missing_npc_ids`** (77 rows) — the wiki's `emu_id`
  for this page doesn't match any `npc_types.id` in our database at all.
  Includes `same_name_row_count`/`same_name_sample_npc_id` — a same-named
  row existing under a *different* id is a plausible lead that the wiki's
  `emu_id` is simply stale (this database's import renumbered the
  template at some point), worth checking first before concluding the NPC
  is genuinely absent. **Treat this with the same caution as every other
  name-based signal in this document (rule 6, "what this tool does not do
  above") — a shared name is still not proof of shared identity, just a
  cheaper place to start looking than nothing.** Zero same-name matches
  is a weak lean toward an actual content gap, not proof either — the
  NPC's name could have changed entirely. Also note the name-normalization
  here is simple (lowercase, trim, spaces→underscores) and won't catch
  every real match — a name differing by punctuation (apostrophes,
  hyphens) could show 0 matches despite a real same-name row existing.
- **`npc_reconciliation_dormant_npcs`** (481 rows) — the `emu_id` matches
  a real `npc_types.id`, but it has no active, in-scope spawn point
  (`COALESCE(spawn2.version,0)=0`, in-scope zone). Includes
  `any_spawnentry_count`/`any_spawn_zones`/`any_spawn_versions`/
  `content_flags_present` — spawn wiring that exists but only outside the
  active version/zone scope. **Confirmed triage signal, not a guess:** of
  the 481, 221 have wiring with a nonzero `any_spawn_versions` value —
  the same pattern already found on `citymist` (a real zone-revamp
  version pair, not a bug) — meaning these most likely belong to an
  alternate zone-layout version, not a genuine gap. The remaining **260
  have zero spawn wiring in any version or any zone whatsoever** — no
  version-based explanation available, making this the actual
  priority bucket worth investigating first, since "it's just on a
  different zone version" doesn't apply to any of them.

Treat this as a distinct check from the main staging-table process, not a
field to add to it — resolving "why is this inactive" often means reading
the actual wiki page's history/description text, not comparing structured
field values, and there's no active `npc_id` row to attach a comparison
to for the 77 missing-id cases at all. Record findings in
**`npc_reconciliation_inactive_notes`** (real table, seeded with 558 rows
— one per wiki page from either view, keyed by `wiki_title`,
`case_type` pre-filled). Set `resolution_status` to
`confirmed_gap` (genuinely missing/should be investigated for restoring),
`confirmed_superseded_in_range` (a real classic-era NPC that was
legitimately removed/replaced within P99's own Classic-through-Velious
coverage, per the framing above — not a bug), `confirmed_stale_wiki_id`
(the `emu_id` is simply wrong/outdated, the NPC likely exists under a
different id), or `confirmed_alternate_zone_version` (the 221-row case —
real wiring, just on a non-active `spawn2.version`). Use `resolution_notes`
for the reasoning and citation, same pattern as the staging table.

## Day/night and other conditional spawns

EQEmu represents this via a generic named-condition system, not a
`day`/`night` column — `spawn2` has `_condition`/`cond_value`, tied to the
`spawn_conditions` table (confirmed real and actively used: 4,014 spawn2
rows reference a non-zero condition; e.g. `commons` has `CommonsDayMobs`/
`CommonsNightMobs`, and the pattern repeats across many zones —
`QeynosHillDay`, `KithicorDay`, etc.). `npc_reconciliation_match`/`_diff`
surface this as `spawn_condition`/`spawn_condition_value` — a non-NULL
value means that spawn point only counts when the named condition equals
that value, which matters when reasoning about whether two NPCs at the
same zone are actually concurrent. The wiki documents this only as prose,
almost never a structured field (`wiki_mentions_day_night` catches the
~0.2% of pages that mention it at all).

## Staging table precompute (rules 5 and 8)

`npc_reconciliation_staging_precompute.sql` (same directory as this doc)
bulk-precomputes the two purely mechanical, no-judgment lookups rules 5
and 8 otherwise ask for one NPC at a time: level-variant sibling
candidates (rule 5, into `level_variant_sibling_ids`/
`level_variant_siblings_checked`) and the out-of-era same-name sibling
check (rule 8, into the existing `out_of_era_sibling_*` columns). Same
computation, run once for the whole remaining table instead of once per
NPC during review — it does not change what gets decided per row, only
removes redundant repeated queries for a fact that doesn't change
per-row. Guarded to only touch not-yet-checked rows, so it's safe to
re-run after a reseed. Validated against live data before being written
(see the script's own header) — still spot-check a handful of rows
against a manual query after running, per `TESTING.md`.

**Once run:** read `level_variant_sibling_ids` and `out_of_era_sibling_*`
directly off the staging row instead of re-running rules 5/8's queries
by hand — the candidate list is already there. The judgment calls in
rules 5 and 8 (what to do with a sibling, whether to flag it) are
unchanged and still happen per-row.

## Working rules

1. Query `npc_reconciliation_diff` first for any NPC/zone question — this
   is the primary research step, ahead of reading raw wiki pages by hand.
   Only fall back to the local wiki archive directly
   (`C:\Users\Jatyr\AppData\Local\Microsoft\WindowsApps\python.exe`,
   invoked explicitly) for NPCs the diff view doesn't cover, or fields it
   doesn't capture. P99 is the acceptance authority regardless of which
   path finds the data.
2. A template is not resolved once one field matches — check the *full*
   field set a source actually documents:
   - Combat: `hp`, `mana`, `mindmg`, `maxdmg`, `AC`, `attack_delay`/
     `attack_speed`, `attack_count`.
   - Movement: `runspeed`, `walkspeed`.
   - Identity/AI: `class` (affects skill caps and casting AI, not
     cosmetic), `bodytype`, `race`.
   - Detection: `see_invis`, `see_invis_undead`, `see_hide`,
     `see_improved_hide`.
   - Resists: `MR`, `CR`, `FR`, `PR`, `DR` (and `Corrup`/`PhR` where
     sourced).
   - `aggroradius`, `assistradius` (real EQEmu field — social/assist
     aggro — but wiki coverage for it is extremely sparse, ~0.1% of
     pages, almost always loose prose rather than a number; expect no
     sourced answer for most NPCs, that's a data-availability limit, not
     a reason to skip checking).
   - Coordinates and spawn timing (`spawn2.respawntime`/`variance`) — a
     source may state a different respawn time per zone for the same NPC
     family; never reuse one zone's value for another. Before flagging a
     spawn point's `respawntime` as wrong, confirm via `spawnentry` that
     the spawn point is exclusive to the template(s) in question — a
     shared spawn point also used by unrelated NPCs is a different
     situation.
   - Signature spell/ability setup: check the assigned `npc_spells_id`
     row's *entire* configuration, not just its `npc_spells_entries` rows
     — also check `parent_list` inheritance and the
     `attack_proc`/`defensive_proc`/`range_proc` fields on the
     `npc_spells` row itself. A spell list with no direct entries can
     still be fully and correctly wired through its parent list or a
     proc field; verify before concluding something is missing, and
     equally, before concluding something is present.
   - Faction, loot (per rule 4), related quests.
3. **A blank structured field is not the same as "no data."** Check the
   wiki page's free-text `special` and `description` fields for the
   answer stated in prose before concluding a field has no source —
   confirmed to happen regularly: respawn timing, day/night restrictions,
   and detection abilities (See Invis vs. Undead) have all been found
   stated only in prose on pages where the matching structured field was
   empty. The diff view's `wiki_mentions_*` flags catch the cases found so
   far; for anything else, read the raw text directly.
4. **Outlier and suspect-value validation.** Never treat a wiki-sourced
   numeric-ish value as ground truth just because it parsed — sanity-check
   it against the field's normal range first. Confirmed real problem: 30+
   wiki pages state `run_speed` as "250" or "300" (percentage notation
   bleeding into a field everywhere else uses decimal-multiplier notation
   — treating one of these as real would make an NPC run ~200x too fast),
   and hundreds of pages have literal `?`/`??`/`???`/`normal` sitting in
   what should be numeric fields. `wiki_run_speed_suspect`/
   `wiki_agro_radius_suspect`/`wiki_attack_speed_suspect` flag known cases.
   **A `true` flag can mean either "the value looks wrong" or "there's no
   value at all"** — check the raw `*_raw` column to tell which; missing
   and implausible-but-present need different handling. Apply the same
   suspicion to any field the tool doesn't flag yet: a value far outside
   what similar NPCs show is a signal to verify against the raw wiki page,
   not something to record as-is.
5. **Level-variant siblings.** Before treating any NPC template as
   resolved, query every `npc_types` row sharing its exact `name` within
   the zone in scope. A source that documents one representative stat
   block for a level range (as P99's wiki commonly does, via a single
   `emu_id` reference) applies to — or must be explicitly and deliberately
   excluded with a stated reason from — every sibling level-variant row,
   not just the one the source's ID happens to reference. Record the
   decision either way.
6. **Zone variants.** The same NPC name can appear as separate `npc_types`
   rows in multiple zones. A finding in one zone never applies to a
   same-named row in a different zone without its own independent check.
   Every finding must be scoped to specific `npc_types.id` values, never a
   bare name.
7. Treat loot differences as leads, not conclusions. Before recording a
   loot discrepancy as confirmed, check quest hand-ins, quest rewards,
   event handlers, scripted/proc rewards, shared lootdrop consumers, item
   era, and full group/probability context.
8. **When an in-scope NPC's name also turns up in an out-of-era zone,
   tag it — but this is incidental to reviewing the in-scope NPC, not a
   reason to go review the out-of-era zone itself.** `npc_reconciliation_match`/`_diff`
   are scoped to Classic/Kunark/Velious only (rule stays consistent with
   the tool's actual scope, see "What this is" above) — they will not
   surface an out-of-era match on their own. To check whether the NPC
   currently being reviewed also has a same-named presence elsewhere, run
   a targeted lookup:
   ```sql
   SELECT nt2.id, s22.zone, z2.long_name, z2.expansion
   FROM npc_types nt2
   JOIN spawnentry se2 ON se2.npcID = nt2.id
   JOIN spawn2 s22 ON s22.spawngroupID = se2.spawngroupID
   JOIN zone z2 ON z2.short_name = s22.zone
   WHERE nt2.name = REPLACE_WITH_THE_NPCS_NAME  -- e.g. a_spectre; substitute the literal value quoted, don't paste this token as-is
     AND COALESCE(s22.version, 0) = 0
     AND NOT (z2.expansion IS NULL OR z2.expansion <= 2);
   ```
   If it returns rows, record `out_of_era_sibling_found = 1` on the
   staging table row with a one-line note (which zone(s), which
   expansion) — this is purely a "don't assume these are related" flag
   for later content-flagging work, not a request for P99-sourced target
   values for the out-of-era rows (P99 doesn't cover anything past
   Velious, so there's no source data to record for them regardless).
   Set `out_of_era_sibling_checked = 1` either way once checked, even
   when the answer is "no sibling found" — the point is a complete
   record of what was checked, not just the positive hits.
9. **An NPC inside an in-scope zone is not automatically in-scope itself.**
   `match`/`diff`'s zone-level filtering (`zone.expansion <= 2`) handles
   whole-zone era-scoping, but a specific NPC or `spawnentry` can still be
   later-era content layered into an otherwise in-scope zone — ADR-018's
   Phase 1 already found and gated 27 such Fabled `spawnentry` rows this
   way. So: do not treat a nonzero NPC level, a high item ID, a nonempty
   later-expansion field, or a nonzero `spawnentry`/`loottable`
   `min_expansion`/`max_expansion` as sufficient evidence *either way* by
   itself — a level above 60 can be correct Velious-era encounter tuning,
   and a populated `min_expansion` field doesn't automatically mean
   something is out of scope. A later release needs a dated historical
   source or a specific expansion/event identity before anything is
   treated as out of scope, the same evidentiary bar as everywhere else
   in this document.
10. Never apply SQL to the live game database as part of this process.
    The output is a populated staging-table row — nothing more. `arena`,
    `cshome`, `shadowrest`, tutorial zones, Jaggedpine, Nedaria's Landing,
    Stonebrunt, and The Warrens are not part of the target-era population
    (utility/non-world zones) — finding zero matches there is expected,
    not a gap.

## Working with the staging table

`npc_reconciliation_staging` holds one row per in-scope NPC (9,860 rows,
seeded 2026-08-10). Field groups, mirroring `diff`: level, hp, ac,
mindmg/maxdmg, runspeed, class, bodytype, aggroradius, and
see_invis_undead each have a `live_*` (snapshot value), `wiki_*_raw`
(source), and `target_*` (fill this in) column. Loot/faction/quest/
coordinate/respawn fields are **not** in the staging table yet — those
stay in `diff` only for now (see "Known limits"); add columns for them if
and when that becomes the actual bottleneck, don't build it preemptively.

**A confirmed finding for one of those non-tabular fields still needs
somewhere to go.** Every reviewed in-scope NPC already has exactly one
staging row (keyed by `npc_id`) regardless of which fields it has
dedicated columns for — record a confirmed loot/faction/quest/coordinate/
respawn finding as a line in that same row's `resolution_notes` (live
value, sourced target, citation, same as the tabular fields get via their
`target_*` columns, just as text instead of a column). Don't invent a
separate document for this — the whole point of consolidating onto one
row per NPC is that there's always a home for a finding regardless of
which field it's about.

As each NPC is reviewed:
- Set `target_*` to the confirmed correct value for every field that has
  one — including fields that already match (`target_hp` = `live_hp` is a
  normal, expected outcome, not something to leave NULL just because
  nothing needs to change).
- Set `resolution_status`: `confirmed_no_change` if everything checked out
  as-is, `confirmed_needs_update` if any `target_*` differs from the
  matching `live_*`, `excluded_ambiguous` if the match itself couldn't be
  trusted (rules 5/6) and nothing should be recorded as a real finding.
- Use `resolution_notes` for anything a future reader would need —
  citation specifics, why a level-variant sibling was excluded, why a
  suspect-flagged value was or wasn't trusted.
- Fill in the `out_of_era_sibling_*` columns per rule 8.

Leave a field's `target_*` NULL when it's genuinely still unresolved
(need more research, an ambiguous case not yet decided) — NULL is the
"not done yet" signal the final consolidation step (below) depends on.

## What happens to the staging table

This process's job ends at a fully (or as-fully-as-possible) populated
staging table — it does not write to the live game database itself
(rule 10). Turning it into an actual migration is a separate, later,
explicitly-requested step, following this project's normal process
(`docs/development/CODING_STANDARDS.md`'s SQL Migration Convention):
generate one consolidated `UPDATE` per field from every row where
`target_* IS NOT NULL AND target_* <> live_*` (skip no-op rows where the
target matches what was already there), guarded by
`WHERE npc_types.id = staging.npc_id AND npc_types.<field> = staging.live_*`
— the same guarded-by-observed-old-value pattern every other migration in
this project already uses, generated from the table instead of
hand-written, and accounting for the live database possibly having
changed since the snapshot was taken. Apply via the EQEmu MCP, verify per
`TESTING.md`, move the resulting script to `scripts/Applied/`. Once a row
has been applied and verified, mark it (e.g. append `[APPLIED: <script
filename>]` to `resolution_notes`) rather than deleting the row — the
table stays a complete record of what was found *and* what was done
about it.

`out_of_era_sibling_found` rows don't resolve the same way — they're
tagging for later content-flagging work (a separate task), not a queue
of pending stat fixes. They stay as-is once checked; that's the intended
end state for those rows, not an unfinished one.

## Findings log

### 2026-08-11 â€” High Keep through Freeport checkpoint (NPC IDs 6,181â€“10,199)

The active staging pass has advanced in ascending `npc_id` order through
10,199. In this interval, 218 rows were resolved: 186
`confirmed_needs_update`, 8 `confirmed_no_change`, and 24
`excluded_ambiguous`. Every resolved row has its out-of-era same-name check
recorded; 58 found an active later-expansion sibling and were flagged only
for later content-flagging work. No live game database SQL was applied.

The completed portion covers the remaining High Keep rows and the active
North, West, and East Freeport populations. Repeated, source-backed findings
include substantially under-tuned guards and Freeport guildmasters, routinely
incorrect AC/run-speed values, and class mismatches. The P99 cache also
contains a number of stale or overloaded `emu_id` references: some pages
point to a later-expansion sibling, some map two unrelated pages to one ID,
and several names have documented level-specific variants. The staging notes
record the per-row decision in each case.

Level variants without an exact documented profile were deliberately marked
`excluded_ambiguous`, rather than inheriting values from a different-level
sibling. Examples include additional East Freeport variants of guards,
Jyle Windshot, Zenita D`Rin, Orc Centurion, A Shark, and several named
residents. Conversely, same-level or explicitly documented zone variants
were reconciled from their source profile. Generic pages with a documented
matching profile (for example rats, rodents, fire beetles, wolves, and the
Priest of Discord) were used only where the active row matched that profile.

No new ambiguity category or contradiction with an Accepted ADR or applied
migration was found in this interval. The inactive-NPC follow-on table has
not been started.

## Continuous operation

Work through the population continuously, without pausing to ask
permission between NPCs or zones. **Stop and ask the user specifically
when:**
- A candidate match cannot be resolved by the rules above (exclusion
  check, level-variant fan-out) and looks like a genuinely new category
  of ambiguity — not just "record it and continue," something that might
  need a policy call (e.g. whether to trust a source at all).
- A finding contradicts an already-Accepted ADR or an already-applied
  migration, rather than merely extending one.

The two conditions above are genuine stops: pause and wait for a response
before continuing.

**Processing order:** work `npc_reconciliation_staging` rows in ascending
`npc_id` order — simple, deterministic, and matches the table's own
primary key, so there's no ambiguity about what's already been covered or
what comes next. To find where to resume:
```sql
SELECT npc_id FROM npc_reconciliation_staging
WHERE resolution_status = 'unresolved' ORDER BY npc_id LIMIT 1;
```

**Separately, check in after roughly every 1,000 NPCs processed** (not
per-zone — zones range from a handful of NPCs to hundreds, so tying the
checkpoint to zone count alone produces far too many check-ins across the
reachable population; a fixed count spaces this out far more evenly,
landing somewhere around 10 check-ins total for the full 9,860-row
population). Summarize what changed in the staging table since the last
check-in (rows moved to each `resolution_status`, anything notable,
current `npc_id` position for resumability). This is a status update, not
a stop: keep going immediately afterward unless one of the two conditions
above actually applies. Do not wait for acknowledgment before continuing.

**Do not stop for:** routine field mismatches with a clear, sourced target
value; ordinary level-variant siblings once the anchor is confirmed;
routine exclusion checks; moving from one NPC or zone to the next; the
periodic check-in itself.
