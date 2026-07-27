# Rain of Fear 2 Client (RoF2)

## Purpose

The Rain of Fear 2 (RoF2) client is the current target client for Angels Misfits.

RoF2 was selected primarily because it provides strong compatibility with the current EQEmu ecosystem and supports Very Vanilla MQ Emulator (VV MQ) compatibility.

While Titanium-era clients more closely represent the historical era being targeted, RoF2 provides practical advantages for a modern EQEmu development environment.

Base client currently in use: sourced from AddictedDads ("RoF2_Full.zip"), used strictly as a pristine base client. All era-specific customization is sourced separately — see below.

---

# Player Models

## Player Characters

Luclin player models are currently **disabled**, set via individual per-race client settings (not the global override). This is a player preference and may be revisited per-race in the future (e.g., Troll/Ogre).

## NPCs

NPC visual presentation uses classic-era models by default for non-playable NPC races. For NPCs sharing a playable race ID (e.g., humanoid guards), model appearance is tied to the same client-side setting as player characters of that race — this is a confirmed engine-level limitation, not a configuration gap. See `docs/decisions/ADR-007_NPC_MODELS.md` and `ADR-008` for detail.

---

# Zone Files

Classic-continent zone files have been applied, sourced from FV Project. This covers zone graphics and layout only — not NPC placement, spawn timers, or loot, which remain governed by the database. Velious-era zone visuals have not yet been addressed; this is a separate, not-yet-started research pass.

---

# Spell Visuals

Spell icons, spell gems, spell effects, and skeleton models have been updated to classic-style assets, sourced from FV Project. `spells_us.txt` was deliberately left at its RoF2-current state to preserve spell name/AA display accuracy.

**Known issue:** a spell icon mismatch has been observed (a magic-resist buff displaying a cold/snowflake icon). Root cause not yet isolated between the FV icon set and TaipoUI's icon mapping.

**Known limitation:** classic spell effect particles do not emit correctly from the caster's hands. This is an engine-level limitation, not expected to be resolved.

---

# User Interface

See `docs/client/UI.md` for current UI status and evaluated alternatives.

---

# Loading Screens

Currently displaying RoF2-era expansion art rather than Classic/Kunark/Velious art. Restoration method not yet researched. A fallback (disabling loading screens entirely via the in-game menu) is available but not preferred.

---

# Client Modification Philosophy

Client modifications should follow these principles:

1. Preserve RoF2 compatibility.
2. Improve classic visual presentation where practical.
3. Avoid unnecessary maintenance burden.
4. Prefer reversible changes.
5. Document significant client changes.

The goal is not to convert RoF2 into a different client.

The goal is to use RoF2 as a compatible technical foundation while moving the player experience closer to the desired classic EverQuest presentation.
