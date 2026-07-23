# ADR-003: NPC Combat Stat Tuning (PEQ vs TAKP)

**Status:** Accepted (implementation pending MCP connection)
**Date:** 2026-07-23

---

## Context

A field-level comparison of `npc_types` was performed between the
imported PEQ database and the TAKP Reference database, scoped to NPCs
whose spawns occur exclusively in Classic, Kunark, or Velious zones
(per the mapping established in ADR-001).

### Scope Definition

- **Population:** 16,950 NPCs whose spawn groups map only to zones
  with `zone.expansion <= 2`. NPCs spawning in any post-Velious zone
  are excluded from this ADR entirely.
- **Exclusions within that population:** `#`-prefixed special/GM NPCs,
  and any NPC with an `hp` value above 500,000 (sentinel/placeholder
  values, not real combat stats). Both are counted separately and
  excluded from all statistics and adoption decisions below.
- **Identity check:** of NPCs sharing an ID between the two databases,
  100% share the same `name` field, confirming these are the same
  creatures with retuned stats, not mismatched or reassigned IDs.

### External Corroboration

The TAKP file's original author, in an accompanying note, states their
own edit methodology: *stronger-in-TAKP mob stats were adopted;
stronger-or-equal-in-PEQ stats were left unchanged.* This exactly
matches what the data-only comparison independently found — 100% of
differing values favor TAKP, with zero counterexamples across every
stat examined. This is treated as **community/self-reported
corroboration**, not independent verification, per the project's
research evidence hierarchy — but the match between an independently
run comparison and the author's stated method is a meaningful
consistency check.

---

## Decisions

### HP / Damage / AC — Adopt TAKP

| Stat | NPCs differing (scoped) | TAKP higher | Median ratio |
|---|---|---|---|
| `hp` | 4,430 | 100% | 1.20× |
| `maxdmg` | 1,992 | 100% | 1.09× |
| `AC` | 214 | 100% | 1.32× |

Full TAKP value adopted for every NPC in scope where a difference
exists. `mindmg` and `attack_speed` showed negligible/no differences
and are left as-is.

### Resist Rates & HP Regen — Adopt TAKP

| Stat | NPCs differing (scoped) | TAKP higher | Median ratio |
|---|---|---|---|
| `hp_regen_rate` | 12,403 | 100% | 43.75× |
| `MR` | 11,573 | 100% | 2.92× |
| `CR` | 11,901 | 100% | 2.92× |
| `FR` | 11,846 | 100% | 2.92× |
| `DR` | 11,765 | 100% | 2.50× |
| `PR` | 11,755 | 100% | 2.50× |

Full TAKP value adopted. `hp_regen_per_second`, `mana_regen_rate`, and
`PhR` (Physical resist) showed zero differences and are unaffected.

**Note on magnitude:** PEQ resists scale slowly with level (roughly
2 → 8 → 12 → 16 → 24 across levels 4-58); TAKP resists reach 25-35 by
level 20-40 and plateau, with isolated named-mob outliers reaching
much higher (treated as intentional CC-resistant boss-tier design, not
scaling error). `hp_regen_rate` follows the same pattern at far larger
ratios, since PEQ's baseline sits at 0-1 for most NPCs regardless of
level.

### Aggro Radius — Custom (Per-NPC Midpoint)

| Stat | NPCs differing (scoped) | TAKP higher | Median ratio |
|---|---|---|---|
| `aggroradius` | 1,132 | 100% | 1.33× (range: 1.07×–10×) |

**Not a straight adopt.** TAKP's full values are the one stat directly
in tension with this server's multibox-based group content — a human
group can react to an accidental add faster than one person managing
six clients can. A flat scalar was also rejected, since a single
multiplier would overcorrect NPCs TAKP barely touched and undercorrect
the handful of extreme outliers (up to 10× in TAKP).

**Method adopted:** for each NPC where aggro radius differs, the new
value is the **arithmetic midpoint** of the PEQ and TAKP values
(`(peq + takp) / 2`, rounded). This lands at a median of **1.17×** PEQ
baseline — meaningfully tighter than PEQ's current looseness (so
careless positioning is still punished), well short of TAKP's full
widening (so simultaneous multi-client adds aren't the default
outcome), and scales naturally per-NPC rather than via a blanket rule.

Example outcomes:

| NPC | Level | PEQ | TAKP | Adopted (midpoint) |
|---|---|---|---|---|
| Guard Walorinags | 13 | 70 | 75 | 72 |
| a fallen noble | 28 | 55 | 60 | 58 |
| a suit of sentient armor | 46 | 75 | 100 | 88 |
| a sandbar serpent | 14 | 35 | 60 | 48 |
| Grenn | 61 | 50 | 100 | 75 |

---

## Deferred: Pet Stats

The TAKP author specifically claims mage pets (and pets generally,
levels 1-50) were "manually tuned" to be less overpowered. The `pets`
linkage table (type → NPC template, `petpower`) was checked and is
**byte-identical** between PEQ and TAKP across all 424 rows — the
claimed tuning is not reflected there.

Standard EQEmu summoned pets (mage/necro/druid/shaman) are generally
derived from pet-summoning spell effects rather than fixed `npc_types`
rows per level, so verifying this claim requires a `spells_new`
comparison of pet-summon spell effects — a distinct investigation from
this ADR's `npc_types` scope.

**Decision: deferred.** This does not block adoption of the stat
changes above. Revisit as a follow-on investigation.

---

## Consequences

- Roughly 16,950 NPCs are in scope; the majority receive no changes
  (only NPCs with an actual PEQ/TAKP difference are touched).
- This is a substantial data migration (thousands of row-level
  updates across ten columns), not a rule or config change — it
  requires a generated SQL script, not hand-written statements.
- Encounter difficulty for Velious-and-earlier content increases
  meaningfully and consistently: tougher mobs, better mob self-healing,
  and much stronger resists against player CC/DoTs.
- Aggro radius increases moderately rather than matching TAKP's full
  widening, in recognition of the multibox playstyle this server is
  built around.
- Pet balance remains at PEQ defaults until the deferred spell-level
  investigation is completed.

## Spire Compatibility

No schema changes. All affected columns (`hp`, `maxdmg`, `AC`,
`aggroradius`, `MR`, `CR`, `DR`, `FR`, `PR`, `hp_regen_rate`) are
standard PEQ `npc_types` columns. This is a data update, not a
structural change — Spire's NPC editor will display and allow further
editing of the new values exactly as it does the current ones.

## Implementation Status

**Not implemented.** No database changes have been made. Implementation
requires a generated SQL script (row-level, scoped to the ~16,950 NPCs
identified above) and will be applied directly against the live Angels
Misfits database once EQEmu MCP is connected, following the project's
backup and rollback process. Given the scale, a spot-check validation
pass against a sample of updated NPCs is recommended before the full
script is committed to the live database.