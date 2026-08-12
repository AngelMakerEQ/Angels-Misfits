# Bard P99 Activation Audit — 2026-08-08

**Status:** Investigation only. No database writes were made. This document is
input for a human-reviewed migration script to be written separately.

**Scope:** Every spell currently active for Bard (`classes8 BETWEEN 1 AND 60`)
in `spells_new` on the live `angelsmisfits` database, checked against the P99
(Project 1999) wiki — this project's authoritative era-accuracy reference —
to confirm each is genuinely documented Bard content at or before the
Velious era.

## Methodology notes

- Source query: `SELECT id, name, classes8 AS level_req, mana, EndurCost,
  IsDiscipline, recast_time FROM spells_new WHERE classes8 BETWEEN 1 AND 60
  ORDER BY classes8, name`.
- Primary corroborating source: the P99 wiki **Bard class page**
  (`https://wiki.project1999.com/Bard`), which carries a `{{Template:SongRow}}`
  entry per canonical song with `name`, `level`, and `era` fields — this
  turned out to be a single authoritative list of all 74 documented Bard
  songs and was used to cross-check every non-discipline row in one pass.
  Individual spell pages were fetched (batched, pipe-separated titles) to
  confirm level, description, mechanical values (mana/range/recast/effect
  text), and `Category:*Era` tags.
- Disciplines (`IsDiscipline = 1`) are not `SongRow` entries; they were
  checked against the P99 wiki **Disciplines page**
  (`https://wiki.project1999.com/Disciplines`), which has a dedicated `Bard`
  section under "Hybrids" with level, duration, and reuse timer per
  discipline, plus historical patch-date duration changes.
- Per the added methodology instruction: for every duplicate id/name pair,
  database mechanical values (range, buff duration, effect base values,
  `spell_category`) were compared against the wiki's documented
  description/effect text and any noted patch-date revisions, not just
  name+level, to try to determine which id is the currently-correct one.
  Where this comparison produced a confident answer it is noted below with
  the specific values compared; where it did not, the row is flagged for
  human review rather than guessed.
- All wiki access succeeded directly against `wiki.project1999.com` — no
  fallback to the secondary source (`fvproject.com`) was needed.

## Summary

- **Total spells checked:** 93 (85 unique names; 8 same-name duplicate pairs
  plus one near-duplicate pair with a pluralization variant name, "Shield of
  Song" / "Shield of Songs" — 9 duplicate-id pairs total)
- **Confirmed correct, no action:** 78 rows (69 singleton spells + 9 "keep"
  sides of the 9 duplicate pairs)
- **Flagged for deactivation:** 15 rows
  - 6 standalone spells not documented anywhere on the P99 wiki
    ("Chant of Chaos/Flame/Frost/Magic/Plague/Venom", ids 22486–22491, all
    level 1)
  - 9 duplicate-pair "loser" sides (one per resolved pair, see table)
- **Duplicate pairs resolved:** 9 total
  - 5 resolved with high confidence (clear mechanical/documentation signal):
    Angstlich's Appalling Screech, Fufil's Curtailing Chant, Resistant
    Discipline, Puretone Discipline, Shield of Song/Songs
  - 1 resolved as a true mechanically-identical duplicate (arbitrary keep):
    Deftdance Discipline
  - 3 resolved with **medium/low confidence** and explicitly flagged for
    human re-review before the migration is written: Syvelian's Anti-Magic
    Aria, Jonthan's Provocation, Jonthan's Inspiration
- None of the checked spells carried a post-Velious era category (no
  Luclin/PoP/etc. content was found active for Bard) — the only
  out-of-era-in-spirit finding is the 6 undocumented "Chant of X" spells,
  which aren't tagged with a later era at all, they simply aren't
  documented as ever having existed on P99.

## Findings table

| id | name | level | current status | P99 verdict | era category | action needed | citation |
|----|------|-------|-----------------|-------------|---------------|----------------|----------|
| 700 | Chant of Battle | 1 | active | Confirmed — Bard L1 | Classic | none | Chant of Battle (own page); Bard (SongRow) |
| 22491 | Chant of Chaos | 1 | active | Not found on own page, not mentioned on Bard class page | not documented | **deactivate** | Chant of Chaos (page missing); Bard (no mention) |
| 22487 | Chant of Flame | 1 | active | Not found on own page; Bard page only mentions "Tuyen's Chant of Flame" (different spell, id 743, L38) | not documented | **deactivate** | Chant of Flame (page missing); Bard (no bare-name mention) |
| 22488 | Chant of Frost | 1 | active | Not found on own page; Bard page only mentions "Tuyen's Chant of Frost" (different spell, id 744, L46) | not documented | **deactivate** | Chant of Frost (page missing); Bard (no bare-name mention) |
| 22486 | Chant of Magic | 1 | active | Not found on own page, not mentioned on Bard class page | not documented | **deactivate** | Chant of Magic (page missing); Bard (no mention) |
| 22490 | Chant of Plague | 1 | active | Not found on own page, not mentioned on Bard class page | not documented | **deactivate** | Chant of Plague (page missing); Bard (no mention) |
| 22489 | Chant of Venom | 1 | active | Not found on own page, not mentioned on Bard class page | not documented | **deactivate** | Chant of Venom (page missing); Bard (no mention) |
| 703 | Chords of Dissonance | 2 | active | Confirmed — Bard L2 | Classic | none | Chords of Dissonance (own page) |
| 722 | Jaxan's Jig o' Vigor | 3 | active | Confirmed — Bard L3 | Classic | none | Jaxan's Jig o' Vigor (own page) |
| 720 | Lyssa's Locating Lyric | 4 | active | Confirmed — Bard L4 | Classic | none | Lyssa's Locating Lyric (own page) |
| 717 | Selo's Accelerando | 5 | active | Confirmed — Bard L5 | Classic | none | Selo's Accelerando (own page) |
| 7 | Hymn of Restoration | 6 | active | Confirmed — Bard L6 | Classic | none | Hymn of Restoration (own page) |
| 734 | Jonthan's Whistling Warsong | 7 | active | Confirmed — Bard L7 | Classic | none | Jonthan's Whistling Warsong (own page) |
| 728 | Kelin's Lugubrious Lament | 8 | active | Confirmed — Bard L8 | Classic | none | Kelin's Lugubrious Lament (own page) |
| 710 | Elemental Rhythms | 9 | active | Confirmed — Bard L9 | Classic | none | Elemental Rhythms (own page) |
| 701 | Anthem de Arms | 10 | active | Confirmed — Bard L10 (wiki title "Anthem De Arms") | Classic | none | Anthem De Arms (own page) |
| 708 | Cinda's Charismatic Carillon | 11 | active | Confirmed — Bard L11 | Classic | none | Cinda's Charismatic Carillon (own page) |
| 704 | Brusco's Boastful Bellow | 12 | active | Confirmed — Bard L12 | Classic | none | Brusco's Boastful Bellow (own page) |
| 711 | Purifying Rhythms | 13 | active | Confirmed — Bard L13 | Classic | none | Purifying Rhythms (own page) |
| 737 | Lyssa's Cataloging Libretto | 14 | active | Confirmed — Bard L14 | Classic | none | Lyssa's Cataloging Libretto (own page) |
| 724 | Kelin's Lucid Lullaby | 15 | active | Confirmed — Bard L15 | Classic | none | Kelin's Lucid Lullaby (own page) |
| 729 | Tarew's Aquatic Ayre | 16 | active | Confirmed — Bard L16 | Classic | none | Tarew's Aquatic Ayre (own page) |
| 709 | Guardian Rhythms | 17 | active | Confirmed — Bard L17 | Classic | none | Guardian Rhythms (own page) |
| 730 | Denon's Disruptive Discord | 18 | active | Confirmed — Bard L18 | Classic | none | Denon's Disruptive Discord (own page) |
| 719 | Shauri's Sonorous Clouding | 19 | active | Confirmed — Bard L19 | Classic | none | Shauri's Sonorous Clouding (own page) |
| 1287 | Cassindra's Chant of Clarity | 20 | active | Confirmed — Bard L20; own page notes "This Velious song is a lower level version of Cantata of Replenishment" | Velious | none | Cassindra's Chant of Clarity (own page); Bard (SongRow) |
| 705 | Largo's Melodic Binding | 20 | active | Confirmed — Bard L20 | Classic | none | Largo's Melodic Binding (own page) |
| 739 | Melanie's Mellifluous Motion | 21 | active | Confirmed — Bard L21 | Classic | none | Melanie's Mellifluous Motion (own page) |
| 727 | Alenia's Disenchanting Melody | 22 | active | Confirmed — Bard L22 | Classic | none | Alenia's Disenchanting Melody (own page) |
| 738 | Selo's Consonant Chain | 23 | active | Confirmed — Bard L23 | Classic | none | Selo's Consonant Chain (own page) |
| 735 | Lyssa's Veracious Concord | 24 | active | Confirmed — Bard L24 | Classic | none | Lyssa's Veracious Concord (own page) |
| 712 | Psalm of Warmth | 25 | active | Confirmed — Bard L25 | Classic | none | Psalm of Warmth (own page) |
| 706 | Angstlich's Appalling Screech | 26 | active | **Keep.** Wiki documents one version only, Classic era, L26. DB `spell_category = 62` (populated/real), matches wiki desc/effect (Fear PB AE). | Classic | none (confirmed as the correct surviving id) | Angstlich's Appalling Screech (own page) |
| 1329 | Angstlich's Appalling Screech | 26 | active | **Duplicate of 706.** Identical effect data to 706 but `spell_category = -99` (unclassified placeholder — same signature EQEmu uses for unused/template rows) and no `effectdescnum`. No second era-version is documented anywhere. | Classic (n/a — erroneous row) | **deactivate-duplicate-keep-other-id (706)** | Angstlich's Appalling Screech (own page); DB `spell_category` comparison |
| 725 | Solon's Song of the Sirens | 27 | active | Confirmed — Bard L27 | Classic | none | Solon's Song of the Sirens (own page) |
| 741 | Crission's Pixie Strike | 28 | active | Confirmed — Bard L28 | Classic | none | Crission's Pixie Strike (own page) |
| 715 | Psalm of Vitality | 29 | active | Confirmed — Bard L29 | Classic | none | Psalm of Vitality (own page) |
| 8539 | Fufil's Curtailing Chant | 30 | active | **Keep.** Wiki documents one version, Classic era ("May 1999"), L30, `range = 200`. DB `range = 200` — matches exactly. | Classic | none (confirmed as the correct surviving id) | Fufil's Curtailing Chant (own page, `range` field) |
| 707 | Fufil's Curtailing Chant | 30 | active | **Duplicate of 8539.** Same name/level/effects but DB `range = 150`, which does not match the wiki's documented `range = 200`. | Classic (n/a — mechanically stale row) | **deactivate-duplicate-keep-other-id (8539)** | Fufil's Curtailing Chant (own page, `range` field) |
| 718 | Agilmente's Aria of Eagles | 31 | active | Confirmed — Bard L31 | Classic | none | Agilmente's Aria of Eagles (own page) |
| 723 | Cassindra's Chorus of Clarity | 32 | active | Confirmed — Bard L32 | Classic | none | Cassindra's Chorus of Clarity (own page) |
| 713 | Psalm of Cooling | 33 | active | Confirmed — Bard L33 | Classic | none | Psalm of Cooling (own page) |
| 1448 | Cantana of Soothing | 34 | active | Confirmed — Bard L34 (DB spelling "Cantana" is a database-side variant of the wiki's own-page title "Cantata of Soothing"; SongRow table on the Bard page itself also uses "Cantana") | Velious | none | Cantata of Soothing (own page, redirect target); Bard (SongRow, spelled "Cantana") |
| 721 | Lyssa's Solidarity of Vision | 34 | active | Confirmed — Bard L34 | Classic | none | Lyssa's Solidarity of Vision (own page) |
| 736 | Denon's Dissension | 35 | active | Confirmed — Bard L35 | Classic | none | Denon's Dissension (own page) |
| 740 | Vilia's Verses of Celerity | 36 | active | Confirmed — Bard L36 | Classic | none | Vilia's Verses of Celerity (own page) |
| 716 | Psalm of Purity | 37 | active | Confirmed — Bard L37 | Classic | none | Psalm of Purity (own page) |
| 743 | Tuyen's Chant of Flame | 38 | active | Confirmed — Bard L38 | Classic | none | Tuyen's Chant of Flame (own page) |
| 750 | Solon's Bewitching Bravura | 39 | active | Confirmed — Bard L39 | Kunark | none | Solon's Bewitching Bravura (own page); Bard (SongRow) |
| 8489 | Syvelian's Anti-Magic Aria | 40 | active | **Ambiguous — flagged for human review.** Wiki documents one version only, Classic era, L40, `range = 200`. Neither DB id matches: 8489 has `range = 100`, 726 has `range = 75`. Core effect (Cancel Magic, effectid1=27 value=4) is identical between both ids, so that doesn't disambiguate either. Tentative lean toward keeping 8489 (closer numerically to 200) but this is a low-confidence guess, not a documented signal. | Classic | **needs review before action** | Syvelian's Anti-Magic Aria (own page, `range` field); DB `range` comparison (inconclusive) |
| 726 | Syvelian's Anti-Magic Aria | 40 | active | Same ambiguity as 8489 — see above. | Classic | **needs review before action** | same as above |
| 714 | Psalm of Mystic Shielding | 41 | active | Confirmed — Bard L41 | Classic | none | Psalm of Mystic Shielding (own page) |
| 702 | McVaxius' Berserker Crescendo | 42 | active | Confirmed — Bard L42 | Classic | none | McVaxius' Berserker Crescendo (own page) |
| 742 | Denon's Desperate Dirge | 43 | active | Confirmed — Bard L43 | Classic | none | Denon's Desperate Dirge (own page) |
| 745 | Cassindra's Elegy | 44 | active | Confirmed — Bard L44 | Classic | none | Cassindra's Elegy (own page) |
| 8585 | Jonthan's Provocation | 45 | active | **Ambiguous — flagged for human review, medium confidence lean toward deactivating this id.** Wiki documents one version, Kunark ("April 2000"), L45, with STR/ATK effects that scale with level (13→17 STR, 13→17 ATK). DB `effect_base_value1 = 103` on this id is **identical** to `effect_base_value1 = 103` on 8584 ("Jonthan's Inspiration", a *different* spell at a *different* level, L58) — the same suspicious flat value recurring across two different spells/levels suggests 8585 may be an unfinished/placeholder P99-raw-export row rather than the real one. Id 749 has a level-appropriate-looking distinct value (113) and a populated third effect slot that 8585 lacks. | Kunark | **needs review — lean deactivate 8585, keep 749** | Jonthan's Provocation (own page); DB effect-value comparison against sibling pair (Jonthan's Inspiration) |
| 749 | Jonthan's Provocation | 45 | active | Same ambiguity as 8585 — see above; this is the tentatively-favored id to keep. | Kunark | **needs review** | same as above |
| 744 | Tuyen's Chant of Frost | 46 | active | Confirmed — Bard L46 | Classic | none | Tuyen's Chant of Frost (own page) |
| 748 | Niv's Melody of Preservation | 47 | active | Confirmed — Bard L47 | Classic | none | Niv's Melody of Preservation (own page) |
| 746 | Selo's Chords of Cessation | 48 | active | Confirmed — Bard L48 | Classic | none | Selo's Chords of Cessation (own page) |
| 1450 | Shield of Song | 49 | active | **Keep.** Wiki's own page is literally titled "Shield of Song" (added end of Epics Era, pre-Velious-launch); "Shield of Songs" is a MediaWiki `#REDIRECT` to this page, i.e. the wiki treats them as the same spell under one canonical name. DB effect data for 1450 and 8592 is identical. | Kunark | none (confirmed as the correct surviving id; name matches wiki's canonical title exactly) | Shield of Song (own page); Shield of Songs → redirect to Shield of Song |
| 8592 | Shield of Songs | 49 | active | **Duplicate of 1450** (see above — redirect target, identical DB values, just an alternate pluralization of the same name). | Kunark | **deactivate-duplicate-keep-other-id (1450)** | same as above |
| 1449 | Melody of Ervaj | 50 | active | Confirmed — Bard L50 | Velious | none | Melody of Ervaj (own page); Bard (SongRow) |
| 747 | Verses of Victory | 50 | active | Confirmed — Bard L50 | Classic | none | Verses of Victory (own page) |
| 1751 | Largo's Absonant Binding | 51 | active | Confirmed — Bard L51 | Kunark | none | Largo's Absonant Binding (own page) |
| 8601 | Resistant Discipline | 51 | active | **Keep.** Disciplines page: Bard Resistant Discipline, L51, originally "1 Min" duration/60 Min reuse, with a documented Jan 9, 2001 patch note "Duration increased to 5 minutes" (Jan 2001 is still within the Velious era window, pre-Luclin). DB `buffduration = 50` ticks = 300s = 5 min — matches the **post-patch** (current, correct) value. `recast_time = 3600000` ms = 60 min, matches either state (reuse time unchanged by that patch). | Velious (hybrid disciplines added in Velious per Disciplines page) | none (confirmed as the correct, current-state surviving id) | Disciplines (Bard section); DB `buffduration` comparison |
| 8608 | Resistant Discipline | 51 | active | **Duplicate of 8601, pre-patch value.** `buffduration = 10` ticks = 60s = 1 min, matching the **original (superseded)** duration documented on the Disciplines page before the Jan 9, 2001 patch. | Velious (n/a — stale pre-patch row) | **deactivate-duplicate-keep-other-id (8601)** | same as above |
| 1750 | Selo's Song of Travel | 51 | active | Confirmed — Bard L51 | Kunark | none | Selo's Song of Travel (own page) |
| 1752 | Nillipus' March of the Wee | 52 | active | Confirmed — Bard L52 | Kunark | none | Nillipus' March of the Wee (own page) |
| 1754 | Song of Dawn | 53 | active | Confirmed — Bard L53 | Kunark | none | Song of Dawn (own page) |
| 1753 | Song of Twilight | 53 | active | Confirmed — Bard L53 | Kunark | none | Song of Twilight (own page) |
| 8609 | Fearless Discipline | 54 | active | Confirmed — Disciplines page: Bard Fearless Discipline, L54, 11 sec duration/60 Min reuse, no pre/post-patch value split documented; only one Bard id exists in our DB for this discipline (no duplicate). | Velious | none | Disciplines (Bard section) |
| 1758 | Selo's Assonant Strane | 54 | active | Confirmed — Bard L54 | Kunark | none | Selo's Assonant Strane (own page) |
| 1757 | Vilia's Chorus of Celerity | 54 | active | Confirmed — Bard L54 | Kunark | none | Vilia's Chorus of Celerity (own page) |
| 1747 | Brusco's Bombastic Bellow | 55 | active | Confirmed — Bard L55 | Kunark | none | Brusco's Bombastic Bellow (own page) |
| 1759 | Cantana of Replenishment | 55 | active | Confirmed — Bard L55 (DB spelling "Cantana" matches the Bard page's own SongRow spelling; own-page title is "Cantata of Replenishment", redirect target) | Kunark | none | Cantata of Replenishment (own page, redirect target); Bard (SongRow, spelled "Cantana") |
| 8605 | Deftdance Discipline | 55 | active | **Mechanically identical duplicate — arbitrary keep.** Disciplines page: Bard Deftdance Discipline, L55, "10 Sec" duration originally, "increased to 15 seconds" post-patch, 72 Min reuse. Both DB ids (8605, 8610) have **identical** `buffduration = 3` ticks (18s ≈ rounds toward the post-patch 15s figure) and identical `recast_time = 4320000` (72 min). There is no mechanical signal distinguishing the two ids — this is a true duplicate object, not an era split. Kept 8605 (lower id) arbitrarily as the canonical row; recommend human confirmation before the migration removes 8610. | Velious | none (tentatively kept, arbitrary choice — see note) | Disciplines (Bard section); DB value comparison (both ids identical) |
| 8610 | Deftdance Discipline | 55 | active | Identical duplicate of 8605 — see above. | Velious | **deactivate-duplicate-keep-other-id (8605, arbitrary — confirm before applying)** | same as above |
| 1451 | Occlusion of Sound | 55 | active | Confirmed — Bard L55 | Velious | none | Occlusion of Sound (own page); Bard (SongRow) |
| 1755 | Song of Highsun | 56 | active | Confirmed — Bard L56 | Kunark | none | Song of Highsun (own page) |
| 1756 | Song of Midnight | 56 | active | Confirmed — Bard L56 | Kunark | none | Song of Midnight (own page); Bard (SongRow) |
| 1761 | Cassindra's Insipid Ditty | 57 | active | Confirmed — Bard L57 | Kunark | none | Cassindra's Insipid Ditty (own page); Bard (SongRow) |
| 1760 | McVaxius' Rousing Rondo | 57 | active | Confirmed — Bard L57 | Kunark | none | McVaxius' Rousing Rondo (own page); Bard (SongRow) |
| 8584 | Jonthan's Inspiration | 58 | active | **Ambiguous — flagged for human review, medium confidence lean toward deactivating this id.** Wiki documents one version, L58, STR/ATK effects scaling with level (17→18 STR, 15→16 ATK). DB `effect_base_value1 = 103` on this id is identical to the *same* flat value on 8585 ("Jonthan's Provocation", a different spell at a different level) — same suspicious-flat-value signal as that pair. Id 1762 has a distinct, higher value (120) consistent with being the higher-level spell, and a populated third effect slot 8584 lacks. | Kunark | **needs review — lean deactivate 8584, keep 1762** | Jonthan's Inspiration (own page); DB effect-value comparison against sibling pair (Jonthan's Provocation) |
| 1762 | Jonthan's Inspiration | 58 | active | Same ambiguity as 8584 — see above; this is the tentatively-favored id to keep. | Kunark | **needs review** | same as above |
| 1763 | Niv's Harmonic | 58 | active | Confirmed — Bard L58 | Kunark | none | Niv's Harmonic (own page); Bard (SongRow) |
| 1764 | Denon's Bereavement | 59 | active | Confirmed — Bard L59 | Kunark | none | Denon's Bereavement (own page); Bard (SongRow) |
| 1765 | Solon's Charismatic Concord | 59 | active | Confirmed — Bard L59 | Kunark | none | Solon's Charismatic Concord (own page); Bard (SongRow) |
| 1748 | Angstlich's Assonance | 60 | active | Confirmed — Bard L60 | Kunark | none | Angstlich's Assonance (own page); Bard (SongRow) |
| 1452 | Composition of Ervaj | 60 | active | Confirmed — Bard L60 | Velious | none | Composition of Ervaj (own page); Bard (SongRow) |
| 1749 | Kazumi's Note of Preservation | 60 | active | Confirmed — Bard L60 | Kunark | none | Kazumi's Note of Preservation (own page); Bard (SongRow) |
| 8606 | Puretone Discipline | 60 | active | **Keep.** Disciplines page: Bard Puretone Discipline, L60, "2 Min" duration originally, "increased to 4 minutes" post-patch, 72 Min reuse. DB `buffduration = 40` ticks = 240s = 4 min — matches the **post-patch** (current, correct) value. `recast_time = 4320000` ms = 72 min matches. | Velious | none (confirmed as the correct, current-state surviving id) | Disciplines (Bard section); DB `buffduration` comparison |
| 8611 | Puretone Discipline | 60 | active | **Duplicate of 8606, pre-patch value.** `buffduration = 20` ticks = 120s = 2 min, matching the **original (superseded)** duration documented before the patch. | Velious (n/a — stale pre-patch row) | **deactivate-duplicate-keep-other-id (8606)** | same as above |

## Notes for whoever writes the migration

- The 6 "Chant of X" ids (22486–22491) are the cleanest cut — no wiki
  presence anywhere, `spell_category = -99` on all six (same placeholder
  signature as the confirmed-erroneous 1329), and effect values are mostly
  unset. High confidence these are inert P99-raw-export artifacts that
  never shipped as real Bard content.
- Of the 9 duplicate pairs, 6 have a clear, cited mechanical or
  documentation-based tiebreaker. 3 (Syvelian's Anti-Magic Aria, Jonthan's
  Provocation, Jonthan's Inspiration) do not have fully conclusive evidence
  — recommend a second look (possibly decoding the exact SPA/formula fields
  rather than raw `effect_base_value`, which may not be directly comparable
  across different spell formulas) before committing to which id to
  deactivate in those three cases.
- Per `docs/decisions/000_UNCLASSIC_DECISIONS.md` convention, once the
  migration is written and applied, any spells kept active despite an
  imperfect mechanical match to the wiki (e.g. if Syvelian's Anti-Magic
  Aria's range is left at 75 or 100 rather than corrected to the wiki's 200)
  should get an entry there, since that would be a knowing deviation from
  documented P99 mechanics.
