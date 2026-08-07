# Models

## Current State

## Player Characters

Luclin models are currently **disabled globally**, set via individual per-race client settings (not the blanket `AllLuclinPcModelsOff` override, which was tested and rejected for being all-or-nothing). This is a player-facing preference and can be changed per-race at any time.

The former Troll/Ogre Luclin-model option was dropped from tracking as a
low-stakes, fluid preference (ADR-008 addendum). All player Luclin models
remain off; revisit only if the project lead raises a specific preference.

## NPCs

Non-playable NPC races (monsters, etc.) render classic by default and are unaffected by the player Luclin setting — this is controlled independently, server-side, via race ID/model assignment.

NPCs using one of the 12 true playable race IDs (Human, Barbarian, Erudite, Wood Elf, High Elf, Dark Elf, Half Elf, Dwarf, Troll, Ogre, Halfling, Gnome) **cannot** have their model era set independently from players of that race — confirmed engine-level (`eqgame.exe`) limitation, not a config or database gap. Practical effect right now: since Luclin is off globally, these NPCs render classic. If a playable-race Luclin model is enabled in the future, NPCs of that race (for example, Troll/Ogre guards) will also render Luclin as a direct consequence.

## Skeleton Models

Corrected at the database level for 1,630 NPCs (skeleton-family), and updated at the client level via FV Project assets. See `docs/architecture/CLIENT_ARCHITECTURE.md` for the file-level manifest.

## Known Rendering Fix

`DoProperTinting` (eqclient.ini) is enabled — corrects a known RoF2-era bug where armor tint incorrectly also tints the character's skin. Relevant to classic armor visual accuracy.

## History

Full reasoning and testing: **ADR-007**, **ADR-008**.
