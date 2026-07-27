# TAKP (Rebalanced Database)

## Reliability Summary

TAKP has proven to be a highly reliable source for classic-era **mechanical** data, and its own author's stated tuning methodology has repeatedly checked out against independent verification. Confidence varies by data category — see below.

## High Confidence — Verified, Not Just Trusted

- **Spell mechanics (`spells_new`).** Verified byte-for-byte identical to the real classic client's own spell data file across all 237 fields and ~40,719 spells. This is the single strongest validation TAKP has received in this project — not "TAKP looks right," but a direct match to primary client data. See ADR-004.
- **NPC combat stat direction.** The TAKP author's own stated method ("stronger-in-TAKP stats adopted, stronger-or-equal-in-PEQ left unchanged") was independently confirmed by a blind data comparison — 100% of differing values favored TAKP, zero counterexamples. Treated as corroborated, not just self-reported. See ADR-003.
- **Client reference files (`BaseData.txt`, `SkillCaps.txt`).** Spot-checked and found already identical to the live database — no gap, no action needed, but confirms these specific files are trustworthy where used.

## Medium Confidence — Internally Consistent, Author-Stated Intent Confirmed

- **Pet stats.** TAKP's pet tuning is a genuine mixed pattern (softer damage/regen, better resists, faster movement) rather than a uniform buff — but it matches the author's explicitly stated "less powerful pets" intent, and was adopted on that basis. See ADR-005.

## Known Limitations — Do Not Adopt Blindly

- **Aggro radius.** TAKP widens this substantially (up to 10× in outliers) — real data, but not adopted outright since it conflicts with this project's multibox-based group content. A custom midpoint was used instead. This is a case where TAKP being "verified as directionally correct" did not mean "safe to adopt at full magnitude" — worth remembering for any future TAKP field. See ADR-003.
- **Server rules (bot system).** TAKP's file includes a full bot system enablement — this reflects the file author's personal server preferences, not classic accuracy, and was rejected in full. TAKP data should not be assumed free of the original author's personal customizations just because other fields check out. See ADR-002.
- **`Character:DeathItemLossLevel = 90`** — rejected; at this project's level cap, this value would have functionally disabled item loss as a mechanic. A specific value being present in TAKP doesn't guarantee it's era-accurate rather than an author preference.
- **Client asset files (`spells_us.txt`, `GlobalLoad.txt`, `dbstr_us.txt`) supplied alongside TAKP.** Assessed as built for a Titanium-era client — not safe to apply directly to RoF2. See ADR-005.
- **`Spells:WizCritLevel`.** TAKP's value (80) was rejected — it would disable a mechanic well-supported to have existed pre-Luclin. A reminder that TAKP is a rebalanced/customized dataset, not a pure historical mirror, and single values still need individual scrutiny even given the source's overall trustworthiness.

## Working Takeaway

TAKP is a strong default source for **mechanical/numerical** classic-era data (spells, combat stats), especially where independently verifiable. It is a weaker source for anything touching **server rules or systemic design choices**, since those most directly reflect the original file author's personal server preferences rather than classic EverQuest itself. When evaluating TAKP for a new area, ask first: is this a raw game-data field (trust more), or a design/rule choice (verify against other sources before adopting)?
