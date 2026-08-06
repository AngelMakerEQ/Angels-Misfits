# ADR-012: Necromancer Illusion Height Correction & Pet Model Race Correction (Race 485 → 85)

**Status:** Accepted — Partially Implemented
**Date:** 2026-08-02

---

## Context

Two independent, but thematically related, necromancer-specific rendering defects
were identified and corrected during client-side classic restoration follow-up
work (post-ADR-007/ADR-008):

1. **Illusion height defect (race 60).** Player-cast illusions into race 60
   (Skeleton — the same classic race ID corrected for world NPCs in ADR-007)
   rendered at gnome-scale height rather than a normal humanoid height.
2. **Pet model era mismatch (race 485).** The necromancer's late-game skeletal
   pet line (levels 47–70) summons pets using race 485, a Luclin-era duplicate
   model of an older, classic-appropriate race (85), both carrying the same
   in-game display name ("Spectre").

Both are visual-only defects with no effect on spell mechanics, pet combat
stats, or any other gameplay system.

---

## Part 1: Illusion Height Correction (Race 60)

### Investigation

The necromancer self-illusion spell **Call of Bones** (id 643) was cast and
observed to shrink the caster to gnome-scale height, despite correctly
displaying the classic race-60 skeleton texture (confirmed after re-applying
the ADR-008 FV Project client files).

Root cause was traced directly in the EQEmu C++ source, not the client or the
database:

- `Mob::ApplySpellEffectIllusion()` (`zone/spell_effects.cpp`) — the code path
  every `SE_Illusion` effect runs through — calls
  `GetRaceGenderDefaultHeight(race, gender)` to determine a player illusion's
  displayed height whenever the spell does not explicitly override it.
- `GetRaceGenderDefaultHeight()` (`common/races.cpp`) is a hardcoded,
  per-race-ID lookup table compiled into the server binary. For race 60
  (Skeleton), the male height entry is **4.0** — Gnome/Halfling scale
  (Gnome = 3.0, Halfling = 3.5 in the same table), far below a normal
  humanoid's expected ~6.0.
- This is unrelated to client asset files (`global6_chr.s3d`, `gequip5.s3d`)
  and unrelated to any `npc_types` data — it only affects player-cast
  illusions with no explicit size override. World NPCs at race 60 are
  unaffected because `npc_types.size` is set explicitly per NPC and bypasses
  this fallback table entirely (confirmed via the necromancer's own
  `skel_pet_29_` pet template, size 6.0, which rendered correctly).
- A GM `#size 6` command, tested live while illusioned as race 60, held
  correctly with no issue — confirming the height-rendering pipeline itself
  is not broken for race 60 as a player model, only the *default* value fed
  into it by this spell.

### Decision

Rather than recompile the server to change a hardcoded C++ table (last
resort per project engineering philosophy — database/spell-data fixes are
preferred over engine modification), an explicit **`SE_ModelSize`**
(effect ID 89) override was added to each affected illusion spell, in a
previously-unused effect slot, using the *absolute-value* branch of the
effect handler (`effect_base_value = 0`, `effect_limit_value = 6`):

```cpp
else if (effect == SpellEffect::ModelSize && spells[spell_id].limit_value[i]) {
    ChangeSize(spells[spell_id].limit_value[i]);
}
```

`6` was chosen to match the necromancer's own mature-tier skeleton pet
templates (`skel_pet_11_` through `skel_pet_33_`, size 6.0) and the average
size (6.7) across the 1,626 live race-60 NPCs corrected under ADR-007 —
i.e., "what a normal-height classic skeleton already looks like elsewhere
in this database," rather than an arbitrary number.

### Affected Spells

| ID | Name | Slot used | New effect |
|---|---|---|---|
| 581 | Illusion: Skeleton (item-click) | effectid2 | ModelSize, limit 6 |
| 596 | Illusion: Dry Bone (item-click) | effectid3 | ModelSize, limit 6 |
| 643 | Call of Bones (Necro 34) | effectid8 | ModelSize, limit 6 |
| 644 | Lich (Necro 49) | effectid8 | ModelSize, limit 6 |
| 1612 | Quivering Veil of Xarn (Necro Epic 1.0 clicky) | effectid5 | ModelSize, limit 6 |
| 8508 | Quivering Veil of Xarn (duplicate row, same spell) | effectid5 | ModelSize, limit 6 |

### Deliberate Deviation Note

This does **not** conflict with ADR-004. ADR-004 verified `spells_new`'s
*mechanical* fields (mana, cast time, effect types, target types, etc.)
against classic client data. The height defect corrected here originates in
a compiled server default table (`common/races.cpp`), not in any
classic-verified spell field — the added effect is a cosmetic-only
compatibility addition, not an alteration of verified classic spell
mechanics.

### Operational Note (for future spell-data changes)

`spells_new` is not read live by the running server. Any change requires:

1. Regenerating the shared-memory cache: `shared_memory.exe spells`
   (from the server's `bin` directory).
2. A full restart of `world` and all `zone` processes (via Spire's Power
   panel stop/start) so those processes remap the freshly rebuilt cache.

A change can also silently fail to take effect if the writing tool's
connection has an open, uncommitted transaction — always confirm `COMMIT;`
was run before assuming a `spells_new` edit is live, and ideally verify via
a **separate** database connection before investing time in the
cache-rebuild/restart cycle.

## Part 2: Race-60 Skeleton Pet Material Restoration (RoF2)

#### Context

RoF2 normally forces race 60 (Skeleton) to texture 0 in the client. After
that behavior was corrected, ordinary race-60 NPCs with texture 1, including
Oasis Dry Bones, rendered red/brown at size 6. This proved the client can
render the intended classic skeleton variant.

Malignant Dead still created a white skeleton. Runtime inspection isolated
the actual content mapping:

| Actor | Race | Size | Runtime texture |
|---|---:|---:|---:|
| Dry Bones | 60 | 6 | 1 |
| `#npctypespawn 624` test NPC | 60 | 6 | 1 |
| Malignant Dead pet | 60 | 6 | 4 |

The Malignant Dead pet uses NPC template **623**, not template 624. Template
623's texture was 4 (white), while 624 was an adjacent but unrelated template.

#### Decision

Preserve the material configured on each skeleton pet's actual NPC template,
and correct the Malignant Dead template to the intended classic material.

The following changes are accepted and deployed:

1. **RoF2 client.** In `eqgame.exe`, the race-60 texture-zero branch in
   `EQPlayer::SwapNPCMaterials` is bypassed by changing the conditional jump
   at file offset `0x193F09` from `75` (`JNE`) to `EB` (`JMP`). The original
   executable is retained as `eqgame.exe.bak-race60-texture`.
2. **Database.** `npc_types.id = 623` was changed from texture 4 to texture
   1. Its race remains 60 and its explicit size remains 6. This is the
   Malignant Dead content correction.
3. **Version-matched server source.** The v23.10.3 source build now sends a
   RoF2 appearance update for skeleton pets using the texture held by the
   pet's own `NPCType` data, rather than the mutable runtime texture. This is
   invoked both when a pet is created and when a client receives zone
   appearance refreshes. The implementation is in `zone/npc.h`,
   `zone/mob.cpp`, `zone/pets.cpp`, and `zone/spell_effects.cpp`; the rebuilt
   `zone.exe` is deployed.

This design is template-driven. It does not make all skeletons texture 1:
future NPC, summon, or pet templates may use their own valid nonzero texture
and retain that selection.

#### Verification

- Oasis Dry Bones reported race 60, size 6, texture 1 and rendered red/brown.
- `#npctypespawn 624` reported race 60, size 6, texture 1 and rendered
  red/brown.
- A fresh Malignant Dead pet, after the template-623 update and server restart,
  rendered red/brown at the intended size.

#### Operational Notes

- Run content updates in HeidiSQL (or another MariaDB query editor) and commit
  the transaction before restarting the server.
- `npc_types` changes require a zone/server restart to reload; no
  `shared_memory.exe spells` rebuild is required.
- Keep the prior deployed `zone.exe` backup alongside the new binary for a
  direct rollback if a future server build is replaced.

### Implementation Status

**Part 1 implemented and verified 2026-08-02. Part 2 implemented and
verified 2026-08-05.** Part 3 remains drafted and unapplied.

---

## Part 3: Necromancer Pet Model Race Correction (485 → 85)

### Investigation

While reviewing texture assignments across the necromancer's skeletal pet
progression, the late-game tier (Emissary of Thule, level 59, through Dark
Assassin, level 70) was found to summon pets using race **485**.

Per the server's race-token reference (`GetRaceToken`), race 485 and race
**85** share the identical display name — **"Spectre"** — the same
classic-vs-Luclin dual-race-ID situation already documented and corrected
for the Skeleton race in ADR-007 (race 60 vs. 367). Race 85 is confirmed
actively present and in classic/Kunark-appropriate use elsewhere in the
live database (62 NPCs, levels 10–72, including multiple `a_spectre`
entries at levels 33–36 consistent with Kunark-era content), while race 485
is a separate, coexisting Luclin-era duplicate model (120 NPCs, levels
14–90).

One pre-existing inconsistency was found during this review: `skel_pet_67_`
tier's `_p15` power-scaled variant (NPC id 793, "Lost Soul" pet line) was
**already** at race 85 while all 37 sibling rows across the same pet chain
remained at race 485 — an apparent partial/incomplete prior change, not
something introduced by this ADR.

### Decision

Correct `npc_types.race` from 485 to 85 for all 37 remaining affected rows
across the six late-game necromancer pet template chains. Race 85's
`texture = 1` was confirmed present and valid on the live database before
committing to reuse the same texture value across the corrected rows.

**Size values were left untouched.** Every affected NPC template already
carries an explicit `npc_types.size` value (not a default-table fallback),
so the race swap has no bearing on displayed height — unlike Part 1 above,
there is no equivalent default-height risk here.

### Scope

37 NPC template rows across six pet chains, spanning Emissary of Thule
(level 59) through Dark Assassin (level 70):

| Pet chain (spell) | Rows affected |
|---|---|
| `skel_pet_47_` (Emissary of Thule) | 4 |
| `skel_pet_61_` (Legacy of Zek) | 6 |
| `skel_pet_63_` (Saryrn's Companion) | 6 |
| `skel_pet_65_` (Child of Bertoxxulous) | 6 |
| `skel_pet_67_` (Lost Soul) | 7 (of 8 — id 793 already corrected) |
| `skel_pet_70_` (Dark Assassin) | 8 |

### Consequences

- Purely a visual/model correction — no effect on pet combat stats, level
  scaling, or summon mechanics (consistent with ADR-007's precedent for
  NPC-level race corrections).
- Resolves the pre-existing inconsistency at NPC id 793 as a side effect,
  rather than requiring separate handling.
- No further "Spectre" duplicate-race content is known to exist outside
  this necromancer pet chain; a broader race 485 audit was not performed
  and remains a possible future gap if other classes' Luclin-era pets or
  summoned creatures use race 485 elsewhere.

### Spire Compatibility

No schema changes. `npc_types.race` is a standard PEQ column Spire already
edits directly, matching ADR-007's precedent.

### Implementation Status

**Drafted and committed, not yet applied to the live database.** The SQL
(preflight check, transactional `UPDATE`, verification query) lives at
`scripts/2026-08-02_necromancer_pet_race_correction.sql`. Run it via
HeidiSQL/Spire against the live database, inspect the verification query's
output, and `COMMIT` only once all 38 rows in the chain show `race = 85`.

Unlike `spells_new`, `npc_types` is read live by zone processes at zone
boot rather than through the `shared_memory` cache — a Spire restart alone
should be sufficient to pick up this change, without a `shared_memory.exe`
run.
