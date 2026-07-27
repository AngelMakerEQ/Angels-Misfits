# Rain of Fear 2 Client (RoF2)

## Purpose

The Rain of Fear 2 (RoF2) client is the current target client for Angels Misfits.

## Why RoF2

RoF2 was selected primarily for Very Vanilla MQ Emulator (VV MQ) compatibility and broader EQEmu ecosystem compatibility — **see `docs/compatibility/VV_MQ.md`**, since this is the deciding factor over clients that would otherwise better suit the project's classic-era visual goals with less restoration effort.

## Base Client

Sourced from AddictedDads ("RoF2_Full.zip"), used strictly as a pristine base install. Full detail: `docs/architecture/CLIENT_ARCHITECTURE.md`.

## What's Been Modified

See `docs/architecture/CLIENT_ARCHITECTURE.md` for the full manifest of zone files, spell visuals, and model changes. See `docs/client/UI.md` for current UI status.

## Known Issues

- **Spell icon mismatch:** a magic-resist buff has been observed displaying a cold/snowflake icon. Root cause not yet isolated between the FV icon set and TaipoUI's icon mapping.
- **Loading screens:** currently display RoF2-era expansion art rather than Classic/Kunark/Velious art. Restoration method not yet researched; disabling loading screens entirely is an available fallback.

## Client Modification Philosophy

1. Preserve RoF2 compatibility.
2. Improve classic visual presentation where practical.
3. Avoid unnecessary maintenance burden.
4. Prefer reversible changes.
5. Document significant client changes.

The goal is not to convert RoF2 into a different client — it's to use RoF2 as a compatible technical foundation while moving the player experience closer to classic EverQuest presentation.

## History

Full reasoning and testing timeline: **ADR-008**.
