# ADR-005: Pet NPC Stat Tuning

**Status:** Accepted — Implemented
**Date:** 2026-07-23

---

## Context

The TAKP author's note specifically claimed pet stats (particularly
mage pets, levels 1-50) were "manually tuned" to be less overpowered.
This was deferred in ADR-003 because the `pets` linkage table (type →
NPC template, `petpower`) was found to be byte-identical between PEQ
and TAKP, and the claimed tuning wasn't reflected there.

Investigation traced the actual mechanism: pet-summoning spells (e.g.
"Elementalkin: Fire", id 316) store a pet template key in the
`teleport_zone` field (repurposed for this use) and use `effectid1 =
33` (Summon Pet) to trigger it. This key matches a row in the `pets`
table, whose `npcID` column points to the actual stat template in
`npc_types`. These template IDs are **never spawn-linked** — pets are
summoned, not placed in zones — so they fell entirely outside
ADR-003's spawn-based Velious scope and were never touched by it.

## Verification

423 of 424 `pets` table rows resolved to a unique `npc_types`
template (one likely duplicate). All 423 were compared field-by-field
between PEQ and TAKP.

Unlike ADR-003's world-NPC findings (100% directionally uniform —
TAKP always higher), pet stats show a genuinely mixed pattern:

| Stat | Templates differing | Direction | Median ratio |
|---|---|---|---|
| `hp` | 106 | Mostly lower | 0.99 |
| `mindmg` | 76 | Mostly lower | 0.36 |
| `maxdmg` | 77 | Mostly lower | 0.89 |
| `AC` | 139 | Roughly balanced | 0.93 |
| `hp_regen_rate` | 129 | Overwhelmingly lower (128/129) | 0.35 |
| `MR` / `FR` | 117 / 104 | Mostly higher | 1.67 |
| `CR` / `DR` / `PR` | ~105 each | Mixed | 0.58–0.72 |
| `runspeed` | 131 | Uniformly higher (131/131) | 1.24 |

Net effect: pets hit softer and recover from damage much more slowly,
while resisting magic and fire damage better and moving faster. This
matches the author's description ("more realistic and less powerful
pets 1-50") directly — the damage and regen cuts are the "less
powerful" part; the resist increases follow the same pattern found
everywhere else in this database (ADR-003). The uniform movement speed
increase has no stated rationale in the author's note and is adopted
as-is along with everything else, since it was part of the same
verified TAKP dataset.

## Decision

Adopt TAKP's pet NPC template values in full for all 140 templates
where a difference exists.

## Risk

This is a genuine difficulty tradeoff, not a one-directional
improvement like ADR-003. Pet classes will hit softer and self-heal
slower. Given this server is played through Very Vanilla MQ
multiboxing with full pet-reliant compositions possible, a weaker pet
changes how much a pet can be leaned on as a tank or sustained DPS
slot. This was surfaced explicitly and accepted with that tradeoff
understood, rather than adopted as a low-risk correction.

## Consequences

- 140 of 423 pet templates change; the remainder already matched.
- No change to which pet is summoned by which spell, class, or
  level — only the summoned template's combat stats change.
- Necromancer, mage, and any other summoned-pet class are affected
  equally; the underlying data does not distinguish pet-owning class,
  only the template itself.

## Spire Compatibility

No schema changes. `npc_types` is a standard PEQ table Spire already
edits directly.

## Implementation Status

**Implemented 2026-07-23.** Applied via migration script against the
live Angels Misfits database (MCP connection). 140 pet NPC templates
updated.

Verified post-run via direct query against the live database — 7
templates checked (2 initially, including confirmation that an
unchanged template correctly stayed unchanged; 5 via random,
non-cherry-picked sampling of the full update set). All 7 matched the
computed values exactly.

## Related Investigation: Client Files

A separate check of the TAKP author's supplied client files
(`spells_us.txt`, `BaseData.txt`, `SkillCaps.txt`, `GlobalLoad.txt`,
`dbstr_us.txt`) found no action needed on the client side:

- `BaseData.txt` and `SkillCaps.txt` were already confirmed identical
  to the live server's `base_data`/`skill_caps` tables — no gap to
  close.
- `spells_us.txt`, `GlobalLoad.txt`, and `dbstr_us.txt` are client-side
  display/asset files only; they do not affect server-side spell
  resolution, NPC stats, or any mechanic covered by ADR-002 through
  ADR-005, all of which are already authoritative and in effect
  server-side regardless of client file state.
- `GlobalLoad.txt` and `dbstr_us.txt` specifically were assessed as
  unsafe to copy into an RoF2 client folder: both appear built for a
  Titanium-era asset/string set, and RoF2 requires a substantially
  larger set of both. Not adopted.
- `spells_us.txt` was assessed as likely RoF2-compatible despite the
  author's Titanium recommendation (237-field format and ~28MB size
  both match current EQEmu/RoF2 conventions rather than Titanium's
  smaller, older format), but is optional cosmetic tooltip polish, not
  a functional requirement, since server-side spell mechanics are
  already fully implemented via ADR-004. Not adopted at this time.
