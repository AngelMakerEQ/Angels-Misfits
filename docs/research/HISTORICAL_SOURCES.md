# Angels Misfits — External Research Resources

This document is a running list of external reference sources used for classic-accuracy research on Angels Misfits. Treat these as supplemental to the project's research priority order (client data > EQEmu source > P99 wiki > PEQ > archived Allakhazam/Lucy > wikis > community discussion) — these wiki/community sources sit toward the lower-but-still-valuable end of that hierarchy and should be cross-checked against source/client data where possible. The project's local "TAKP-claimed" comparison database is not part of this ranking — see `docs/research/TAKP.md` for why it's treated as an unverified starting point rather than an authoritative source.

**Note on relative confidence:** within the "wiki" tier, the P99 wiki should be treated with higher confidence than archived Lucy or Allakhazam. P99 wiki entries are actively cross-checked by its community against classic-era behavior; archived Lucy/Allakhazam snapshots are raw historical data with no such review layer, and their non-archived/live versions reflect current live EQ, not the classic era, unless the specific field is known not to have changed since then.

---

## Spawn & Content Data

- **Classic Spawn List** (FV Project, data derived August 2001): https://fvproject.com/index.php/Classic_Spawn_List
- **Content Flags / Mob Spawn Changes** — legacy item drop list; items that dropped in Classic/Kunark/Velious but were later changed or removed (FV Project): https://fvproject.com/index.php/Content_Flags#Mob_Spawn_Changes
- **Expansion Content Filtering docs** (EQEmu) — use for toggling content on/off by era more cleanly: https://docs.eqemu.dev/server/expansions/expansion-content-filtering/

## Patch & Zone History

- **EQ Live Patch History** (FV Project): https://fvproject.com/index.php/Category:EQLive_Patch_History
- **Historical Zone Release and Revamp Timeline** (FV Project): https://fvproject.com/index.php/Historical_Zone_Release_and_Revamp_Timeline
- **Zones list, Velious and earlier** (P99 wiki): https://wiki.project1999.com/Zones

## Items

- **Removed Items compendium** (P99 wiki) — items changed/removed across Classic, Kunark, and Velious.
  **Project decision: restore ALL of these (Classic + Kunark + Velious), not just Velious-era changes.**
  https://wiki.project1999.com/Removed_Items
- **Non-Classic Compendium** (P99 wiki) — P99's own documented list of *intentional* deviations from pure classic behavior, with reasoning for each. Directly useful for distinguishing "verified historical behavior" from "emulator house rule" per our own research categorization standard.
  https://wiki.project1999.com/Non-Classic_Compendium
- **Statistics** (P99 wiki) — AC/HP/mana mechanics overview, including the historical hard cap on mana-from-items that existed in-era (not currently enforced on P99 itself, per the page).
  https://wiki.project1999.com/Statistics
- **Category:Legacy Items** (P99 wiki) — items intentionally present at one point in the timeline then nerfed/removed at the correct later point; useful reference for era-appropriate itemization.
  https://wiki.project1999.com/Category:Legacy_Items

## Mechanics & Skills

- **Game Mechanics overview** (P99 wiki) — reference for comparing against current server mechanics: https://wiki.project1999.com/Game_Mechanics
- **Skills page** (P99 wiki) — use to verify skill gain rates/caps and era-correct availability.
  **Status:** Sense Heading and Swimming were verified and corrected: both now
  require guildmaster training and skill up through use. See `CHANGELOG.md`.
  https://wiki.project1999.com/Skills
- **Deity combinations, classic list** (P99 wiki): https://wiki.project1999.com/Deities
- **NPC-only spells category** (P99 wiki) — player spells are being audited separately (ADR-009); this covers NPC-side spells: https://wiki.project1999.com/Category:NPC_Only_Spells

## Bard Instrument Modifiers

**Status: verified and closed.** Instrument modifiers were checked end to end;
one invalid duplicate spell was disabled and the non-classic AE DoT restriction
was reverted. See `CHANGELOG.md` for the implementation record.

- **Bard Instruments** (P99 wiki) — core mechanic explanation; instruments act as a multiplier on certain song effects, keyed to instrument skill type: https://wiki.project1999.com/Bard_Instruments
- **Thrasos' Bard Guide** (P99 wiki) — practical breakdown of which instrument skill (Singing / Brass / Wind / Percussion / Stringed) affects which songs, and notes the Bard Epic's unique behavior (acts as a flat 1.8× modifier across all instrument types with nothing equipped, and is the only item that affects Singing): https://wiki.project1999.com/Thrasos'_Bard_Guide
- **Category:Bard Instrument** (P99 wiki) — index of instrument items: https://wiki.project1999.com/Category:Bard_Instrument

## Faction

**Priority: HIGH** — directly affects merchant access, quest availability, and aggro; easy to overlook until a player notices something off.

- **Faction** (P99 wiki) — core mechanic overview: https://wiki.project1999.com/Faction
- **Category:Factions** (P99 wiki) — index of all documented individual factions, with associated quests/mobs/zones: https://wiki.project1999.com/category:factions
- **Category:Significant Factions** (P99 wiki) — the factions that matter most for progression, including Velious raid factions (Kromzek, Claws of Veeshan, etc.): https://wiki.project1999.com/Category:Significant_Factions
- **Starting Faction Standings** (P99 wiki) — default faction values by race/class at character creation: https://wiki.project1999.com/Starting_Faction_Standings
- **Historical faction tables** (P99 wiki, self-flagged as "Non-P99 Content") — raw historical data, useful as a cross-check: https://wiki.project1999.com/Historical_faction_tables
- **Faction Guide** (P99 wiki) — practical guide; also links an archived 2003-era classic faction guide: https://wiki.project1999.com/Faction_Guide

## Merchants / Vendors

**Priority: Ongoing background item** — not a single feasible audit pass (1,300+ merchant NPCs on the wiki alone); treat as spot-check-as-issues-arise, similar in scope/priority to the full quest list below.

- **Vendor** (P99 wiki) — mechanic overview: permanent vs. temporary inventory, faction gating on vendor access, pricing behavior: https://wiki.project1999.com/Vendor
- **Classic Merchant Guide** (P99 wiki) — sortable table of merchant NPCs, useful for cross-checking specific vendor stock: https://wiki.project1999.com/Classic_Merchant_Guide
- **Category:Merchants** (P99 wiki) — index of individual merchant pages: https://wiki.project1999.com/Category:Merchants

## Quests

- **Epic quests list** (P99 wiki) — includes in-depth walkthroughs per class.
  **Project decision: epics must be fully functional. Do NOT add Epic 1.5 or 2.0 (Omens of War content).**
  https://wiki.project1999.com/Epic
- **Full classic quest list** (P99 wiki) — 900+ entries.
  **Priority: LOW. Separate from epic quests. Tackle when there's little else to do.**
  https://wiki.project1999.com/Category:Quests

## Archived Reference Databases (Lucy / Allakhazam)

Per project research hierarchy, these sit above general community discussion but below the P99 wiki in confidence — see the note at the top of this document.

- **Lucy** (P99 wiki's own explainer page) — notes the original 2002-era classic-adjacent host (fnord.net) is dead; the live Allakhazam-hosted Lucy mirror still runs but reflects current live EQ: https://wiki.project1999.com/Lucy
- **Live Lucy mirror** (spell/item database) — use only for fields known not to have changed since classic: https://lucy.allakhazam.com/
- **Archived Allakhazam items-by-zone list** (Wayback Machine snapshot, Classic–Velious era): http://web.archive.org/web/20010604081241/eqdb.allakhazam.com/itemzone.html
- **Classic Research** (P99 wiki) — the wiki's own meta-guide to source reliability: explains why Lucy/Allakhazam are weak for classic-era accuracy but useful for data unchanged since then, and points to further primary sources (ShowEQ captures, decompiled client research, archived Usenet discussion). Worth reading before relying heavily on either archived database.
  https://wiki.project1999.com/Classic_Research

---

## Open Research Items (Not Yet Resourced)

Logged here as known gaps, not yet tied to a specific external source:

- **Guild mechanics** — guild halls did not exist in Velious; believed disabled via expansion selection settings (same mechanism as AA), but not yet confirmed.
- **Tradeskill recipes** — not yet covered by any resource above; classic recipe lists (components, trivial values, container requirements) likely have the same PEQ-drift risk as spells/items did.

## Access Method — P99 Wiki and FV Project

A standard `WebFetch`/browser-based fetch to `wiki.project1999.com` fails
in Claude Code's environment with a TLS certificate-chain error — it is
**not** a P99-side block. Plain `curl` (via a shell tool) bypasses this
completely and works reliably against both `wiki.project1999.com` and
`fvproject.com`, since both are MediaWiki installs exposing the standard
raw-export and batch-query endpoints:

```
curl -s "https://wiki.project1999.com/index.php?title=<Page_Name>&action=raw"
curl -s "https://wiki.project1999.com/api.php?action=query&titles=A|B|C&prop=revisions&rvprop=content&format=json&redirects=1"
```

The second form (`api.php`, `action=query`) batches up to ~50 page titles
per request — use it instead of one fetch per page for anything beyond a
handful of lookups.

**This does not work uniformly across environments.** Confirmed 2026-08-07:
a remote-Codex session connected through the desktop app hit a network-level
connection block on `wiki.project1999.com:443` — distinct from Claude Code's
TLS cert-chain issue, and not fixed by switching from the in-app browser to
`curl.exe`, since the block sits at the sandbox's network egress boundary,
before any TLS handshake. If Codex needs this data and hits the same wall,
try the local Codex CLI (`codex`, installed via npm) rather than the
remote/desktop-app session — it runs in the normal local shell with the
machine's actual network access, the same situation Claude Code's Bash tool
is in, and likely isn't subject to the same sandboxed egress restriction.
If that doesn't work either, ask Claude Code to fetch the specific pages
needed rather than retrying the same blocked path.

## Usage Notes

- When comparing a wiki entry to current server data, flag findings as one of: **Confirmed EQEmu implementation**, **Confirmed historical EverQuest behavior**, **Community consensus**, or **Reasoned inference** — per the project's research documentation standard.
- P99 has its own house rules distinct from pure historical accuracy (often anti-automation or balance-driven). Flag "P99 does it this way" separately from "this is verified classic behavior." The Non-Classic Compendium page above is P99's own record of these.
- Log source conflicts and resulting decisions in project documentation, not just in chat.
