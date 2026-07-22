# Angels Misfits Design Philosophy

## Purpose

Angels Misfits is a private EverQuest Emulator project focused on creating a personal EverQuest experience that preserves the atmosphere, identity, and gameplay philosophy of classic EverQuest while allowing carefully considered improvements that support long-term enjoyment, administration, and maintainability.

The goal is not to recreate every historical limitation of classic EverQuest.

The goal is to recreate the feeling of playing classic EverQuest.

---

# Core Principles

## Preserve What Players Experience

Historical authenticity is most important in areas that directly affect the player's experience.

Prioritize authenticity in:

- World design
- Zone atmosphere
- NPC placement
- NPC behavior
- Encounters
- Loot
- Itemization
- Progression structure
- Class identity
- Visual presentation
- Encounter and reward pacing

These systems define the identity of EverQuest and should be changed carefully.

---

## Improve What Players Do Not Notice

Outside of gameplay-defining systems, prioritize solutions that improve:

- Maintainability
- Stability
- Administration
- Debugging
- Development workflow
- Compatibility
- Future expansion potential

A technical limitation should not be preserved simply because it existed historically.

---

# Authenticity vs Practicality

Historical accuracy is a guiding principle, not an absolute requirement.

When authenticity conflicts with:

- Server stability
- Long-term maintenance
- Compatibility
- Administration
- Quality-of-life improvements

Evaluate the tradeoffs and choose the solution that best preserves the overall EverQuest experience.

Prefer:

"Authentic where players notice."

"Practical where they do not."

---

# Expansion Philosophy

Velious is the initial design target and primary reference point.

However, Angels Misfits is not permanently limited to Velious.

Future expansion into later eras, including Luclin or Planes of Power, remains possible if it supports the overall project goals.

Velious represents the foundation of the project rather than an irreversible restriction.

Future changes should preserve the established design philosophy regardless of expansion scope.

---

# Solo Player Philosophy

Angels Misfits is designed around a private solo gameplay environment.

Quality-of-life improvements are acceptable when they improve playability without removing the core EverQuest experience.

Potential improvements may include:

- Reduced or removed death penalties
- Adjusted experience rates
- Improved solo viability
- Reduced unnecessary downtime
- Administrative conveniences
- Personal progression adjustments

These changes should preserve meaningful progression, exploration, character growth, and accomplishment rather than simply reducing the game to a faster completion experience.

The goal is not identical historical pacing.

The goal is maintaining the feeling of progression while adapting EverQuest for a solo environment.

---

# Client Philosophy

The RoF2 client is the current technical compatibility target.

RoF2 was selected primarily because of Very Vanilla MQ Emulator compatibility and compatibility with the current EQEmu ecosystem.

Titanium-era clients more closely represent the historical era being targeted but may introduce limitations in compatibility, tooling, and supported features.

The project should evaluate restoration of classic-era presentation where practical, including:

- Classic zone visuals
- Classic loading screens
- Classic UI presentation
- Historical atmosphere

Client improvements should preserve compatibility while moving the experience closer to the desired classic presentation.

---

# Character Model Philosophy

Player choice should be preserved where possible.

Luclin player models should remain available as an optional player choice.

NPC visual presentation should prioritize classic-era appearances.

Luclin-era NPC replacements should not be used unless intentionally chosen for a specific design reason.

---

# Customization Philosophy

Custom systems should exist only when they improve the overall player experience or solve a meaningful limitation.

Before creating custom implementations