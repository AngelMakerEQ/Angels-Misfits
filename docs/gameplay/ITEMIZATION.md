# Itemization

## Status

No universal "stat-budget formula" for classic-era itemization exists anywhere
— confirmed by research (2026-08-06): neither P99 wiki, EQEmu forums, nor
general community sources document one. Verant never published item-design
rules, and this is one of the categories where the true answer likely no
longer exists outside the original (long-gone) dev team — see
`docs/development/assessments/CODEX_ASSESSMENT_7_30_26.md`-style "hard to
know" categories for the general pattern.

Given that, the working method is comparative, not formulaic: pick
individually well-documented classic items (especially ones known to have
changed materially over EQ's live history) and check their exact live-DB
stats against their documented classic values — the same spot-check method
used successfully for NPCs.

## Spot-check findings (2026-08-06)

Initial hypothesis going in: since PEQ is a "live-like, all-era" database
rather than a classic-focused one (unlike P99 or TAKP), itemization should
show meaningful drift. Three items checked, spanning all three in-scope eras:

| Item | Era | Result |
|---|---|---|
| Fungus Covered Scale Tunic (2735) | Kunark | ✅ Exact match — AC 21, +2 STR/-10 DEX/+2 INT/-10 AGI, 15 HP/tick worn regen, no click effect. Byte-for-byte identical to documented stats. |
| Burlap Coldain Prayer Shawl (1175) | Velious | ✅ Exact match — AC 1, +1 INT/+1 WIS/+1 CR, shoulder slot. Identical to documented tier-1 stats. |
| Manastone (13401) | Classic | ⚠️ Mixed — see below. |

**Manastone is the interesting case**, and it cuts against the "significant
drift" hypothesis in one way while confirming a real, separate defect in
another:

- The classic Manastone (id 13401) is a famous item known to have been
  removed from its only drop source (An Evil Eye, Lower Guk) by the October
  1999 patch, and restricted to Old World zones only. **The live database
  currently has zero loot-table entries anywhere granting this item** —
  consistent with (though not provably caused by) that documented removal.
  A second, unrelated item also named "Manastone" (id 54905, reqlevel 80,
  explicitly flavor-texted "an artifact once thought lost to the ages") is a
  much later-era tribute/remake reusing the same click effect — inert and
  unreachable under this server's Velious expansion gate, same
  harmless-coexistence pattern found repeatedly during epic-quest research.
- **Real, verified defect (currently inert):** the classic Manastone's click
  effect is spell 940 "Mana Convert," documented as converting 60 HP into 20
  Mana. The live spell record only has a `CurrentMana +20` effect (SPA 15) —
  **the HP-cost half of the trade is entirely missing.** As configured, this
  would be a free +20 mana with no drawback if it were ever obtainable again.
  Not currently player-facing (no drop source exists), but worth fixing if
  Manastone (or anything else referencing spell 940) is ever reintroduced.

**Conclusion so far:** individually well-documented items — the ones the
whole EQEmu/P99 community has scrutinized for 20+ years — are highly
accurate in this database, mirroring exactly what the NPC spot-check found.
This doesn't mean itemization drift isn't real; it means spot-checking
famous items is structurally the *wrong* tool to find it, for the same
reason spot-checking famous NPCs was. The real risk is the undocumented long
tail: the thousands of items nobody has ever individually verified, where
PEQ's all-era design could plausibly have pulled forward later-era stat
inflation with nobody the wiser. Finding that requires a different method
than more spot-checks — see Next Steps.

## Next steps (not yet started)

The spell/NPC precedent in this project is instructive: ADR-004's spell
audit didn't spot-check famous spells, it diffed **all 37,729 spells**
byte-for-byte against a verified classic source file (independent primary-
source verification), and ADR-003 did the same at bulk scale for NPC
combat stats against the TAKP-claimed comparison database (internal
self-consistency with that file's own claims, not independent
verification — see `docs/research/TAKP.md`). Itemization has no
equivalent yet:

- Identify whether a comparably complete, era-verified item source exists
  (the TAKP-claimed comparison database's own `items` table would be a
  candidate, subject to the project's standing caveat that this database's
  provenance is unverified and it spans into Luclin/PoP — the same caution
  already applied to ADR-003's NPC data; any value pulled from it would
  still need independent verification before being trusted).
- If a comparable source exists, a structured diff (PEQ vs. that source,
  scoped to Classic/Kunark/Velious-era items only) would surface real,
  systematic drift the way the spell audit did — rather than continuing to
  spot-check individually famous items, which this pass suggests will keep
  reporting "looks fine" regardless of the true state of the undocumented
  bulk.
- Historical sources and the targeted Classic item-stack-size corrections
  remain recorded in `docs/research/HISTORICAL_SOURCES.md` and
  `docs/database/PEQ_CHANGES.md`.

Use this document for future item-budget and era-appropriate equipment policy,
not for the value-level database ledger.
