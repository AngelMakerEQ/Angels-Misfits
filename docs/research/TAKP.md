# The TAKP-Claimed Comparison Database

## Provenance note — read this first

What this project calls "TAKP" throughout its docs and ADRs is **not a confirmed copy of The Al'Kabor Project's actual database**. It's a local comparison database the user obtained from elsewhere, supplied with a file author's own notes claiming it was derived from TAKP with specific manual tuning applied. This project has no independent way to verify that provenance claim, no access to a confirmed-genuine TAKP source, and doesn't know what, if anything, differs from whatever it was actually derived from. It should never be cited as "TAKP says X" as if that settles a question — see below for what's actually known, category by category.

References elsewhere in this repo to "TAKP," "the TAKP database," or "the TAKP Reference database" all mean this same unverified comparison dataset. Prefer "the TAKP-claimed database" or "the comparison database" going forward.

## Reliability Summary

Confidence in specific fields pulled from this database varies enormously depending on **how each finding was actually checked** — not on any general trust in the dataset's authority or its file author's claims. Two different kinds of evidence get conflated easily, so keep them distinct:

- **Independent verification** — a value from the comparison database was checked against a genuine primary source (an actual classic client data file, the P99 wiki, original patch notes) and matched. This is real evidence, and it doesn't depend on the comparison database's own provenance being true.
- **Internal self-consistency** — a value matched what the file's own accompanying notes claimed the (unverified) author had done to it. This confirms the file is consistent with its own documentation, not that the documentation itself reflects real classic EverQuest behavior.

## High Confidence — Independently Verified Against a Primary Source

- **Spell mechanics (`spells_new`).** The comparison database's spell table was checked field-by-field against the real classic client's own spell data file (`spells_us.txt`) and matched across all 237 fields and ~40,719 spells. This is genuine primary-source verification — not "the comparison database looks right," but a direct byte-for-byte match to actual classic client data, independent of any claim about where the comparison database itself came from. See ADR-004.
- **Client reference files (`BaseData.txt`, `SkillCaps.txt`).** Spot-checked and found already identical to the live database — no gap, no action needed, but confirms these specific files matched at the point checked.

## Medium Confidence — Internally Consistent With the File Author's Own Claims, Not Independently Verified Against Primary Data

**Treat these with real caution — see the provenance note above.** These conclusions rest on the comparison database's own accompanying notes being accurate, which this project cannot confirm:

- **NPC combat stat direction.** The comparison database's file author claimed a specific tuning method ("stronger-in-this-file stats adopted, stronger-or-equal-in-PEQ left unchanged"). A blind data comparison found 100% of differing values consistent with that *stated* method — but this only confirms the file matches its own author's description of it, not that the underlying values are independently correct classic data. See ADR-003, and treat any future re-examination of this area as still open, not closed.
- **Pet stats.** Similarly, the comparison database's pet tuning matches the file author's stated "less powerful pets" intent — again, internal consistency with a claim this project cannot independently verify, not primary-source confirmation. See ADR-005.

## Known Limitations — Do Not Adopt Blindly

- **Aggro radius.** The comparison database widens this substantially (up to 10× in outliers) — but this was not adopted outright since it conflicts with this project's multibox-based group content, and there's no independent verification it's classic-accurate rather than a personal tuning choice by the file's author. A custom midpoint was used instead. See ADR-003.
- **Server rules (bot system).** The comparison database's rule set includes a full bot system enablement — this reflects the file author's own personal server preferences, not classic accuracy, and was rejected in full. Nothing in this dataset should be assumed free of the original (unknown) author's personal customizations just because other fields happened to check out elsewhere.
- **`Character:DeathItemLossLevel = 90`** — rejected; at this project's level cap, this value would have functionally disabled item loss as a mechanic. A value being present in this comparison database doesn't establish it's era-accurate rather than a personal preference of whoever built the file.
- **Client asset files (`spells_us.txt`, `GlobalLoad.txt`, `dbstr_us.txt`) supplied alongside the comparison database.** Assessed as built for a Titanium-era client — not safe to apply directly to RoF2. See ADR-005.
- **`Spells:WizCritLevel`.** The comparison database's value (80) was rejected — it would disable a mechanic well-supported to have existed pre-Luclin. A reminder that this is an unverified, apparently rebalanced/customized dataset of unknown authorship, not a confirmed historical mirror — every individual value still needs its own scrutiny.

## Working Takeaway

Treat the TAKP-claimed comparison database as a **candidate-generation tool, not a source of truth**. It's genuinely useful for surfacing where PEQ's stock data likely drifted from classic (it correctly flagged real problems in ADR-003/004/005), but any specific value pulled from it needs independent verification against client data, the P99 wiki, or original patch notes (see `patcheq` in the reference-repositories note in `CLAUDE.md`/`AGENTS.md`) before being trusted as ground truth — not because the dataset is bad, but because its actual provenance and the reliability of its own author's claims are both unconfirmed. When evaluating a new field from this database, ask: was this checked against real primary data, or only against the file's own claims about itself?
