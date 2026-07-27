# Models

## Current State

## Player Characters

Luclin models are currently **disabled globally**, set via individual per-race client settings (not the blanket `AllLuclinPcModelsOff` override, which was tested and rejected for being all-or-nothing). This is a player-facing preference and can be changed per-race at any time.

**Open item:** Troll and/or Ogre may be switched to Luclin models specifically, for aesthetic reasons — classic models for these two races are considered unusually unappealing by project lead. Not yet decided.

## NPCs

Non-playable NPC races (monsters, etc.) render classic by default and are unaffected by the player Luclin setting — this is controlled independently, server-side, via race ID/model assignment.

NPCs using one of the 12 true playable race IDs (Human, Barbarian, Erudite, Wood Elf, High Elf, Dark Elf, Half Elf, Dwarf, Troll, Ogre, Halfling, Gnome) **cannot** have their model era set independently from players of that race — confirmed engine-level (`eqgame.exe`) limitation, not a config or database gap. Practical effect right now: since Luclin is off globally, these NPCs render classic. If Troll/Ogre Luclin is enabled later, NPCs of those races (e.g., Troll/Ogre guards) will also render Luclin as a direct consequence.

## Skeleton Models

Corrected at the database level for 1,630 NPCs (skeleton-family), and updated at the client level via FV Project assets. See `docs/architecture/CLIENT_ARCHITECTURE.md` for the file-level manifest.

## Known Rendering Fix

`DoProperTinting` (eqclient.ini) is enabled — corrects a known RoF2-era bug where armor tint incorrectly also tints the character's skin. Relevant to classic armor visual accuracy.

## History

Full reasoning and testing: **ADR-007**, **ADR-008**.
