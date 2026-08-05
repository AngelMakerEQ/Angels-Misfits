# ADR-015: Classic Spell Particle Texture Restoration

**Status:** Accepted — Implemented and Confirmed
**Date:** 2026-08-04

---

## Context

Reported bug: level 40 Iksar Necromancer "Angel" showed no spell-cast
particle effects, and (initially) no casting animation/body movement
either. The animation half was independently diagnosed and fixed by
project lead outside this ADR's scope and is not detailed here. This
ADR covers only the remaining symptom: **no spell particles at all,
for any spell.**

ADR-008 had previously logged a related but distinct symptom as a
"known accepted cosmetic limitation": classic Titanium-era spell
effects "do not emit correctly from the caster's hands," attributed to
an assumed RoF2 engine-level incompatibility, not investigated
further at the time.

This investigation started from a specific working theory (that
`spellsnew.eff`, `spellsnew.edd`, `spells_us.txt`, and `spells_new`'s
`spellanim` column had drifted out of alignment with each other) and,
through validation, found the actual cause to be different from that
theory, and different from ADR-008's assumed engine limitation.

## Investigation Summary

1. **`eqclient.ini` particle settings ruled out.** `SpellParticleDensity`
   and related density/opacity settings were confirmed at correct
   values (`1.000000`) in-client; not the cause.

2. **`spellanim` indices are not out of range.** Decoded the binary
   record format of both files (`spellsnew.eff`: 268-byte records, no
   header; `spellsnew.edd`: 416-byte records, 424-byte header) and
   cross-referenced every `spellanim` value across all 40,722 rows of
   `spells_new`. All real values fall within 1–417 (one outlier at
   3411, an unused/junk value), comfortably inside the live files'
   418/2,117-record range. No index-level misalignment exists.

3. **`spellsnew.eff`/`.edd` are not corrupted.** Traced the live files'
   true origin to `P99FilesV62.zip` (exact byte-size match) and
   compared record-by-record: 412/418 (`.eff`) and 2,112/2,117
   (`.edd`) records are byte-identical to source; the handful of
   differences are trivial cosmetic cleanups (e.g. stray index-number
   suffixes stripped from names), not corruption. `spells_us.txt` is a
   straight `CONCAT_WS` export of `spells_new` (confirmed from
   `client_files/export/main.cpp` / `SpellsNewRepository`) and carries
   no independent drift.

4. **Actual root cause: missing texture assets.** Decoded the texture
   filename field of every `spellsnew.edd` record (309 distinct
   textures referenced across 2,117 records) and checked each against
   the live client. The `SpellEffects/` folder — which holds the
   actual sprite images the effect definitions point to — was
   **41 files short** of a known-good reference: a separately
   FV Project-patched client at `C:\Users\Jatyr\Desktop\FV`, built by
   running FV's own patcher against a clean RoF2 install. Those 41
   missing textures are used by up to 74 effect records apiece
   (e.g. `flare_blsp50a.png`: 74 records; `spelab.tga`: 40 records),
   covering the majority of classic Necromancer (and other classes')
   spell effects. `ActorEffects/`, `EnvEmitterEffects/`, and
   `RenderEffects/` were already complete and byte-identical between
   the two installs.

This means: when FV Project's classic spell effects were originally
applied (per ADR-008, decision #3), only the effect *definition* files
(`spellsnew.eff`/`.edd`) were copied over — the accompanying texture
*images* those definitions reference were left incomplete. The effect
system was correctly triggering; it simply had no sprite to draw.

## Decision

Copy the 41 missing files from the FV-patched reference client's
`SpellEffects/` folder into the live client's `SpellEffects/` folder,
additively (no files removed or overwritten):

```
flare_blsp50a.png   flare_whsp50a.png   gena20.bmp    gena30.bmp
genab1.png          genb20.bmp          gob.png       snow.png
spelaa.png          spelab.tga          spelan.png    spelba.png
spelbb.tga          spelcb.png          spelcc.png    spelcd.tga
spelce.png          spelcf.png          spelcm.png    speldc.png
speldd.tga          spelea.png          spelja.png    speljb.png
spelka.png          spelkb.png          spella.png    spelma.png
spelna.png          speloa.png          spelpa.png    spelqa.png
spelra.png          spelrb.png          spelua.png    spelub.png
spelva.png          spelyb.png          spelyc.png    spelyd.png
spelye.png
```

Source: `C:\Users\Jatyr\Desktop\FV\SpellEffects\`
Destination: `C:\Users\Jatyr\Desktop\Full_RoF2\SpellEffects\`

No SQL/database changes are part of this decision — `spells_new`,
`spellanim`, `spellsnew.eff`, and `spellsnew.edd` were all confirmed
correctly aligned already and were **not** modified, despite that
being the original working theory motivating the investigation.

## Post-Fix Validation

Re-checked all 309 distinct textures referenced anywhere in
`spellsnew.edd` (all 2,117 records, not just currently-used ones)
against the corrected client. Result: **1 residual gap**,
`lightningsp501.dds` (used by a single effect slot, index 220).
Confirmed absent from the FV reference client as well — a pre-existing
gap in the upstream FV package itself, not introduced by or fixable
via this change. No spell in `spells_new`'s actually-used `spellanim`
range (0–417) depends on any other texture that remains missing.

## Consequences

- Spell particle effects render correctly for classic-effect spell
  slots currently in use — **confirmed in-game by project lead**
  2026-08-04.
- If a spell is later found still missing particles specifically at
  effect index 220, that is the known, explained `lightningsp501.dds`
  gap, not a new defect.
- **Corrects ADR-008's characterization** of the "particles don't emit
  correctly from the caster's hands" issue as an assumed RoF2
  engine-level limitation. The actual (or at minimum, primary
  contributing) cause was an incomplete asset copy during the original
  client patch — a straightforward, fixable data-completeness gap, not
  an engine incompatibility. ADR-008 should be read alongside this ADR
  for that item going forward.

## Open Items (Not Part of This Fix)

1. **Spell id 75 ("Sicken") has an anomalous `CastingAnim` value (255)
   with `TargetAnim` holding 44** — found during this investigation's
   validation pass but unrelated to the particle-texture root cause
   (this affects the body-cast animation for that one spell
   specifically, not particles). Not corrected as part of this ADR;
   flagged for a future, narrowly-scoped fix.
2. **`lightningsp501.dds`** — the one confirmed-missing texture with no
   available source copy in either client. Low priority (affects one
   effect slot); would need sourcing from elsewhere if ever needed.

## Related Decisions

- **ADR-008** (RoF2 Client Updates) — original application of FV
  Project's classic spell effects; this ADR corrects that entry's
  "engine-level limitation" characterization for the particle-hands
  issue specifically.
