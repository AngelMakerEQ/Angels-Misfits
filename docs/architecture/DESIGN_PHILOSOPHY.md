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

Before creating custom implementations:
- Evaluate whether existing EQEmu functionality can accomplish the goal.
- Prefer database, rules, quests, and configuration changes before engine modifications.
- Consider long-term maintenance requirements.
- Document major design decisions.

Custom systems should avoid unnecessary complexity and should not replace existing EQEmu functionality without a clear benefit.

# Technical Philosophy

EQEmu is the technical foundation of Angels Misfits.

The project should leverage existing EQEmu architecture whenever practical while evaluating default behavior against the goals of the server.

EQEmu default behavior should not automatically be considered the desired gameplay baseline.

Existing systems should be evaluated based on:
- Intended player experience
- Compatibility
- Maintainability
- Stability
- Future development requirements

Implementation preference:

1. Existing EQEmu systems
2. Database configuration
3. Server rules
4. Quest scripting
5. Custom systems
6. Engine modifications

Engine modifications should only be considered when existing solutions cannot reasonably achieve the desired result.

# Compatibility Philosophy

Angels Misfits should maintain compatibility with the broader EQEmu ecosystem whenever practical.

Important compatibility goals include:

- EQEmu development
- PEQ database structures
- Spire
- RoF2 client compatibility
- Very Vanilla MQ Emulator compatibility
- DuxasUI compatibility

Compatibility should be preserved unless it directly prevents achieving a major project goal.

When compatibility conflicts with project goals:

1. Identify the limitation.
2. Explain available alternatives.
3. Explain the impact.
4. Recommend the approach that best supports the project.

# Historical Research Philosophy

Historical EverQuest information should be researched to understand the original design intent.

Sources should be evaluated approximately in this order:

1. Original EverQuest client assets and available historical data
2. EQEmu source code
3. PEQ database
4. TAKP database
5. Archived Allakhazam information
6. Archived Lucy information
7. Established emulator documentation
8. Community discussion

Historical information should be categorized as:

- Verified historical behavior
- Verified EQEmu implementation
- Community consensus
- Reasoned inference

When sources disagree, prioritize the implementation that best preserves the intended gameplay experience while maintaining long-term project sustainability.

# Decision Making Philosophy

When multiple approaches are possible:

Recommend the approach that:

1. Best preserves the intended EverQuest experience.
2. Maintains long-term sustainability.
3. Minimizes unnecessary complexity.
4. Maintains compatibility.
5. Uses existing systems whenever possible.

Recommendations should include:

- Preferred approach
- Reasoning
- Alternatives
- Tradeoffs

Significant changes affecting:
- Progression
- Balance
- Historical authenticity
- Client experience
- Architecture

should be documented before implementation.

# Documentation Philosophy

The AngelsMisfitsEQ GitHub repository serves as the authoritative source of truth for project decisions.

Documentation should record:

- Architecture decisions
- Database changes
- Gameplay decisions
- Historical research
- Compatibility considerations
- Custom systems
- Known limitations
- Development history

Documentation should prevent reliance on conversation history alone.

When a decision is finalized:
- Update the appropriate documentation.
- Avoid duplicating information across multiple documents.
- Reference existing documentation when information applies to multiple areas.

If documentation conflicts with a proposed change:
- Identify the conflict.
- Explain the impact.
- Request clarification before proceeding.

# Development Philosophy

Angels Misfits should be developed as a long-term maintained project rather than a collection of isolated changes.

Prioritize:

- Small, testable changes
- Reversible changes
- Documented decisions
- Clear ownership of systems
- Avoidance of unnecessary technical debt

Before significant implementation:

Evaluate:
- Current architecture
- Existing systems
- Compatibility impact
- Maintenance requirements

# Final Project Goal

Angels Misfits is intended to create a sustainable personal EverQuest experience that captures the atmosphere, exploration, progression, and identity of classic EverQuest.

The project is not intended to recreate every historical limitation.

It is intended to preserve what made EverQuest memorable while allowing thoughtful improvements that support a private, maintainable, and enjoyable long-term server experience.