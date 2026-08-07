# TAKP-Claimed Comparison Database Imports

Quick-reference table of what was sourced from the project's local
comparison database — a dataset the user obtained and was told is sourced
from TAKP (The Al'Kabor Project), with provenance this project cannot
independently verify. See `docs/research/TAKP.md` for the full reliability
breakdown; don't treat entries below as "verified classic" just because
they're listed here — several were independently confirmed against real
client data, others only match the comparison file's own claims about
itself. Split into **adopted** (values imported) and **verification-only**
(checked but no values imported). For full reasoning and timing, see the
referenced ADR.

---

## Adopted — Values Imported from the Comparison Database

| Area | Field(s) | Adopted As-Is? | Reason | ADR |
|---|---|---|---|---|
| Level cap | `Character:MaxLevel`, `MaxExpLevel` | Yes (60) | Kunark/Velious-accurate cap | ADR-002 |
| Death handling | `DeathKeepLevel`, hunger penalties, TGB, rest regen, Master Wu | Yes | Classic mechanic restoration | ADR-002 |
| Bind mechanic | `BindAnywhere` | Yes, but flagged as deliberate deviation | Not classic, kept for convenience | ADR-002 |
| NPC combat stats | `hp`, `maxdmg`, `AC`, `hp_regen_rate`, `MR/CR/FR/DR/PR` | Yes, full value | 100% directionally consistent with the comparison file's own stated tuning method — internal self-consistency, not independent verification; see `docs/research/TAKP.md` | ADR-003 |
| NPC aggro radius | `aggroradius` | **No** — midpoint of PEQ/comparison-database values used instead | Full comparison-database widening too punishing for multibox play | ADR-003 |
| Spell mechanics | `spells_new`, all 237 fields | Yes, full table | Independently verified byte-identical to the real classic client's own `spells_us.txt` — genuine primary-source verification | ADR-004 |
| Pet stats | `hp`, `mindmg`, `maxdmg`, `AC`, `hp_regen_rate`, resists, `runspeed` | Yes, full value | Matches the comparison file's stated "less powerful pets" tuning — internal self-consistency, not independent verification | ADR-005 |

**Rejected outright:** all `Bots:*` rules (ADR-002); `DeathItemLossLevel = 90` (ADR-002, would disable item loss at level 50 cap — since superseded by the level-60 correction, but the underlying value was still rejected on its own merits).

---

## Verification-Only — Comparison Database Checked, No Values Imported

| Item Checked | Found in Comparison DB? | Conclusion | ADR |
|---|---|---|---|
| Gloomingdeep Lantern | No | Confirms it's non-classic; removed from our starting_items | ADR-006 |
| Backpack | No | Confirms it's non-classic; removed from our starting_items | ADR-006 |
| Recruitment letters, weapons, food/drink, bandages, prescribed spells | Yes | Confirms these are classic; retained unchanged | ADR-006 |
| `BaseData.txt`, `SkillCaps.txt` (client files supplied alongside the comparison database) | Already matched live DB | No import needed — zero deviation found | ADR-005 |
| `spells_us.txt`, `GlobalLoad.txt`, `dbstr_us.txt` (client files supplied alongside the comparison database) | N/A | Not adopted — built for Titanium, unsafe/unnecessary for RoF2 | ADR-005 |

---

## Pending / Not Yet Investigated

- No further comparison-database review scheduled at this time. Future
  database work (itemization, quests) may reopen it as a candidate-
  generation source — log any new comparison here using the same table
  format, and independently verify anything pulled from it before
  treating it as ground truth (see `docs/research/TAKP.md`).
