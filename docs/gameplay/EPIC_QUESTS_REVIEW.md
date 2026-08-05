# Epic Quests Review

## Purpose

This document is the single source of truth for class epic 1.0 quest research and verification status. It replaces two previously separate documents — a research reference and a later database audit — which are retired in favor of this consolidated, status-tracked version (see ADR-014).

**Status legend:**
- ✅ **Verified** — structural data (NPCs, items, scripts, drops) confirmed present and correct against the live database and active quest tree.
- 🔲 **Not yet researched** — no P99/classic-source research pass has been done for this class.
- ⚠️ **Decision needed** — a real open question requiring a project-lead call, not a research gap.

All epic 1.0 quests were introduced together shortly after Kunark's release (P99: "Epic Quests Era, added Sept 2000"), modeled on the original Paladin Fiery Avenger quest. All are in scope for a Velious-and-earlier server. This document was built directly from P99's current wiki pages, which reflect classic-corrected quest steps (not the later live-revamped versions — cross-checked against P99's Non-Classic Compendium, e.g. confirming the Cleric epic here correctly omits the revamp-only Pearlescent Fragment/Skyfire step).

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
| Paladin | — | 🔲 | 🔲 |
| Ranger | — | 🔲 | 🔲 |
| Shadow Knight | — | 🔲 | 🔲 |
| Druid | — | 🔲 | 🔲 |
| Magician | — | 🔲 | 🔲 |
| Wizard | — | 🔲 | 🔲 |
| Rogue | — | 🔲 | 🔲 |

**Conclusion for the 7 verified classes: no database update required.** All reviewed chains have the required quest NPCs, active handlers, final item IDs, and relevant static or scripted encounter/loot paths. No conflicting ADR was found — all content is Kunark/Velious-era and within ADR-001's expansion scope. This is a structural/data audit, not a substitute for a live player completing each raid-heavy chain (see Regression Checklist below).

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

## DB Verification Method (applies to all 7 verified classes)

- All primary quest NPCs have a version-0 spawn in their intended classic zone; redesign-zone duplicates are supplementary and do not replace classic entries.
- Final reward IDs and intended quest scripts agree: 10908, 10651, 10650, 10652, 5532, 20542, 20544.
- Key deterministic quest loot is present at the required rate: Ancient Blade (20670), Trunt's Head (1686), Impure Heart of Zordak Ragefire (17122), Twisted Bone Earring (20658), Undead Dragongut Strings (20526) all confirmed at 100% where the quest encounter requires it.
- Trigger-only NPCs intentionally have no permanent `spawn2` row (e.g. An Undead Bard → `#Trakanon` is script-spawned) — their absence from static-spawn queries is expected, not a gap.
- Faction-list ID 404 resolves to `Truespirit` in MariaDB (verified via direct SQL; a diagnostic helper had labeled it incorrectly by reading an NPC-faction mapping rather than the faction list itself).

**Deliberately unchanged during verification:**
- No expansion gating added — these quests are in scope through Velious and remain available under ADR-001's existing gate.
- No item `reqlevel` fields changed — classic scripts enforce level 46 on Monk hand-ins where required; existing epic reward equip requirements retain their current values pending the equip-level policy decision below.
- No rare-spawn timer or loot probability altered — reviewed chain-critical drops are already present at the required rate.

---

## Resolved Decisions

### ✅ Epic weapon equip-level requirement — left ungated (2026-08-05)

P99 requires level 46 to equip any epic weapon; P99's own documentation admits it is "unclear whether or not all epics on live required a specific level" universally, and the restriction itself exists on P99 largely to stop low-level twinking via higher-level players funneling an epic down to an alt. Per DESIGN_PHILOSOPHY.md's "authentic where players notice" principle, an equip-level gate is directly player-visible and was left as an explicit open decision pending project-lead call rather than silently inherited.

**Decision: no equip-level gate.** This server is solo/single-player for now — there is no higher-level character available to complete an epic chain and hand the reward down to a lower-level alt, so the specific twinking scenario P99's level-46 requirement guards against does not apply here. Item `reqlevel` fields for the epic reward items are left as-is (unchanged from the 2026-08-02 audit); no new restriction is being added.

**Follow-up (unconfirmed, not yet checked):** the live `reqlevel` values for the seven verified reward items (10908, 10651, 10650, 10652, 5532, 20542, 20544) were never directly queried during the 2026-08-02 audit — only confirmed *unchanged*. If any of them already carry an inherited level-46 (or other) restriction from the PEQ baseline, that would need a direct live-database check and a small `UPDATE` to actually reflect the ungated decision. If this project ever moves beyond single-player (a second real character reaches endgame), revisit this decision — the original twinking concern would then apply.

## Open Items

### Not yet researched (7 classes)

Paladin, Ranger, Shadow Knight, Druid, Magician, Wizard, Rogue. No P99-sourced structural research or database verification has been done for any of these. Scope was originally limited to the 6 active characters' classes plus Necromancer; the remaining 7 are a real gap, not an oversight to explain away.

### Shaman: True Spirit faction turn-in count

Community-reported Tiny Gem turn-ins to reach max True Spirit faction range from 13 to 80+ depending on starting point — a genuinely wide, unresolved spread. If this quest's pacing is ever meant to feel deliberate rather than arbitrary, this is the number to pin down first.

### Operational regression checklist (not a data-verification gap)

Before declaring gameplay certification on the 7 verified classes, complete one GM-assisted walkthrough per class (or a targeted final-hand-in test) and confirm server logs stay free of Lua/Perl errors. Priority order: True Spirit faction threshold progression (Shaman), Monk's two-Kaiaren sequence, Cleric's Avatar spawn, Bard's Undead Bard → `#Trakanon`, Necromancer's bone-golem spawn/loot.

### Cross-cutting notes for future verification passes

- **Shaman's quest is structurally different from the other six** — faction-driven, not item-chain-driven.
- **Multiple quests require planar content** (Fear, Hate, Sky) as kill targets — worth confirming these zones and NPCs exist correctly before assuming any chain is completable end-to-end.
- **Several NPCs are rare-spawn or long-timer** (Verina Tomb, Vessel Drozlin, Lord Bergurgle, Shmendrik Lavawalker, etc.) — worth checking spawn timer configuration matches, not just NPC existence.
- **Recurring "wrong NPC eats your item" trap pattern** (Monk's mad/sane Kaiaren, Shaman's under-faction final turn-in) — worth flagging in any future player-facing documentation so it isn't mistaken for a bug.

---

## History

This document supersedes and consolidates `docs/research/CLASS_EPIC_QUEST_REFERENCE.md` (research, compiled through 2026-07-30) and `docs/development/assessments/EPIC_QUEST_IMPLEMENTATION_AUDIT_2026-08-02.md` (database audit, 2026-08-02), both retired via ADR-014. Update this document in place as remaining classes are researched/verified or open items close — do not recreate a separate tracking document.
