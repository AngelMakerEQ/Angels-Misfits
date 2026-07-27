# ADR-008: Client-Side Classic Visual Restoration (Phase 1)

## Status - Partially Implemented — core changes complete, known issues open, additional workstreams pending.

## Context

RoF2 is the target client for compatibility reasons, but the project's design goals call for a visual presentation that more closely resembles the Classic/Kunark/Velious era rather than RoF2's default (Luclin+) presentation. This ADR documents the first phase of client-side changes made toward that goal, covering player/NPC models, zone files, spell visuals, and UI.

Primary file source for this phase: **FV Project** (fvproject.com), specifically their published "Zone Files" and "Client" pages. Provenance of individual files beyond "sourced from FV Project" has not been independently verified against Trilogy/Titanium originals.

This ADR is intended to serve as the single client-side ADR for this project unless a future change is large or independently scoped enough to warrant its own record.

## Decisions Made

### 1. Luclin Player Models — Disabled via Individual Race Settings

- Luclin models were disabled using the **per-race client settings** (in-game Options screen / individual `UseLuclinX` lines in `eqclient.ini`), **not** the blanket `AllLuclinPcModelsOff` override.
- **Rationale:** The blanket override was tested first and rejected — it removes Luclin models globally with no granularity, and does not allow future per-race exceptions (see Open Items).
- **Known engine limitation (accepted, not fixable):** Humanoid NPCs that use one of the 12 true playable race IDs (Human, Barbarian, Erudite, Wood Elf, High Elf, Dark Elf, Half Elf, Dwarf, Troll, Ogre, Halfling, Gnome) cannot have their model selection (old vs. Luclin) set independently from player characters of that same race. This is a client-side (`eqgame.exe`) hardcoded behavior tied to the race ID itself, not a data file (GlobalLoad.txt / zone `_chr.txt`) setting, and is not overridable while the NPC retains its original playable race ID.
  - Practical effect: since Luclin models are off, all humanoid NPCs sharing playable race IDs (e.g., guards) currently render with classic models, consistent with the project's goals.
  - Accepted tradeoff: true separation of PC-vs-NPC appearance for shared playable races is not achievable without reassigning affected NPCs to a non-playable/lookalike race ID — which was explicitly rejected, as it would mean the NPC is no longer genuinely its original race.

### 2. Classic Zone Files — Added via FV Project

Two distinct categories of zone files were added, sourced from FV Project's Zone Files page (page as of its Jan 2020 revision):

- **Category A — Missing/Corrective files** (functional necessity, not a style decision): Arena, CSHome, Commons, East Commons, Freeport East, Freeport North, Freeport West, North Ro, Toxxulia. These files were noted by FV as potentially missing from a stock RoF2 install, which could otherwise cause zone load issues.
- **Category B — "Old version" overrides** (deliberate classic-appearance reversion): Highkeep, Highpass, Highpasshold, Lavastorm, Nektulos. These explicitly replace RoF2's current/revamped zone geometry with the classic version.
- Files were applied selectively — only files that were either genuinely missing or explicitly marked as "old version" overrides were moved over; no blanket replacement was performed.
- **Note:** None of the zones on FV's list are Velious-era content. This phase addresses classic-continent atmosphere only. Velious zone visual research is a separate, not-yet-started workstream.

### 3. Spell Icons, Spell Gems, Spell Effects, and Skeleton Models — Updated via FV Project

- All four were sourced from FV Project's Client page and applied.
- `spells_us.txt` was **intentionally not updated** — this was a deliberate decision, not an oversight, to preserve current RoF2 spell name/description/AA data integrity while still reverting the visual/particle assets (`spellsnew.eff`/`.edd` and related files).
- **Known accepted cosmetic limitation:** classic spell effects have a longstanding, community-documented issue where particle effects do not emit correctly from the caster's hands. This is understood to be an engine-level limitation, not something expected to be fully resolved.
- **Known accepted functional limitation:** using classic spell effects/animations on an RoF2 client may disable the ability to right-click an empty spell slot to memorize a spell from a dropdown list. This was accepted as a minor QoL tradeoff.

### 4. UI — TaipoUI (RoF2-compatible build)

- **Rejected candidates and why:**
  - **Defiance** — tested twice.
    - First attempt: rejected for having icons/fonts that felt too modern, despite being clean, RoF2-native, and having no compatibility issues at that stage.
    - Second attempt: revisited because its overall approach fit project needs better than TaipoUI. Ultimately rejected again due to two functional barriers:
      1. The target information window/section was oversized, and its associated image did not resize with the window — it was cut off instead of scaling.
      2. RedGuides' Very Vanilla (VV) precompiled MQ2 build lost target-information-related functionality as a result of this same UI element, indicating a compatibility conflict between Defiance's target window and VV.
    - **Forward-looking note:** Given the project's goal of treating VV/MQ as a supported player-facing component, any future custom UI candidate should be explicitly checked for VV compatibility (particularly around target/info windows) before adoption, not just visual style and RoF2 load-success.
  - **SARS UI** (client-bundled version) — tested (already present in `uifiles\sars\` in the RoF2 client install); rejected, reason not further diagnosed. Community-documented SARS-for-RoF2 packages exist but generally require assembling third-party compatibility patches from older (c. 2013–2015) threads; this path was not pursued given the bundled version was already disliked.
  - **"Default Old Interface" by Drakah** — evaluated but **not installed**. Determined to be actively maintained for the current **Live** client (tracking recent Live expansions/features such as Overseer and Laurion's Song), not built for or verified against RoF2. Rejected due to compatibility risk, not appearance.
  - **DuxasUI** — originally listed as a compatibility target in the project's initial setup, but confirmed during this phase to be a Titanium-only UI with no RoF2 port. Retained as a style reference only (known for supporting classic-style spell gems), not a usable base.
- **Selected:** TaipoUI, using the download build specifically labeled RoF2-compatible.
- **Reasoning for concern flagged going in:** informal comparison suggested Taipo may be visually similar to DuxasUI (i.e., a modern-leaning UI with some classic accommodations) rather than a fully classic-styled icon/font set. This was accepted as the best available option after ruling out the alternatives above.

## Current Known Issues

1. **Spell icon mismatches.** Observed on a level 12 Cleric: a spell that increases magic resistance is displaying a snowflake (cold-associated) icon rather than an appropriate magic-resist icon. Root cause not yet isolated between two candidate sources:
   - The FV Project spell icon/gem file set, or
   - TaipoUI's own icon set/mapping.
   - **Status:** Open, not yet diagnosed.

## Future / Open Items

1. **Diagnose spell icon mismatch (Current Issue #1).** Recommended approach: isolate variables by testing FV spell icons against the RoF2 default UI (without TaipoUI) to determine which source owns the mismatch, before assuming either file set is fully at fault.
2. **Loading screens.** Currently displaying RoF2-era expansion art rather than Classic/Kunark/Velious art.
   - **Preferred solution:** Identify and implement a method to replace loading screen art with Classic/Kunark/Velious-era art. Not yet researched.
   - **Fallback solution:** Disable loading screens entirely via the in-game options menu, which results in a plain loading bar over whatever was last rendered on screen. Considered acceptable but lower priority than a true art replacement.
   - Not considered large/complex enough to warrant its own ADR at this time.
3. **Troll/Ogre Luclin models.** Open decision, deliberately deferred — may enable Luclin models specifically for Troll and/or Ogre via individual per-race settings, purely for aesthetic reasons (classic models considered unusually unappealing for these two races by project lead). Independent of the NPC/PC model-sharing limitation noted in Decision #1 — same tradeoff would apply if enabled (NPCs of these races would also render as Luclin).
4. **Velious-era zone visual research.** Not yet started. FV Project's Zone Files list covers only classic-continent zones; Velious zones (Great Divide, Iceclad, Kael, Skyshrine, Thurgadin, Velketor, Crystal Caverns, Western/Eastern Wastes, Cobalt Scar, Wakening Land, Sirens Grotto, Dragon Necropolis, Temple of Veeshan) require a separate, likely less-documented research pass.
5. **Marketplace/Krono UI cleanup.** Not yet addressed under TaipoUI specifically.
   - Marketplace window (`EQUI_MarketplaceWnd.xml` and its entry point(s), e.g. possible attachment to the main EQ menu button) needs to be checked/hidden within TaipoUI's file set.
   - Krono is a database/content concern, not a UI concern — needs verification that the Krono item does not exist in Angels Misfits' item database (relevant to a future database audit pass, not this ADR's scope).
6. **General verification pass (deferred by project lead).** Models, skeleton textures, spell effects, spell icons/gems, and Luclin-off behavior have not yet been formally verified in-client beyond incidental observation (e.g., the spell icon issue above was found this way). A full pass — checking multiple races/NPCs, casting a range of spell types, confirming no broken/faceless models — remains outstanding.

## Related Decisions

- FV Project's client-side patcher (`eqemupatcher`) was evaluated and **rejected as a source** for these changes, as it syncs a client to FV's own hosted server file list rather than serving as a neutral classic-restoration tool. All files in this ADR were manually sourced from FV's static download pages, not applied via their patcher.
