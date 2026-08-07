# Client Architecture

## Purpose

This document is a structural manifest of everything that has been modified from a stock RoF2 client install. It answers "what's different from vanilla" — not why, not when, and not UI selection (see `docs/client/UI.md` for that).

## Base Client

Sourced from AddictedDads' "RoF2_Full.zip," used strictly as a pristine base install. No AddictedDads customization files are in use.

## Modified/Replaced Assets

| Category | Source | Files/Scope |
|---|---|---|
| Zone files (missing/corrective) | FV Project | Arena, CSHome, Commons, East Commons, Freeport East, Freeport North, Freeport West, North Ro, Toxxulia |
| Zone files (classic-version override) | FV Project | Highkeep, Highpass, Highpasshold, Lavastorm, Nektulos |
| Spell icons | FV Project | Full set |
| Spell gems | FV Project | Full set |
| Spell effects (particles) | FV Project | `spellsnew.eff`/`.edd` plus 41 previously omitted `SpellEffects/` texture files restored under ADR-015; `spells_new` was verified aligned and not changed for this fix |
| Skeleton models | FV Project | Classic-style skeleton models |

## Explicitly NOT Modified

- `spells_us.txt` — left at RoF2-current state deliberately, to preserve spell name/description/AA display accuracy. Not an oversight.

## Configuration-Level Changes

- Luclin player models: disabled via individual per-race `eqclient.ini` settings (not the global `AllLuclinPcModelsOff` override).
- `eqclient.ini` server pointer: updated to point to the local server rather than the EQEmu master login server.

## Known Structural Limitation

NPCs sharing one of the 12 playable race IDs (e.g., humanoid guards) cannot have model era (classic vs. Luclin) set independently from player characters of that race. This is hardcoded client (`eqgame.exe`) behavior, not a file or database setting, and is not resolvable while the NPC keeps its original race ID.

## History

Full reasoning, testing, and decision timeline for everything above: **ADR-008**.
