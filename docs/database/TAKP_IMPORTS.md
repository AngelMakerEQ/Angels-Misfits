# TAKP Imports

Quick-reference table of what was sourced from TAKP, split into
**adopted** (values imported) and **verification-only** (TAKP checked
but no values imported). For full reasoning and timing, see the
referenced ADR.

---

## Adopted — Values Imported from TAKP

| Area | Field(s) | Adopted As-Is? | Reason | ADR |
|---|---|---|---|---|
| Level cap | `Character:MaxLevel`, `MaxExpLevel` | Yes (60) | Kunark/Velious-accurate cap | ADR-002 |
| Death handling | `DeathKeepLevel`, hunger penalties, TGB, rest regen, Master Wu | Yes | Classic mechanic restoration | ADR-002 |
| Bind mechanic | `BindAnywhere` | Yes, but flagged as deliberate deviation | Not classic, kept for convenience | ADR-002 |
| NPC combat stats | `hp`, `maxdmg`, `AC`, `hp_regen_rate`, `MR/CR/FR/DR/PR` | Yes, full value | 100% directionally consistent with TAKP author's stated tuning method | ADR-003 |
| NPC aggro radius | `aggroradius` | **No** — midpoint of PEQ/TAKP used instead | Full TAKP widening too punishing for multibox play | ADR-003 |
| Spell mechanics | `spells_new`, all 237 fields | Yes, full table | Verified byte-identical to real classic client data | ADR-004 |
| Pet stats | `hp`, `mindmg`, `maxdmg`, `AC`, `hp_regen_rate`, resists, `runspeed` | Yes, full value | Matches author's stated "less powerful pets" tuning | ADR-005 |

**Rejected outright:** all `Bots:*` rules (ADR-002); `DeathItemLossLevel = 90` (ADR-002, would disable item loss at level 50 cap — since superseded by the level-60 correction, but the underlying value was still rejected on its own merits).

---

## Verification-Only — TAKP Checked, No Values Imported

| Item Checked | Found in TAKP? | Conclusion | ADR |
|---|---|---|---|
| Gloomingdeep Lantern | No | Confirms it's non-classic; removed from our starting_items | ADR-006 |
| Backpack | No | Confirms it's non-classic; removed from our starting_items | ADR-006 |
| Recruitment letters, weapons, food/drink, bandages, prescribed spells | Yes | Confirms these are classic; retained unchanged | ADR-006 |
| `BaseData.txt`, `SkillCaps.txt` (TAKP author's client files) | Already matched live DB | No import needed — zero deviation found | ADR-005 |
| `spells_us.txt`, `GlobalLoad.txt`, `dbstr_us.txt` (TAKP author's client files) | N/A | Not adopted — built for Titanium, unsafe/unnecessary for RoF2 | ADR-005 |

---

## Pending / Not Yet Investigated

- No further TAKP comparison scheduled at this time. Future database
  work (itemization, quests) may reopen TAKP as a reference source —
  log any new comparison here using the same table format.
