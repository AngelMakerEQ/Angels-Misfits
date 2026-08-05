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

### RoF2 Material Serialization Follow-up (Cross-Cutting)

The RoF2 client patch that stops race 60 from being forced to texture 0 is
necessary, but it is not sufficient by itself for every actor delivery path.
Testing with `skel_pet_37_` established that an ordinary NPC spawn correctly
receives its configured material and size, while the same NPC type created as
a player pet did not receive its material data in the RoF2 spawn packet.

The server-side correction in `common/patches/rof2.cpp` makes the RoF2 encoder
include equipment/material data whenever `emu->is_pet` is set. It is
intentionally generic: it applies to every client-owned pet and summon using
RoF2, rather than to a particular Necromancer template or character.

This is an engine compatibility fix, not a replacement for a content audit.
Before declaring race-60 rendering complete, validate all applicable actor
paths after deployment:

- ordinary NPC spawns, including texture 0 and nonzero texture variants;
- permanent pets and temporary/summoned pets for every class;
- player and NPC illusion spell effects, including explicit size values; and
- zoning, reconnecting, and respawning for each of those paths.

Do not use the GM `#texture` command as a validation substitute. It sends an
illusion appearance update; for race 60 that update can apply the client
default 4.0 size. Test through the normal spawn or spell path instead.

### Verification

- Live database confirmed (via independent connection) to show `effectid`
  89 with `effect_limit_value` 6 in the designated slot for all six spells.
- In-game: Call of Bones cast on Angel (Level 40 Iksar Necromancer) held at
  correct height following cache rebuild and server restart.

### Implementation Status

**Implemented and verified 2026-08-02.** All six spell rows updated and
confirmed live; in-game height confirmed correct on cast.

---

## Part 2: Necromancer Pet Model Race Correction (485 → 85)

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

**Pending.** SQL drafted; not yet applied to the live database as of this
writing.

```sql
UPDATE npc_types
SET race = 85
WHERE race = 485
AND id IN (
    -- Emissary of Thule (skel_pet_47_)
    628, 905, 907, 906,
    -- Legacy of Zek (skel_pet_61_)
    629, 908, 909, 910, 911, 912,
    -- Saryrn's Companion (skel_pet_63_)
    630, 913, 914, 915, 916, 917,
    -- Child of Bertoxxulous (skel_pet_65_)
    631, 918, 919, 920, 921, 922,
    -- Lost Soul (skel_pet_67_) — id 793 excluded, already at race 85
    632, 789, 790, 791, 792, 840, 841,
    -- Dark Assassin (skel_pet_70_)
    843, 633, 784, 785, 786, 787, 788, 842
);
```

Verification query (all 38 rows in the chain should show `race = 85` once
applied):

```sql
SELECT p.type, n.id, n.name, n.race, n.texture, n.size
FROM pets p
JOIN npc_types n ON n.id = p.NPCID
WHERE p.type IN ('skel_pet_47_','skel_pet_61_','skel_pet_63_',
                  'skel_pet_65_','skel_pet_67_','skel_pet_70_')
ORDER BY p.type, n.size;
```

Unlike `spells_new`, `npc_types` is read live by zone processes at zone
boot rather than through the `shared_memory` cache — a Spire restart alone
should be sufficient to pick up this change, without a `shared_memory.exe`
run.
