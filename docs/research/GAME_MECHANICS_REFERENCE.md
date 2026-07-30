# Game Mechanics Reference — P99 Wiki Synthesis

**Purpose:** Pre-digested from the P99 wiki's "Game Mechanics" page (a
technical-discussion page, distinct from the more player-facing pages
used elsewhere) so that once MCP access is back, we can move straight to
checking our database/source against specific claims rather than
re-reading the wiki live. Organized by topic, with an explicit note on
what each item would require to verify (rule_values, source code, or
observed in-game behavior) and confidence level where the wiki itself
flags uncertainty.

**Important framing from the page itself:** this page explicitly warns
that some of its own numbers are unconfirmed for P99 specifically (as
opposed to stock EQEmu or Live) and invites correction — several tables
below carry that same uncertainty forward.

---

## 🔴 Priority flag: Conflicting faction tier numbers found

This page's faction section gives **different con-level thresholds**
than the dedicated Faction page used for ADR-010:

| Tier | ADR-010 (implemented, from dedicated Faction page) | This page's numbers |
|---|---|---|
| Ally | 1051+ | 1100+ |
| Warmly | 701–1050 | 700–1099 |
| Kindly | 451–700 | 500–699 |
| Amiable | 51–450 | 100–499 |
| Indifferent | -49 to 50 | -100 to 99 |
| Apprehensive | -50 to -449 | -500 to -101 |
| Dubious | -450 to -699 | -700 to -501 ("glowers dubiously") |
| Threatening | -700 to -1049 | -800 to -701 ("glares threateningly") |
| Scowls | -1050 to -2000 | below -801 |

Notably, this page's numbers land almost exactly on **EQEmu's original
compiled defaults** (1100/750/500/100/0/-100/-500/-750) — the same
defaults ADR-010 concluded were wrong. But this page's own text
explicitly flags its numbers as unconfirmed for P99 ("likely the same as
stock EQEmu but this is unconfirmed"), while the dedicated Faction page
presented its numbers with less hedging and included the historical
detail about the Ally tier's Velious-era introduction that we already
verified independently. Given that self-hedging, ADR-010's numbers
(from the more confident, dedicated source) are likely still the better
call — but this is worth a closer look before assuming it's settled,
since it's a direct wiki-vs-wiki conflict rather than a wiki-vs-EQEmu-
default one. **Action once MCP is back:** re-confirm which source is more
authoritative (check page histories/discussion, or cross-reference a
third source) before considering this fully closed.

---

## Health & Mana Calculations

- **STA-to-HP conversion is class-specific and scales with level** — a
  full table exists for level 50 and level 60 (e.g., Warrior 1 STA = 6 HP
  at level 60 vs. 4.5 at level 50; caster classes convert at roughly half
  the rate of warriors). **Check:** whether our server's HP calculation
  (likely hardcoded in source, not a rule) uses class-differentiated STA
  conversion at all, and if so, whether the rates match.
- **Iksar and Troll regenerate HP faster than other races**, with the
  bonus widening substantially at higher levels (e.g., level 60 sitting:
  7 HP/tick for other races vs. 18 for Iksar/Troll). **Check:** source
  code for a race-based regen multiplier; this is exactly the kind of
  race-flavor detail that's easy to silently omit.
- **Mana formula**: below/at 200 WIS or INT, `Mana = ((80 * Level) / 425)
  * Stat`; above 200, the multiplier drops to 40. **Check:** against our
  mana calculation source/rules — the break point at 200 is a specific,
  testable threshold.
- **Meditate skill**: +1 mana per tick per 12 skill points while sitting;
  only 2 mana/tick without any Meditate skill; only 1 mana/tick while
  standing regardless of Meditate. **Check:** source code for this exact
  ratio.

## Combat Mechanics

- **Weapon damage caps by level range**, separated into three class
  categories (Caster, Priest, Melee & Tank), each with different caps at
  the same level breakpoints (1-9/10-19/20-29/30-39/40+). This is
  foundational to itemization decisions (a high-damage weapon is wasted
  on a low-level caster). **Check:** whether this is enforced at all in
  our compiled server, and whether the specific cap values match.
- **Weapon comparison formula** shifts at level 28 when a level/delay-
  based damage bonus kicks in — not itself a server-config item, more a
  player-facing formula, but worth knowing the breakpoint exists.
- **Dual wield chance formula** — explicitly flagged by the wiki as
  **conjecture, not confirmed**: `(Level + Dual Wield skill) / MaxSkill`,
  with MaxSkill possibly 400 for most classes but 475 specifically for
  Warriors (also unconfirmed). Low-confidence item; worth checking our
  source code's actual formula rather than assuming this table is right.
- **Max damage / "Advanced Max Damage" formulas** — a very detailed
  multi-step calculation (Wrath, weighted D20 roll, Extra Percent,
  critical hit multipliers) with class-specific `maxExtra`/
  `maxExtraChance`/`minusFactor` tables. Many values in these tables are
  themselves marked with "?" by the wiki as unconfirmed even within the
  P99 community. This is deep engine-level combat math, not something
  adjustable via rule_values — verification here means checking whether
  our EQCode source's constants match this table, and is a much heavier
  lift than most other items in this document. Lower priority given the
  effort-to-confidence ratio, but flagged for completeness since it
  directly determines melee damage output server-wide.
- **Weighted D20 roll** — the underlying to-hit/damage-variance roll,
  incorporating attacker Wrath and defender AC/Defense/Agility. Engine-
  level, not configurable.
- **Weapon proc rate**: roughly `(DEX / 170) + 0.5` procs per minute for
  main hand, half that for offhand. **Check:** against source code.
- **Backstab damage formula**: `Weapon Damage * ((Backstab Skill * 0.02)
  + 2) * 2 * maxExtra`, with maxExtra scaling by level tier (210 → 285
  from level 1 to 60). **Check:** against source.
- **NPC max melee damage (rough estimate only, per the wiki)**: roughly
  `2 * NPC level + 2` for normal classic-zone NPCs, with a flat +20 bonus
  for Giants and Spectres. The wiki itself presents this as a rough
  community estimate, not a confirmed formula — worth checking against
  actual NPC data patterns rather than assuming precision.

## Faction System (see priority flag above for the tier-number conflict)

Beyond the numeric thresholds, several **structural** mechanics are
described that are worth checking independently of the tier-number
question:
- Faction is calculated from a sum of modifiers: god, race, class,
  personal (quest/kill history), spell-based, NPC-specific override, and
  a zone modifier (described as "almost always zero").
- Invisibility, camouflage, sneak, hide, and invis-vs-undead all
  **set effective consider to indifferent (0)** against NPCs that don't
  see through them — a mechanic directly relevant to any stealth-based
  quest step (several of the class epics we just documented rely on
  exactly this).
- Enchanter faction-buff spells (Alliance +100, Benevolence +200,
  Collaboration +300) **do not stack** — only one can be active, and
  they overwrite each other rather than adding.
- **Illusions change your effective faction** to that of the illusioned
  race — the wiki gives a concrete example where the same player cons
  very differently to two different NPCs depending on which race
  illusion is active. This directly matters for any quest step involving
  charming or illusion (several epic quest steps use exactly this).
- Charisma has **no effect** on consider/faction (distinct from its
  effect on vendor pricing, which is a separate mechanic).
- Factions are **not interrelated** — changing standing with one faction
  does not affect a different, separately-tracked faction, even for
  thematically related groups.

## Encumbrance

- Weight limit is STR-based; exceeding it reduces movement speed and
  Agility (which in turn reduces AC).
- **Monks have a separate, earlier AC-loss threshold** that scales by
  level (14.9 pre-15, up to 24.9 at level 60) — they lose their class AC
  bonus at this lower weight before normal encumbrance rules also kick
  in at the standard threshola. **Check:** this is a specific, testable
  set of numbers per level bracket.

## Simulated Respawn ("Earthquake")

- A manually-triggered, full-world mob respawn (including raid targets),
  simulating classic server-restart behavior. Reported as happening 0-3
  times per month as of a Nov 2018 note. This is a GM/staff action, not
  a server-config item — not directly actionable for our project, but
  worth being aware of as a concept if we ever want similar functionality
  on our own server.

## Miscellaneous confirmed P99 mechanics (grab-bag, but individually testable)

Grouped by the wiki's own subheadings. Each of these reads as a discrete,
checkable behavior — worth spot-checking against our EQCode source once
MCP is back, since many are specific numeric thresholds rather than
vague descriptions:

**General:**
- Moving targets (not from fear/flee) take 66% damage from DoTs.
- 200+ Bind Wound skill allows binding up to 70%.
- Rogues can only assassinate humanoid targets.
- One in-game day = 72 real minutes; night is most commonly 9pm-7am,
  varying by zone.

**NPC behavior:**
- Level 56+ NPCs are immune to stun.
- NPCs level 50+ can be taunted (Blue server).
- NPCs can gate starting at 20% health, regaining 25% HP after gating.
- NPCs don't aggro within 3 seconds of spawning and are immune to
  non-targeted AEs in that window.
- Direct vs. indirect hate distinction affects whether aggro can transfer
  between NPCs, with sneaking as the only way to prevent direct-hate
  transfer.

**Spells:**
- Detrimental AE spells cap at 25 targets (a P99-specific change dated
  Sept 2016, explicitly to prevent an exploit — this postdates classic
  by many years but is presented as an intentional P99 design choice
  rather than an era-accuracy question).
- Level 51+ buffs have minimum-recipient-level restrictions (e.g., a
  level-52-max spell can't land on a level 40 character; scales up to
  "all spells" at level 45+).
- Giants and Dragons can no longer be stunned or mesmerized.

**Melee:**
- Player attack delay has a floor of 5.
- Offhand double attack requires Double Attack skill ≥ 150.
- All Hand-to-Hand weapons are treated as 1H Blunt (a specific dated
  change, Feb 2012 — worth knowing this is a P99-side reclassification,
  not originally-classic).

**Pets:**
- Solo pet XP split: pet takes half the kill's XP if it did >50% of the
  damage; no pet XP split at all while grouped.
- Higher-level Magician/Necromancer/Shadow Knight pets auto-dual-wield
  (Blue only); otherwise pets only dual wield if given two weapons.

**PvP-specific:** a long list of Red99-focused mechanics (root/snare
resist tiers, spell damage percentage, stun caps, etc.) — flagged as
existing but **not relevant to our server**, since Angels Misfits is a
non-PvP, cooperative solo/multibox environment. Not included in detail
here; can revisit if that ever changes.

## Not included in detail (informational/theorycraft, not verification targets)

- The "Descriptive Statistics and the EQ Magic System" section is a
  lengthy player-written essay (originally published elsewhere in Nov
  2000) comparing spell mana-efficiency across classes using several
  derived metrics (damage-per-mana, damage-per-tick, full-mana-damage,
  full-mana-ticks). It's a useful conceptual lens for evaluating spell
  balance, but isn't itself a claim about our server's configuration —
  nothing here to directly verify against our database. Worth returning
  to only if we want a framework for evaluating whether our spell data
  (already audited in ADR-004/009) produces reasonable class balance.
- Corpses, Experience, and Vendor Pricing sections on this page just
  redirect to their own dedicated wiki pages rather than containing
  independent content — Vendor Pricing's dedicated page is already
  covered by our merchant pricing work.

---

## Suggested verification order once MCP is back

1. **Resolve the faction tier-number conflict** (highest priority — we
   already implemented one version).
2. **HP/Mana formulas** (STA-to-HP by class, race regen bonus, mana
   formula break point, Meditate ratio) — foundational, character-facing,
   and relatively easy to check against source.
3. **Weapon damage caps by level/class** — directly affects itemization
   decisions and is a clean, discrete table to verify.
4. **Encumbrance thresholds** (general + Monk-specific).
5. **The "Miscellaneous" grab-bag** — spot-check the ones most likely to
   affect our actual gameplay (NPC gate/aggro behavior, DoT movement
   penalty, buff level-restriction table) over the more obscure ones.
6. **Combat damage formulas** (max damage, weighted D20, proc rates,
   backstab) — treat as lower priority given the effort-to-confidence
   ratio the wiki itself acknowledges with its many "?" marked values.
