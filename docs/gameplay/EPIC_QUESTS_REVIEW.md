# Epic Quests Review

## Purpose

This document is the single source of truth for class epic 1.0 quest research and verification status. It replaces two previously separate documents — a research reference and a later database audit — which are retired in favor of this consolidated, status-tracked version (see ADR-014).

**Status legend:**
- ✅ **Verified** — structural data (NPCs, items, scripts, drops) confirmed present and correct against the live database and active quest tree.
- 🔲 **Not yet researched** — no P99/classic-source research pass has been done for this class.
- ⚠️ **Decision needed** — a real open question requiring a project-lead call, not a research gap.

All epic 1.0 quests were introduced together shortly after Kunark's release (P99: "Epic Quests Era, added Sept 2000"), modeled on the original Paladin Fiery Avenger quest. All are in scope for a Velious-and-earlier server. The original seven classes below were built directly from P99's current wiki pages, which reflect classic-corrected quest steps (not the later live-revamped versions — cross-checked against P99's Non-Classic Compendium, e.g. confirming the Cleric epic here correctly omits the revamp-only Pearlescent Fragment/Skyfire step).

**Source and method note for the second seven classes (2026-08-05/06):** P99's wiki was intermittently unreachable via direct fetch during this research pass (connection/certificate errors — confirmed via web search that the site itself is up, so this is a fetch-tooling limitation, not the site being down); reachable only through web search snippets for final item stats and high-level summaries. Full step-by-step structure for these seven instead came from period-contemporary archived quest guides (EQArchives corpus, mostly 2000-2003 captures — i.e. written *during* the actual classic era, arguably as authoritative as P99's own retrospective reconstruction) cross-referenced with Almar's Guides' modern condensed checklists. These were **not** individually cross-checked against P99's Non-Classic Compendium the way the original seven were, since the compendium itself wasn't reachable — no revamp-era content was flagged by any source consulted, but that specific cross-check remains a follow-up if P99 wiki access stabilizes.

Unlike the original seven (verified against the final reward and its immediate hand-in chain), the second seven received a **full deep verification pass** (2026-08-06): every named NPC, every loot-table drop and its chance, and every quest script's actual item requirements were traced directly from the live quest scripts (not just the final reward), using the EQEmu MCP's `search_quests` tool once its ripgrep dependency was fixed (see Cross-cutting notes below). This is a materially higher bar than the original seven's verification and surfaced several corrections to the archived/community source material, documented per class below.

---

## Status Summary

| Class | Epic | Research | DB/Script Verification |
|---|---|---|---|
| Warrior | Jagged Blade of War | ✅ | ✅ 2026-08-02 |
| Shaman | Spear of Fate | ✅ | ✅ 2026-08-02 |
| Enchanter | Staff of the Serpent | ✅ | ✅ 2026-08-02 |
| Monk | Celestial Fists | ✅ | ✅ 2026-08-02 |
| Cleric | Water Sprinkler of Nem Ankh | ✅ | ✅ 2026-08-02 |
| Bard | Singing Short Sword | ✅ | ✅ 2026-08-02 |
| Necromancer | Scythe of the Shadowed Soul | ✅ | ✅ 2026-08-02 |
| Paladin | Fiery Defender | ✅ | ✅✅ 2026-08-06 (full) |
| Ranger | Swiftwind & Earthcaller | ✅ | ✅✅ 2026-08-06 (full) |
| Shadow Knight | Innoruuk's Curse | ✅ | ✅✅ 2026-08-06 (full) |
| Druid | Nature Walker's Scimitar | ✅ | ✅✅ 2026-08-06 (full) |
| Magician | Orb of Mastery | ✅ | ✅✅ 2026-08-06 (full) |
| Wizard | Staff of the Four | ✅ | ✅✅ 2026-08-06 (full) |
| Rogue | Ragebringer | ✅ | ✅✅ 2026-08-06 (full) |

"(full)" = every NPC, loot-table drop, and quest-script requirement traced end to end, not just the final reward — see the DB Verification Method (second pass) section below for what that means concretely.

**Conclusion for all 14 classes: no database update required.** All reviewed chains have the required quest NPCs, active handlers, final item IDs, and relevant static or scripted encounter/loot paths. No conflicting ADR was found — all content is Kunark/Velious-era and within ADR-001's expansion scope. This is a structural/data audit, not a substitute for a live player completing each raid-heavy chain (see Regression Checklist below).

---

## Verified Classes (Research + DB Audit Complete)

### Warrior — Jagged Blade of War / Blade of Strategy & Tactics

- **Start zone:** East Freeport. **Quest givers:** Kargek Redblade, Wenden Blackhammer. **Recommended level:** 46+

**Reward:** Jagged Blade of War (2H Slashing, 36dmg/41dly, +20 STR/+15 DEX/+15 STA/+100 HP, all resists +10, Effect: Rage of Zek at level 50) — combinable into two 1H versions instead (Blade of Strategy / Blade of Tactics, 14dmg/24dly each, split stats).

**Structure:** Four components combine in the **Red Scabbard**:
- Jeweled Dragon Head Hilt — Unjeweled Dragon Head Hilt (Lake Rathe, underwater) + a gemstone, combined by Wenden.
- Finely Crafted Dragon Head Hilt — Severely Damaged Dragon Head Hilt (Timorous Deep chessboard) + Rejesiam Ore (Mentrax Mountainbone, Frontier Mountains, via a Giant Sized Monocle) + Ball of Everliving Golem (Plane of Fear), combined by Wenden.
- Ancient Sword Blade — Denken Strongpick (Ocean of Tears), traded for a Keg of Vox Tail Ale, Block of Permafrost, two Rebreathers.
- Ancient Blade — dropped by Queen Velazul Di`zok (Chardok).
- Red Scabbard — Kargek Redblade → Oknoggin Stonesmacker (Feerrott) → Tenal Redblade (East Karana), requiring Red/Green Dragon Scale kills, then the Maestro (Plane of Hate), then the Spiroc Lord (Plane of Sky).

**DB verification (2026-08-02):** Kargek Redblade and Wenden Blackhammer have the classic hand-ins; Queen Velazul Di`zok drops Ancient Blade (20670); The Spiroc Lord carries Spiroc Wingblade (20679). Recipe 9834 combines the four intended parts in Red Scabbard (17859) into 10908.

---

### Shaman — Spear of Fate

- **Start zone:** Various (begins from one of four triggering kills). **Quest giver:** "A lesser spirit" (spawns after trigger kill). **Recommended level:** 46+ to equip; entering Plane of Fear requires 46+.

**Reward:** Spear of Fate (Piercing, 20dmg/30dly, +10 STR/+10 DEX/+10 STA/+20 WIS/+30 HP/+70 MANA, all resists +10, Effect: Curse of the Spirits at level 50). Two intermediate rewards kept permanently: Shield of Falsehood (16 AC), Black Fur Boots (9 AC, Effect: Spirit of Wolf at level 10).

**Structure — unusually faction-gated rather than item-chain-driven:** progress is gated by **True Spirit** faction, built via repeatable Tiny Gem turn-ins to **Bondl Felligan** (North Freeport). Reported turn-in counts to max faction vary enormously by starting point (13 to 80+ across community reports) — **the single most important number to verify if this quest's pacing is ever meant to feel intentional.**

Path: Test of Patience (Erud's Crossing, underwater) → Test of Wisdom (kill Glaron the Wicked + Tabien the Goodly, Rathe Mountains) → Test of Might (kill Black Dire, Mistmoore) → City of Mist report-gathering (6 reports, Kindly+ required) → kill Lord Ghiosk for 3 books → Icon of the High Scale → kill High Scale Kirn (The Hole) → kill Neh`Ashiir (City of Mist, **Max Ally required**) → kill an Iksar Broodling (Plane of Fear) for a Child's Tear → kill Lord Rak`Ashiir (City of Mist, Ally required) → final turn-in to Spirit Sentinel, Emerald Jungle pond (**Max Ally required or the item is lost**).

**DB verification (2026-08-02):** Bondl Felligan starts the True Spirit path and raises live faction-list ID 404 (`Truespirit`); Spirit Sentinel enforces the intended faction thresholds; the associated City of Mist chain is present.

---

### Enchanter — Staff of the Serpent

- **Start zone:** Erudin. **Quest giver:** Stofo Olan. **Recommended level:** 46+ (50+ for the Jeb's Seal step).

**Reward:** Staff of the Serpent (1H Blunt, 11dmg/24dly, +5 STR/+10 STA/+15 CHA/+20 INT/+40 HP/+60 MANA, all resists +10, Effect: Speed of the Shissar at level 50). Intermediate reward Chalice of Kings is a real, separate item kept along the way.

**Structure:** Jeb's Seal prerequisite chain (Ink of the Dark, Mechanical Pen, White Paper → Copy of Notes → Jeb's Seal from Jeb Lumsed, Burning Woods), then four parallel "master" sub-quests combined via an Enchanter's Sack:
- 1st Piece (Test of Illusion) — Modani Qu`Loni (Overthere): Xolion Rod, Innoruuk's Word, Chalice of Kings (via Prince Selrach Di'zok's head → Joren Nobleheart), Snow Blossoms.
- 2nd Piece (Test of Enlightenment) — Mizzle Gepple (Ak'Anon): Spoon, One Key, Lost Scroll, Charm and Sacrifice.
- 3rd Piece (Test of Charm) — Nadia Starfeast (Firiona Vie): charm four named NPCs across four zones.
- 4th Piece (Test of the Phantasm) — Polzin Mrid (The Hole): Head of the Serpent (Plane of Fear), Essence of a Ghost, Essence of a Vampire (Plane of Hate), Sands of the Mystics.

All four pieces → Bundle of Staves → turned in to Jeb Lumsed. **Note:** as of a Dec 2025 P99 patch, the Jeb's Seal step is no longer optional — a P99 quest-trigger change, not an era-accuracy issue.

**DB verification (2026-08-02):** Stofo Olan, the Burning Woods imitator/Jeb chain, Modani, Nadia, and Polzin handlers are present. Mizzle Gepple is deliberately implemented as **Clockwork VIIX** in Ak'Anon, with the Jeb's Seal/Sack for Mizzle hand-ins and second staff piece (10611).

---

### Monk — Celestial Fists

- **Start zone:** Erudin. **Quest giver:** Tomekeeper Danl. **Recommended level:** 46+.

**Reward:** Celestial Fists (Hands slot, 15 AC, +20 STR/+10 DEX/+10 STA/+10 AGI/+100 HP, all resists +10, Effect: Celestial Tranquility at level 50; fist damage/delay becomes 9/16 once clickable at 50).

**Structure:** Two sub-quests feed the main chain (Monk Sash/Headband Quests, Whistling Fist, Lost Circle):
- Robe of the Lost Circle (kill Brother Zephyl/Qwinn directly, or full sash/headband chain).
- Robe of the Whistling Fists — kill an iksar betrayer (Chardok) + a drolvarg pawbuster (Karnor's Castle) for two Metal Pipes → Brother Balatin (Dreadlands).
- First Book — Immortals book (Skyfire) → Tomekeeper Danl → Danl's Reference → Lheao (Timorous Deep) → Celestial Fists (book).
- Fist of Fire/Air/Earth/Water — linear boss chain: Eejag (Lavastorm) → Gwan (Plane of Sky) → Trunt (Mines of Nurga) → Vorash/Xenevorash (Lake of Ill Omen).
- Final turn-in — the book must go to "mad" Kaiaren (Trakanon's Teeth) first, then a *separate* "sane" Kaiaren, before the final combine with Demon Fangs. **Trap:** handing items to the wrong Kaiaren permanently loses them.

**DB verification (2026-08-02):** Tomekeeper Danl, mad Kaiaren, and sane `#Kaiaren` implement the separate-book trap and final 1688+1689 hand-in, including the level-46 Monk guard and reward 10652. Eejag, Gwan, Trunt, and Xenevorash progression remains supported by their scripts/loot.

---

### Cleric — Water Sprinkler of Nem Ankh

- **Start zone:** Lake Rathetear. **Quest giver:** Shmendrik Lavawalker. **Recommended level:** 46+ (50+ for the click effect).

**Reward:** Water Sprinkler of Nem Ankh (1H Blunt, 20dmg/32dly, +10 STA/+15 CHA/+25 WIS/+100 MANA, all resists +10, Effect: Reviviscence at level 50).

**Structure:** Three elemental orbs combine, each its own chain centered on **Omat Vastsea** (Timorous Deep):
- Orb of Frozen Water — Lord Bergurgle → Shmendrik Lavawalker → spirit of flame → Natasha Whitewater → Omat Vastsea → a seeker/Plasmatic Priest (Temple of Solusek Ro) → Lord Gimblox (Solusek's Eye) → Orb of Frozen Water.
- Orb of Clear Water — Lord Gimblox's Signet Ring → Natasha Whitewater → Naxot Deepwater → Ixiblat Fer → Overking Bathezid (Chardok) → Omat Vastsea → Orb of Clear Water.
- Orb of Vapor — Natasha Whitewater → Zordak/Zordakalicus Ragefire (Nagafen's Lair) → Omat Vastsea → Orb of Vapor.

All three orbs combine via Jhassad Oceanson into the Orb of the Triumvirate, turned in to the Avatar of Water.

**DB verification (2026-08-02):** Shmendrik, Omat, Jhassad, and Avatar of Water implement the three-orb progression and final Orb of the Triumvirate hand-in for item 5532. Zordakalicus has the required 100% Impure Heart drop.

---

### Bard — Singing Short Sword

- **Start zone:** Dreadlands. **Quest giver:** Baldric Slezaf. **Recommended level:** 46+.

**Reward:** Singing Short Sword (1H Slashing, 16dmg/26dly, all instrument types 18, +15 STR/+10 DEX/+5 STA/+20 CHA/+100 HP, all resists +10, Effect: Dance of the Blade at level 46).

**Structure:** Three sheet-music pages plus a custom lute combine:
- Page 24 Top — relay race: Konia Swiftfoot → Fajio Knejo → Andad Filla → Misty Tekchita → back to Konia.
- Page 24 Bottom — Baenar Swiftsong → multi-step chain (Solusek's Eye, Unrest) → kill Maligar's Enraged Doppleganger → Mahlin's Mystical Bongos.
- Page 25 — three named-monster "gut" drops: Blackwing, Nezekezena/Phurzikon, Eldrig the Old.
- Mystical Lute — built by Forpar Fizfla (Butcherblock/Steamfont) from Head (Kedge Backbone, Amygdalan Tendril, Petrified Werewolf Skull), Body (Red/White Dragon Scales + metal bits), and Strings (Undead Dragongut Strings, via An Undead Bard → triggered Trakanon clone). **Note:** the "An Undead Bard" mechanism is wiki-dated to March 14, 2001 — post-Velious but pre-Luclin, so still in scope, just a mid-era addition rather than day-one Kunark content.

**DB verification (2026-08-02):** Baldric and Forpar implement the final and lute combines. An Undead Bard's Mystical Lute Body hand-in scripts the `#Trakanon` spawn, whose 100% loot includes Undead Dragongut Strings. Misty Tekchita is correctly spelled **Misty Tekcihta** in Lake Rathe and returns Proof of Speed.

---

### Necromancer — Scythe of the Shadowed Soul

- **Start zone:** Nektulos Forest. **Quest giver:** Venenzi Oberzendi. **Recommended level:** 46+.

**Reward:** Scythe of the Shadowed Soul (1H Blunt, 22dmg/34dly, +5 STR/+10 STA/+5 CHA/+20 INT/+20 HP/+80 MANA, resists +5 to +15 across the board, Effect: Torment of Shadows at level 50). Two smaller permanent rewards along the way: Twisted Bone Earring, Apprentice Ring.

**Structure:** A linear chain through master NPC **Kazen Fecae** (Lake Rathetear) and apprentice **Emkel Kabae**, through five named "Symbols":
- Symbol of the Apprentice — kill Sir Edwin Motte (roaming, 4 spawn points) → Kazen Fecae.
- Symbol of the Serpent — Venenzi Oberzendi → kill Najena for a Flowing Black Robe → Rolling Stone Moss → Emkel Kabae.
- Symbol of Testing — Ssessthrass (Swamp of No Hope) → Manisi Herb (Grand Herbalist Mak`ha, Chardok) → Refined Manisi Herb → Emkel Kabae.
- Symbol of Insanity — triggered 3-mob chain (bone golem → failed apprentice → tortured soul) near Emkel's spawn point.
- Gkzzallk in a Box — Drendico Metalbones (Timorous Deep): Cloak of Spiroc Feathers (Plane of Sky, via Jzil GSix), Eye of Innoruuk (Plane of Hate), Slime Blood of Cazic Thule (Plane of Fear) → Tome of Instruction → Gkzzallk (Plane of Sky, island 3) → final turn-in to Kazen Fecae.

**Note:** triggering Gkzzallk despawns that raid guild's Plane of Sky island 3 boss and blocks it until respawn — a raid-etiquette/scheduling note, not an era-accuracy detail.

**DB verification (2026-08-02):** Venenzi, Emkel, Drendico, Gkzzallk, and Kazen form the active symbol/book/box chain. The summoned bone golem has a 100% Twisted Bone Earring drop; Kazen's final hand-in grants item 20544.

---

### Paladin — Fiery Defender

- **Start zone:** Erudin (Temple of Quellious). **Quest giver (backstory):** Reklon Gnallen. **Trigger NPC:** Irak Altil (Plane of Fear, wandering indifferent undead). **Recommended level:** 46+.

**Reward:** Fiery Defender (1H Slashing, 35dmg/40dly, +20 STR/+10 STA/+15 WIS, all resists +10, +70 HP/+30 MANA, Effect: Holy Shock at level 50). The prerequisite weapon Fiery Avenger (33dmg/44dly, +15 STR/+10 CHA/+15 WIS/+25 HP/+25 MANA, all resists +5, Effect: Flame Shock at level 45) is required as a turn-in component, not just a stepping stone.

**Structure:** Fiery Avenger sub-quest first — Ghoulbane (Froglok Shin Lord, Upper Guk, rare drop) + Soulfire (a genuine separate quest via `#Brother_Hayle`, South Karana — see DB verification, not "Zimel's Blades, Freeport" as one archived source claimed) + Deepwater Knights faction (Erudin) + Lord Nagafen's and Lady Vox's dragon books → combined into Book of Scale (Blind Fish Tavern, Neriak) → traded to the Oracle of K'Arnon (Ocean of Tears) for a Phylactery → charm the Lich of Miragul (Everfrost ice caves) and hand him the Phylactery → the real Miragul spawns, kill for Head + Robe → Plane of Air: **hail Dason Goldblade → say "Heart and Soul" → choose "Dirkog"** → Dason despawns and Dirkog Steelhand spawns in his place (5-min timer) → pay 500pp → Dirkog despawns and Inte Akera spawns (5-min timer, faction-gated: Deepwater Knights ≥ Ally) → trade Soulfire and Ghoulbane as two paired "blessing" turn-ins, then both blessings + Miragul's Head/Robe → **Fiery Avenger**. Main chain: Irak Altil explains a tainted sword/shield/breastplate must be cleansed — sword (Keeper of the Tombs, The Hole) via a Pure Water sub-quest (West Freeport); shield (a rare Nektulos Forest mob) handed directly to Elia the Pure (Felwithe); breastplate (Plane of Hate) via a Pure Gem sub-quest (Kaladim mines). Cleansed pairs turned in separately to Reklon Gnallen → Mark of Atonement. Final: Mark of Atonement + Fiery Avenger to Irak Altil → **Fiery Defender**.

**Full DB verification (2026-08-06)** — every NPC and loot source in the chain, not just the final hand-in: reverse-lookup by item ID through the loot tables (far more reliable than name search, which initially missed several real NPCs) confirmed Tainted Darksteel Sword (29000) ← Keeper_of_the_Tombs (39116) 100%; Tainted Darksteel Shield (29002) ← Kirak_Vil (25301, wandering, 2 spawn points) 100%; Tainted Darksteel Breastplate (29001) ← thought_destroyer (186150, raid-flagged) 100%; Miragul's Head (19073) and Miragul's Robe (1254) ← Miragul (30094) 100% each; Ghoulbane (5403) ← two sources, Joren_Nobleheart (62000, Felwithe — also the Enchanter epic's Chalice-of-Kings NPC, a real cross-class dependency) 100% and the_froglok_shin_lord (65128) 25%. "Book of Nagafen"/"Book of Vox" turned out to be **Torn, Burnt Book** (19071, Lord_Nagafen 15%) and **Torn, Frost-covered Book** (19070, Lady_Vox 7.5%) — archived-guide nicknames, not different items. **The Dason Goldblade → Dirkog → Inte Akera chain was initially flagged as broken** (neither Dirkog nor Inte Akera has a `spawn2` row) until `search_quests` (blocked at the time by a missing ripgrep PATH entry, fixed 2026-08-06) confirmed both are deliberately script-spawned by a permanent trigger NPC — the same pattern independently confirmed on three other classes' epics (see Cross-cutting notes). Soulfire's real source (`#Brother_Hayle`, South Karana, a genuine separate classic quest culminating in defeating Xicotl at Mistmoore Castle) was found the same way after the archived source's "Zimel's Blades, Freeport" framing turned out to be simply wrong. `Reklon_Gnallen` and `Irak_Altil` both have complete, correct quest scripts; Irak_Altil's trade logic correctly requires items 29010 + 11050 together to grant 10099. Inte_Akera's script also carries unrelated, much later (TSS/Anguish-era) content in the same file, harmless and unreachable under ADR-001's gate.

---

### Ranger — Swiftwind & Earthcaller

- **Start zone:** Burning Woods (Kunark). **Quest giver:** Telin Darkforest. One of the longest epic chains, and unusual in granting **two** weapons (Ranger dual-wields).

**Reward:** Swiftwind (1H Slashing, 13dmg/21dly, +15 STR/+10 STA/+5 DEX, all resists +5, +50 HP, 40% haste, no proc) and Earthcaller (1H Slashing, 14dmg/24dly, +15 STR/+5 STA/+10 DEX, all resists +5, +50 HP, Effect: Earthcall — a 50% slow plus damage-over-time — at level 50).

**Structure:** Telin Darkforest → Worn Note → Faelin Bloodbriar (rare spawn, Greater Faydark) → Faelin's Ring → Giz X'Tin (wandering, Kithicor Forest) → Dark Metal Coin → back to Telin → Worn Dark Metal Coin → Arch Druid Althele (Karanas) → Braided Grass Amulet passed through Sionae → Nuien → Teloa (each an NPC that "walks" to the gathering point via a scripted depop/respawn relay, not a fragile spawn chain) → a gathering triggers a Dark Elf Corruptor + 2 Reavers fight (only the Corruptor must die; recommended to root him, as he cannot be pulled) → Fleshbound Tome → Althele → Earth Stained Note, continuing into a long mid/late chain (a foraged Hardened Mixture, a merchant trade chain, Rose of Firona, Black Reavers for jade, **Venril Sathir** for a Pulsing Green Stone, Jaeil the Insane, Mairee Silentone/an essence tamer, Hammer of the Ancients, Usbak the Old) → Refined Mithril Blade + Shattered Emerald of Corruption → final trade to **Xanuusus** (North Karana) → **Earthcaller**; a parallel final trade to Faelin Bloodbriar (Burning Woods) grants **Swiftwind**.

**Full DB verification (2026-08-06):** `eastkarana/Althele.pl` confirms the amulet relay end to end — handing the Worn Dark Metal Coin spawns Sionae via `unique_spawn`; Sionae's own script hands the Frayed amulet and spawns Nuien the same way; each NPC's "walk to the gathering" is a deliberate depop-and-respawn-at-new-coordinates simulation, fully intact. Dark_Elf_Corruptor (spawned via Althele's own timer chain) drops Fleshbound Tome (20452) at 100% — correcting an archived-source typo ("Fleshbound Tomb"). `burningwood/Faelin_Bloodbriar.lua` confirms her final trade requires nothing further and grants Swiftwind (20487) directly; `northkarana/Xanuusus.lua` confirms Earthcaller's real final requirement is 20483 (Refined Mithril Blade) + 20484 (Shattered Emerald of Corruption) → 20488. Confirmed real, permanently-spawned NPCs: Althele (15044, eastkarana), Faelin_Bloodbriar (54237, gfaydark), Giz_X\`Tin (20058, kithicor), Usbak_the_Old (67089), an_essence_tamer (71071 — matches the archived source's mangled "Essese Tamer"), Venril_Sathir, Xanuusus (13061, race 64/Treant). `Althele.pl` also directly encodes the Ranger/Druid shared-infrastructure relationship in code (branches on `$class == "Ranger"` vs `"Druid"`) and carries unrelated later-added "epic 1.5" content (a "cold sickness" thread) harmlessly in the same file.

---

### Shadow Knight — Innoruuk's Curse

- **Start/end zone:** City of Mist. **Quest giver:** Lhranc — a fallen paladin cursed into a deformed spectral knight after killing his own brother. **Recommended level:** 46+.

**Reward:** Innoruuk's Curse (2H Slashing, 40dmg/45dly, +20 STR/+15 DEX/+15 INT, +60 HP/+40 MANA, resists cold+10/disease+5/fire+10/magic+15/poison+5, Effect: Soul Consumption at level 50).

**Structure:** Several independently-gathered branches converge on Duriek Bloodpool (Paineel), who combines them into Corrupted Ghoulbane: Darkforge armor pieces (Temple of Solusek Ro, via Kurron Ni) → Letter to Duriek → Cough Elixir (Neriak, Smaka) → Dusty Tome (The Hole) → a Decrepit Sheath chain (Qeynos Aqueducts, via Teydar) → **Ghoulbane** (Upper Guk, Froglok Shin Lord — shared source with the Paladin epic) → Soul Leech (Plane of Fear) → Blade of Abrogation (Plane of Sky) → **Corrupted Ghoulbane**. Separately: Seal of Kastane (Kerra Ridge, Marl Kastane) → Gerot Kastane → defeat the mummified Glohnor for his head → **Head of the Valiant**. Separately: **Will of Innoruuk** (Kerra Ridge, Marl Kastane). Separately: kill Kyrenna, combine her heart in a Soulcase → **Heart of an Innocent**. Final: all four items to **Lhranc** → **Innoruuk's Curse**.

**Full DB verification (2026-08-06):** `citymist/Lhranc.lua` confirms the exact final requirement — items 14367 (Corrupted Ghoulbane) + 14368 (Heart of the Innocent) + 14369 (Head of the Valiant) + 14370 (Will of Innoruuk) together → 14383. `paineel/Duriek_Bloodpool.pl` confirms the exact Corrupted Ghoulbane combine: 18099 Letter to Duriek + 14365 Cough Elixir + 14382 Dusty Tome + 5403 Ghoulbane + 11609 Soul Leech + 5430 Blade of Abrogation + 14366 Decrepit Sheath → 14367. All 9 intermediate items and Kurron_Ni (93083), Teydar (45044), Kyrenna (39155), and Mummy_of_Glohnor (39165) confirmed live. The full 7-piece Darkforge armor set exists (quest needs 3 of the 7). **Notable side-finding:** `citymist/#Marl_Kastane.lua` grants Innoruuk's Curse via a completely separate route — trading "a token of Lhranc's" at True Spirit faction >82 (the *Shaman* epic's own faction track), explicitly tagged "Part of SK Epic 1.0" in its own source comment. A genuine, deliberate cross-class bonus path, not a bug.

---

### Druid — Nature Walker's Scimitar

- **Start zone:** Burning Woods — shares its starting NPC (Telin Darkforest) and final NPC (Xanuusus) with the Ranger epic, reflecting the two classes' shared nature theming.

**Reward:** Nature Walker's Scimitar ("Scimitar of the True Druid," 1H Slashing, 20dmg/30dly, +15 STR/+15 STA/+20 WIS, all resists +10, +10 HP/+90 MANA, Click Effect at level 50 — a click, not a proc).

**Structure (5 phases):** (1) A Worn Note chain across Greater Faydark/Kithicor Forest/East Karana/Misty Thicket, foraged items combined into a Hardened Mixture. (2) A provisioning chain from Alrik Farsight (Timorous Deep), combined on a pottery wheel into a Runecrested Bowl. (3) The bowl and mixture spawn a stone; separately kill **Venril Sathir** for a second stone; combine into an Elaborate Scimitar. (4) Three Cleansed Spirits — corrupted mob variants across Antonica, Faydwer, and Kunark, each cleansed via a regional NPC. (5) All three spirits plus the Elaborate Scimitar to **Xanuusus** → **Nature Walker's Scimitar**.

**Full DB verification (2026-08-06):** `northkarana/Xanuusus.lua` (shared with Ranger) confirms the exact final requirement — 20699 (Cleansed Spirit of Kunark) + 20697 (Cleansed Spirit of Faydwer) + 20698 (Cleansed Spirit of Antonica) + 20440 (Elaborate Scimitar) together → 20490. Sources confirmed: Cleansed Spirit of Faydwer ← Silox_Azrix (55006, akanon); Cleansed Spirit of Antonica ← Yeka_Ias (14078, southkarana); Cleansed Spirit of Kunark ← Nekexin_Virulence (93043, overthere); Elaborate Scimitar ← Ella_Foodcrafter (33077, mistythicket). All four confirmed real, permanently-spawned NPCs. `Xanuusus.lua` also carries a large amount of unrelated Ranger epic-1.5 content in the same file, harmlessly coexisting — the same pattern seen throughout this second batch of classes.

---

### Magician — Orb of Mastery

- **Start zone:** Lake Rathetear. **Quest giver:** Rykas, "chronicler of knowledge."

**Reward:** Orb of Mastery (1H Blunt, 20dmg/30dly, +15 STR/+5 DEX/+10 STA/+20 INT, +100 MANA, resists cold+20/fire+20/magic+10, Effect: Manifest Elements [summons a pet] at level 50, single-charge clicky).

**Structure — deeper than most other epics:** Rykas → Token of Mastery → Jahsohn Aksot (West Commonlands) → 3 Torn Pages of Magi'kot → Words of Magi'kot → Walnan (rare spawn, Butcherblock) → 4 Powers of the Elements → back to **Rykas**, who grants "Power of the Orb" (not the final item yet) → Akksstaff (Najena, extremely rare spawn) → 4 Torn Pages of Mastery → **separately**, four distinct "Element of X" NPCs (including **Jennus Lyklobar** for Fire, Skyfire Mountains) each require the Power of the Orb tome plus a component (including the classic Staff of Elemental Mastery pieces, e.g. Earth from **Magi P'Tasa**/Plane of Hate, Water from **Phinigel Autropos**) → the four Elements (Fire/Water/Earth/Wind) → all four to **Master of Elements** (a temporary spawn) → grants a **Spell: Summon Orb** scroll → the player scribes and casts it to **summon their own Orb of Mastery** — a distinctive, lore-appropriate mechanic unique among the 14 epics.

**Full DB verification (2026-08-06):** the real chain is meaningfully deeper than the original research captured (see Structure above); every step was traced directly from the live quest scripts. `lakerathe/Rykas.pl` confirms handin of 28003+28004+28031 grants only 18958 "Power of the Orb," not the orb itself. `skyfire/Jennus_Lyklobar.pl` confirms Element of Fire (28009) requires 18958 + 3 other items. `airplane/#Master_of_Elements.lua` confirms all four Elements (28032/28009/28006/28033) together grant item 19436 "Spell: Summon Orb" — whose `scrolleffect` correctly points to spell 1944, which has `Effect=32 (SummonItem), Base=28034`, i.e. genuinely summons the exact Orb of Mastery item (initially misread as a mismatch until the item's actual scroll-effect field, not its own ID, was checked). Master of Elements is spawned by **Kihun_Solstin** (71055, real permanent spawn, airplane zone) via `spawn2` — the same static-trigger pattern confirmed on three other classes (see Cross-cutting notes).

---

### Wizard — Staff of the Four

- **Start zone:** Temple of Solusek Ro. **Quest giver:** Solomen, a wizard historian. **Recommended level:** 46+.

**Reward:** Staff of the Four (1H Blunt, 20dmg/30dly, +10 STR/+5 DEX/+10 STA/+25 INT, +100 MANA, resists cold+10/disease+5/fire+10/magic+10/poison+5, Effect: Barrier of Force at level 50).

**Structure:** Solomen → sealed note → Camin (Erudin) — hand note for faction, pay 1000pp for lore on Arantir Karondor, one of four wizards personally tutored by Solusek Ro. Arantir's location is deliberately obscure: buy a Ro's Breath potion from a vendor named Dargon (Halas), have Camin strip its charge, return it to Dargon — she transforms into **Arantir Karondor** → Arantir's Ring → Challice (Felwithe) → continuing through Kandin Firepot → Kandin's Note back to Arantir, who assembles a Magically Sealed Bag → final delivery to Solomen → **Staff of the Four**.

**Full DB verification (2026-08-06):** `soltemple/Solomen.pl` confirms the true final requirement is a single item, 14340 "Magically Sealed Bag" → 14341. `halas/Arantir_Karondor.lua` (confirming Arantir's transformation happens in Halas) assembles that bag from 7 items (14334, 18169, 14335, 18168, 14337, 14338, 14339) — a larger combine than the original condensed research implied, but every intermediate ID resolves correctly in the live DB. Confirmed real NPCs: Solomen (80023), Camin (24004), Arantir_Karondor (29089), Kandin_Firepot (68109), Challice (61012), Dargon (29000, the vendor who becomes Arantir).

---

### Rogue — Ragebringer

- **Start zone:** Qeynos Aqueducts (Malka Rale). **Final hand-in NPC:** Stanos Herkanor (Highpass Hold).

**Reward:** Ragebringer ("Tainter of Souls," Piercing, 15dmg/25dly, bonus flat backstab damage, +20 STR/+10 AGI/+10 DEX/+10 STA, +100 HP, resists disease+10/magic+20/poison+20, 40% haste, passive worn effect, dual-wieldable).

**Structure:** Three side-quests build toward the final turn-in: a Jagged Diamond Dagger chain (four named-mob drops combined via Vilnius the Small, West Karana); a Cazic Quill chain (four robe drops, including one from Phinigel Autropos — shared with the Magician epic — also combined via Vilnius); and an optional Stanos' Pouch chain (skippable — Malka Rale hands one over for free). Main chain: Malka Rale → pickpocketed parchment halves → Stanos Herkanor combines them → Eldreth (Lake Rathe) → a Book of Souls (Plane of Hate) → Yendar Starpyre → spawns **Renux Herkanor**, killed for a Jagged Diamond Dagger + Translated Parchment → Stanos → Sealed Box → given to a night-spawning dark elf (Kithicor Forest) → spawns **General V'Ghera**, killed for a General's Pouch + Cazic Quill → all three items to Stanos → **Ragebringer**.

**Full DB verification (2026-08-06):** `highpasshold/Stanos_Herkanor.lua` (duplicated in `highpass/` — a classic/revamped zone-variant pair, same pattern as Highkeep/Highpass in ADR-008) confirms the exact final requirement — 28013 (Translated Parchment) + 7506 + 7505 → 11057 — plus a rich, fully-written backstory (the Circle of Unseen Hands, Johann/Hanns Krieghor, General V'ghera) matching and exceeding the archived source's structure. **Stanos himself turned out to be a temp-spawn** (10-min depop timer) — the fourth confirmed instance of the static-trigger-NPC pattern (see Cross-cutting notes): **Anson_McBale** (real permanent spawn, highpass/highpasshold) spawns Stanos via `spawn2`. Confirmed real NPCs: Anson_McBale, Malka_Rale (45095), Yendar_Starpyre (56012), Tani_N\`Mar (42000), General_V\`ghera (20205). Corrected naming: the archived checklist's "Vilinus the Small" is actually **Vilnius_the_Small** (12019) in the live DB.

---

## DB Verification Method (original 7 verified classes)

- All primary quest NPCs have a version-0 spawn in their intended classic zone; redesign-zone duplicates are supplementary and do not replace classic entries.
- Final reward IDs and intended quest scripts agree: 10908, 10651, 10650, 10652, 5532, 20542, 20544.
- Key deterministic quest loot is present at the required rate: Ancient Blade (20670), Trunt's Head (1686), Impure Heart of Zordak Ragefire (17122), Twisted Bone Earring (20658), Undead Dragongut Strings (20526) all confirmed at 100% where the quest encounter requires it.
- Trigger-only NPCs intentionally have no permanent `spawn2` row (e.g. An Undead Bard → `#Trakanon` is script-spawned) — their absence from static-spawn queries is expected, not a gap.
- Faction-list ID 404 resolves to `Truespirit` in MariaDB (verified via direct SQL; a diagnostic helper had labeled it incorrectly by reading an NPC-faction mapping rather than the faction list itself).

**Deliberately unchanged during verification:**
- No expansion gating added — these quests are in scope through Velious and remain available under ADR-001's existing gate.
- No item `reqlevel` fields changed — classic scripts enforce level 46 on Monk hand-ins where required; existing epic reward equip requirements retain their current values pending the equip-level policy decision below.
- No rare-spawn timer or loot probability altered — reviewed chain-critical drops are already present at the required rate.

## DB Verification Method (second 7 verified classes, 2026-08-06 — full pass)

A materially deeper standard than the original seven: every quest-critical NPC named across the source guides was traced to a real, findable live NPC (not just confirmed to exist by name), every reward and intermediate item's actual hand-in requirements were read directly from the live Lua/Perl quest scripts (not inferred from community write-ups), and every "NPC drops item X" claim was verified via a direct reverse lookup through `lootdrop_entries`→`loottable_entries`→`npc_types` rather than trusting name search alone.

- **The single most significant finding: a deliberate, four-times-confirmed "static trigger → temporary quest NPC" design pattern.** A permanent, always-findable NPC (dialogue- or item-triggered) spawns a second, temporary NPC on a short depop timer (typically 5–10 minutes) that the player must interact with before it disappears. Confirmed instances: Paladin's Dason_Goldblade → Dirkog_Steelhand → Inte_Akera; Monk's Holwin → Wu_the_Enlightened (retroactively confirms a detail the original Monk pass didn't explicitly check); Magician's Kihun_Solstin → Master_of_Elements; Rogue's Anson_McBale → Stanos_Herkanor. None of the temporary NPCs have a `spawn2` row — that is expected and correct, not a gap, for any NPC following this pattern. The trigger NPC search (`search_quests`, ripgrep-backed) was broken for part of this investigation (`WinError 2` — ripgrep was installed via WinGet but never added to the system PATH) and was fixed 2026-08-06 by adding the existing WinGet package directory to the user PATH; no change was made to the MCP server itself, so this fix is available to any client using the same server.
- Several archived-source item/NPC **nicknames differ from live database names** without being gaps: "Book of Nagafen/Vox" → `Torn, Burnt Book`/`Torn, Frost-covered Book`; "Fleshbound Tomb" → `Fleshbound Tome`; "Vilinus the Small" → `Vilnius_the_Small`; "thought corruptor" → `thought_destroyer`.
- One archived source was **factually wrong**, not the database: Paladin's Soulfire was documented as "Zimel's Blades, Freeport" but is actually a separate, genuine classic quest via `#Brother_Hayle` in South Karana.
- Several classes share real, live infrastructure: Ranger/Druid (Telin Darkforest, Althele, Xanuusus, Venril Sathir — confirmed at the script level via class-branching logic, not just inferred); Magician/Rogue (Phinigel Autropos). A future change to any of these shared NPCs would affect more than one class's epic.
- Multiple scripts carry unrelated, much-later "epic 1.5/2.0"-era content (post-TSS/Anguish) in the same file as the 1.0 logic — Paladin's Inte_Akera, Ranger/Druid's Althele and Xanuusus. Confirmed harmless (correctly gated behind items/globals the 1.0 path never sets) and unreachable under ADR-001's Velious gate; noted for era-containment awareness only.
- Several classes' true chains are **meaningfully deeper** than the original community/archived research captured — most notably Magician (an entire second "four Elements → Master of Elements → cast a spell to summon your own orb" phase) and Wizard/Rogue (larger final-item combines). Every additional step traced resolved correctly.

**Deliberately unchanged during this verification too:** same three bullets as the original-seven method above — no expansion gating, `reqlevel`, spawn timers, or loot probabilities were altered; this was a read-only audit.

---

## Resolved Decisions

### ✅ Epic weapon equip-level requirement — left ungated (2026-08-05)

P99 requires level 46 to equip any epic weapon; P99's own documentation admits it is "unclear whether or not all epics on live required a specific level" universally, and the restriction itself exists on P99 largely to stop low-level twinking via higher-level players funneling an epic down to an alt. Per DESIGN_PHILOSOPHY.md's "authentic where players notice" principle, an equip-level gate is directly player-visible and was left as an explicit open decision pending project-lead call rather than silently inherited.

**Decision: no equip-level gate.** This server is solo/single-player for now — there is no higher-level character available to complete an epic chain and hand the reward down to a lower-level alt, so the specific twinking scenario P99's level-46 requirement guards against does not apply here. Item `reqlevel` fields for the epic reward items are left as-is (unchanged from the 2026-08-02 audit); no new restriction is being added.

**Follow-up (unconfirmed, not yet checked):** the live `reqlevel` values for all fourteen verified reward items — the original seven (10908, 10651, 10650, 10652, 5532, 20542, 20544) plus the second seven (10099 Fiery Defender, 20487/20488 Swiftwind/Earthcaller, 14383 Innoruuk's Curse, 20490 Nature Walkers Scimitar, 28034 Orb of Mastery, 14341 Staff of the Four, 11057 Ragebringer) — were never directly queried across either verification pass, only confirmed *unchanged*. If any of them already carry an inherited level-46 (or other) restriction from the PEQ baseline, that would need a direct live-database check and a small `UPDATE` to actually reflect the ungated decision. If this project ever moves beyond single-player (a second real character reaches endgame), revisit this decision — the original twinking concern would then apply.

## Open Items

### All 14 classes now researched and fully DB-verified (2026-08-06)

The remaining 7 classes (Paladin, Ranger, Shadow Knight, Druid, Magician, Wizard, Rogue) were researched and given a *full* deep verification pass against the live database and quest scripts on 2026-08-06 — every NPC, loot source, and script requirement, not just the final reward — closing what had been the single largest gap in this document. See each class's section and the second DB Verification Method section above. No gaps were found; several initial false alarms (detailed above) were investigated to a firm conclusion rather than left ambiguous.

### Shaman: True Spirit faction turn-in count

Community-reported Tiny Gem turn-ins to reach max True Spirit faction range from 13 to 80+ depending on starting point — a genuinely wide, unresolved spread. If this quest's pacing is ever meant to feel deliberate rather than arbitrary, this is the number to pin down first.

### Operational regression checklist (not a data-verification gap)

Before declaring gameplay certification on any of the 14 classes, complete one GM-assisted walkthrough per class (or a targeted final-hand-in test) and confirm server logs stay free of Lua/Perl errors. Priority order: True Spirit faction threshold progression (Shaman), Monk's two-Kaiaren sequence, Cleric's Avatar spawn, Bard's Undead Bard → `#Trakanon`, Necromancer's bone-golem spawn/loot, Ranger/Druid's Sionae→Nuien→Teloa gathering sequence, Magician's Akksstaff/Master of Elements chain, Rogue's Anson_McBale→Stanos_Herkanor timing window.

### Cross-cutting notes for future verification passes

- **Shaman's quest is structurally different from the other thirteen** — faction-driven, not item-chain-driven.
- **Multiple quests require planar content** (Fear, Hate, Sky) as kill targets — worth confirming these zones and NPCs exist correctly before assuming any chain is completable end-to-end.
- **Several NPCs are rare-spawn or long-timer** (Verina Tomb, Vessel Drozlin, Lord Bergurgle, Shmendrik Lavawalker, Akksstaff, etc.) — worth checking spawn timer configuration matches, not just NPC existence.
- **Recurring "wrong NPC eats your item" trap pattern** (Monk's mad/sane Kaiaren, Shaman's under-faction final turn-in) — worth flagging in any future player-facing documentation so it isn't mistaken for a bug.
- **The "static trigger → temporary NPC" pattern is now a known, documented design element** of this content set (4 confirmed instances across Paladin/Monk/Magician/Rogue) — before ever flagging a quest NPC as "missing" for having no `spawn2` row, check whether another NPC's script spawns it first via `search_quests` for `spawn2(<npc_id>`.
- **Ranger/Druid and Magician/Rogue each share real live NPC infrastructure** across their respective epic pairs — see the second DB Verification Method section above.

---

## History

This document supersedes and consolidates `docs/research/CLASS_EPIC_QUEST_REFERENCE.md` (research, compiled through 2026-07-30) and `docs/development/assessments/EPIC_QUEST_IMPLEMENTATION_AUDIT_2026-08-02.md` (database audit, 2026-08-02), both retired via ADR-014. Update this document in place as remaining classes are researched/verified or open items close — do not recreate a separate tracking document.
