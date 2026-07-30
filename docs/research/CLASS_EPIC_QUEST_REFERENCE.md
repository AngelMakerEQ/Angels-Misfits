# Class Epic Quest Reference — Warrior, Shaman, Enchanter, Monk, Cleric, Bard, Necromancer

**Purpose:** Research reference for verifying our database has the correct
quest NPCs, items, factions, and epic weapon stats in place. Compiled from
the P99 wiki's per-class Epic Quest pages. This document captures the
structural facts needed for verification (NPCs, items, zones, final reward
stats) — not the full dialogue/roleplay text, which stays on the wiki.

**Era note:** All class epics were introduced together shortly after
Kunark's release (confirmed "Epic Quests Era, added Sept 2000" on every
page), modeled on the original Paladin Fiery Avenger quest. All are
firmly in scope for a Velious-and-earlier server. A few individual steps
within these quests have their own later implementation dates (noted
per-class below); all confirmed dates found so far still fall before
Luclin's Dec 2001 release, so remain in scope.

**Sourcing note (added after a dedicated pass through P99's Non-Classic
Compendium):** the original "1.0" epic quests were changed on live at
various points, and many epic guides found elsewhere online reflect
those later, revamped versions rather than true classic steps — P99's
own compendium explicitly warns of this and documents specific known
differences (e.g., the live/revamped Cleric epic required an extra
Pearlescent Fragment/Skyfire step that the true classic version did
not). This document was built directly from P99's current wiki pages,
which already reflect the classic-corrected versions — cross-checked
against the compendium's Cleric entry specifically and confirmed
consistent. Also worth knowing: P99 requires level 46 to equip any epic
weapon, though their own page admits it's unclear whether this was
universally true on live for every class — worth an explicit decision
if/when we implement these rather than assuming either way.

**Not yet covered:** Paladin, Ranger, Shadow Knight, Druid, Magician,
Wizard, Rogue — the other 7 classes' epics were not researched in this
pass, since the request was scoped to our 6 active characters' classes
plus Necromancer.

---

## Warrior — Jagged Blade of War / Blade of Strategy & Tactics

- **Start zone:** East Freeport
- **Quest givers:** Kargek Redblade, Wenden Blackhammer (both in East Freeport)
- **Recommended level:** 46+

### Reward
Jagged Blade of War (2H Slashing, 36dmg/41dly, +20 STR/+15 DEX/+15 STA/+100 HP,
all resists +10, Effect: Rage of Zek at level 50) — combinable in the Red
Scabbard into two 1H versions instead: Blade of Strategy and Blade of
Tactics (14dmg/24dly each, split stat bonuses).

### Key structure
Four components combine in the **Red Scabbard** for the final weapon:
- **Jeweled Dragon Head Hilt** — Unjeweled Dragon Head Hilt (Lake Rathe,
  underwater) + Diamond/Jacinth/Black Sapphire, combined by Wenden Blackhammer.
- **Finely Crafted Dragon Head Hilt** — Severely Damaged Dragon Head Hilt
  (Timorous Deep chessboard) + Rejesiam Ore (from Mentrax Mountainbone,
  Frontier Mountains, via a Giant Sized Monocle from a mountain giant
  patriarch in Dreadlands) + Ball of Everliving Golem (Fright/Dread/Terror,
  Plane of Fear), combined by Wenden.
- **Ancient Sword Blade** — from Denken Strongpick (Ocean of Tears) in
  exchange for a Keg of Vox Tail Ale, a Block of Permafrost, and two
  Rebreathers.
- **Ancient Blade** — dropped by Queen Velazul Di`zok in Chardok.
- **Red Scabbard itself** — a long side-chain through Kargek Redblade →
  Oknoggin Stonesmacker (Feerrott) → Tenal Redblade (East Karana),
  requiring kills on Red Dragon Scales (Nagafen/Talendor/etc.) and Green
  Dragon Scales (Severilous/Hoshkar), then the Maestro in Plane of Hate,
  then the Spiroc Lord in Plane of Sky.

---

## Shaman — Spear of Fate

- **Start zone:** Various (quest can begin from four different trigger
  kills)
- **Quest giver:** "A lesser spirit" (spawns after a triggering kill)
- **Recommended level:** 46+ to equip; no level restriction on the quest
  itself except entering Plane of Fear (46+)

### Reward
Spear of Fate (Piercing, 20dmg/30dly, +10 STR/+10 DEX/+10 STA/+20 WIS/+30
HP/+70 MANA, all resists +10, Effect: Curse of the Spirits at level 50).
Two intermediate rewards are also kept permanently: Shield of Falsehood
(16 AC) and Black Fur Boots (9 AC, Effect: Spirit of Wolf at level 10).

### Key structure — unusually, this entire quest is faction-gated
Rather than a linear item chain, progress is gated by **True Spirit**
faction, built up primarily through repeatable turn-ins of a Tiny Gem
(looted from a triggering kill) to **Bondl Felligan** in North Freeport.
Reported turn-in counts to reach max faction vary enormously by starting
point (13 to 80+ in different community reports) — this is the single
most i mportant thing to verify if we ever want this quest's pacing to
feel intentional rather than arbitrary.

Structural path: Test of Patience (Erud's Crossing, underwater, a long
wait-based NPC sequence) → Test of Wisdom (kill Glaron the Wicked and
Tabien the Goodly in Rathe Mountains, Shield of Falsehood reward) → Test
of Might (kill Black Dire in Mistmoore, Black Fur Boots reward) → City of
Mist report-gathering (6 reports, Kindly+ faction required) → kill Lord
Ghiosk (City of Mist) for 3 books → obtain Icon of the High Scale → kill
High Scale Kirn (The Hole) → kill Neh`Ashiir (City of Mist, **Max Ally
faction required**) → kill an Iksar Broodling in Plane of Fear for a
Child's Tear → final kill of Lord Rak`Ashiir (City of Mist, Ally faction
required) → final turn-in to Spirit Sentinel in Emerald Jungle (in the
pond, **Max Ally required or the final item is lost**).

---

## Enchanter — Staff of the Serpent

- **Start zone:** Erudin
- **Quest giver:** Stofo Olan
- **Recommended level:** 46+ (50+ to begin Jeb's Seal step)

### Reward
Staff of the Serpent (1H Blunt, 11dmg/24dly, +5 STR/+10 STA/+15 CHA/+20
INT/+40 HP/+60 MANA, all resists +10, Effect: Speed of the Shissar at
level 50). Intermediate reward Chalice of Kings is also a real, separate
item kept along the way.

### Key structure
An initial "Jeb's Seal" prerequisite chain (Ink of the Dark, Mechanical
Pen, White Paper → Copy of Notes → Jeb's Seal from Jeb Lumsed, a sarnak
imitator in Burning Woods), then four parallel "master" sub-quests, each
producing one piece of the staff, combined via an Enchanter's Sack:

- **1st Piece (Test of Illusion)** — Modani Qu`Loni (Overthere). Requires
  Xolion Rod (Vessel Drozlin, Cabilis East), Innoruuk's Word (Verina Tomb,
  Neriak), Chalice of Kings (via Prince Selrach Di'zok's head, Chardok →
  Joren Nobleheart, Felwithe), and Snow Blossoms (Oggok NPC chain).
- **2nd Piece (Test of Enlightenment)** — Mizzle Gepple (Ak'Anon).
  Requires a Spoon (Cazel, Oasis), the One Key (Overthere), the Lost
  Scroll (Dalnir), and the book Charm and Sacrifice (Plane of Sky).
- **3rd Piece (Test of Charm)** — Nadia Starfeast (Firiona Vie). Requires
  charming four separate named NPCs across four zones (Kaesora,
  Skyfire, City of Mist, Overthere) to convert dull gems into enchanted
  ones.
- **4th Piece (Test of the Phantasm)** — Polzin Mrid (The Hole). Requires
  Head of the Serpent (Plane of Fear), Essence of a Ghost (The Hole),
  Essence of a Vampire (Plane of Hate), Sands of the Mystics (Field of
  Bone, "The Tangrin").

All four pieces combine into a Bundle of Staves, turned in to Jeb Lumsed
for the final weapon. **Note:** as of a Dec 2025 P99 patch, the Jeb's
Seal prerequisite step is no longer optional — worth being aware this is
a recent change to P99's own quest-trigger enforcement, not an
era-accuracy issue.

---

## Monk — Celestial Fists

- **Start zone:** Erudin
- **Quest giver:** Tomekeeper Danl
- **Recommended level:** 46+

### Reward
Celestial Fists (Hands slot, 15 AC, +20 STR/+10 DEX/+10 STA/+10 AGI/+100
HP, all resists +10, Effect: Celestial Tranquility at level 50; also
changes fist damage/delay to 9/16 once clickable at level 50).

### Key structure
Two full sub-quests feed into the main chain and are referenced as
separate pages (Monk Sash Quests, Monk Headband Quests, Monks of The
Whistling Fist, The Lost Circle) — worth resourcing separately if we want
full depth, since each is its own multi-step quest:
- Obtain **Robe of the Lost Circle** (via killing Brother Zephyl/Brother
  Qwinn directly, or the full sash/headband sub-quest chain).
- Obtain **Robe of the Whistling Fists** — kill an iksar betrayer
  (Chardok) and a drolvarg pawbuster (Karnor's Castle) for two Metal
  Pipes, turn in with the first robe to Brother Balatin (Dreadlands).
- **First Book** — Immortals book (any named mob, Skyfire) → Tomekeeper
  Danl → Danl's Reference → Lheao (Timorous Deep) → Celestial Fists (book).
- **Fist of Fire/Air/Earth/Water** — a linear boss chain: Eejag
  (Lavastorm) → Gwan (Plane of Sky) → Trunt (Mines of Nurga) → Vorash/
  Xenevorash (Lake of Ill Omen), each triggered by handing the previous
  boss's loot to the next NPC.
- **Final turn-in** — the book must be converted by handing it to "mad"
  Kaiaren (Trakanon's Teeth) first, then to a *separate* "sane" Kaiaren
  spawn, before the final combine with Demon Fangs. Handing items to the
  wrong Kaiaren permanently loses them — a notable trap worth being aware
  of if we ever build this as a scripted quest.

---

## Cleric — Water Sprinkler of Nem Ankh

- **Start zone:** Lake Rathetear
- **Quest giver:** Shmendrik Lavawalker
- **Recommended level:** 46+ (50+ to use the click effect)

### Reward
Water Sprinkler of Nem Ankh (1H Blunt, 20dmg/32dly, +10 STA/+15 CHA/+25
WIS/+100 MANA, all resists +10, Effect: Reviviscence at level 50).

### Key structure
Three elemental orbs combine into the final weapon, each its own chain
centered on NPC hub **Omat Vastsea** (Timorous Deep):

- **Orb of Frozen Water** — Lord Bergurgle (Lake Rathetear) → Shmendrik
  Lavawalker → a spirit of flame (spawned by killing Shmendrik) → Natasha
  Whitewater → Omat Vastsea → a seeker/Plasmatic Priest (Temple of
  Solusek Ro) → Lord Gimblox (Solusek's Eye) → Orb of Frozen Water.
- **Orb of Clear Water** — Lord Gimblox's Signet Ring → Natasha
  Whitewater → Naxot Deepwater (Burning Woods) → Ixiblat Fer (Burning
  Woods, a 62nd-level fire elemental) → Overking Bathezid (Chardok) →
  Omat Vastsea → Orb of Clear Water.
- **Orb of Vapor** — Natasha Whitewater → Zordak Ragefire/Zordakalicus
  Ragefire (Nagafen's Lair, a Nagafen clone) → Omat Vastsea → Orb of
  Vapor.

All three orbs combine via Jhassad Oceanson (Timorous Deep) into the Orb
of the Triumvirate, turned in to the Avatar of Water for the final
weapon.

---

## Bard — Singing Short Sword

- **Start zone:** Dreadlands
- **Quest giver:** Baldric Slezaf
- **Recommended level:** 46+

### Reward
Singing Short Sword (1H Slashing, 16dmg/26dly, all instrument types 18,
+15 STR/+10 DEX/+5 STA/+20 CHA/+100 HP, all resists +10, Effect: Dance of
the Blade at level 46).

### Key structure
Three "sheet music" pages plus a custom-built lute combine for the final
weapon:

- **Page 24 Top** — a four-stop relay race (Konia Swiftfoot → Fajio
  Knejo → Andad Filla → Misty Tekchita → back to Konia) across Western
  Karana, Misty Thicket, South Ro, and Lake Rathetear.
- **Page 24 Bottom** — Baenar Swiftsong (South Karana) → a multi-step
  chain through Solusek's Eye and Unrest → kill Maligar's Enraged
  Doppleganger (West Karana) → Mahlin's Mystical Bongos.
- **Page 25** — three named-monster "gut" drops: Blackwing (Rathe
  Mountains), Nezekezena/Phurzikon (Burning Woods), Eldrig the Old
  (Skyfire Mountains).
- **Mystical Lute** — built in three parts by Forpar Fizfla (Butcherblock/
  Steamfont): Head (Kedge Backbone from Phinigel Autropos in Kedge Keep +
  Amygdalan Tendril from Plane of Fear + Petrified Werewolf Skull from
  Karnor's Castle), Body (Red Dragon Scales + White Dragon Scales + metal
  bits), and Strings (Undead Dragongut Strings, via An Undead Bard →
  triggered Trakanon clone, in Old Sebilis/Trakanon's Teeth). **Note:**
  the wiki explicitly dates the "An Undead Bard" mechanism to March 14,
  2001 — after Velious's Dec 2000 release but before Luclin's Dec 2001
  release, so still in scope for our server, just worth knowing it's a
  mid-era addition rather than day-one Kunark content.

---

## Necromancer — Scythe of the Shadowed Soul

- **Start zone:** Nektulos Forest
- **Quest giver:** Venenzi Oberzendi
- **Recommended level:** 46+

### Reward
Scythe of the Shadowed Soul (1H Blunt, 22dmg/34dly, +5 STR/+10 STA/+5
CHA/+20 INT/+20 HP/+80 MANA, resists +5 to +15 across the board, Effect:
Torment of Shadows at level 50). Two smaller permanent rewards along the
way: Twisted Bone Earring and Apprentice Ring.

### Key structure
A single linear chain through master NPC **Kazen Fecae** (Lake
Rathetear) and his apprentice **Emkel Kabae**, escalating through five
named "Symbols":

- **Symbol of the Apprentice** — kill Sir Edwin Motte (a roaming level 33
  paladin, 4 possible spawn points) → Kazen Fecae.
- **Symbol of the Serpent** — Venenzi Oberzendi (Nektulos Forest) → kill
  Najena for a Flowing Black Robe → Rolling Stone Moss → Emkel Kabae.
- **Symbol of Testing** — Ssessthrass (Swamp of No Hope) → Manisi Herb
  (Grand Herbalist Mak`ha, Chardok) → Refined Manisi Herb → Emkel Kabae.
- **Symbol of Insanity** — a triggered 3-mob chain (bone golem → failed
  apprentice → tortured soul) near Emkel's spawn point.
- **Gkzzallk in a Box** — Drendico Metalbones (Timorous Deep) requires
  three reagents from three different endgame zones: Cloak of Spiroc
  Feathers (built from Plane of Sky island drops via Jzil GSix), Eye of
  Innoruuk (Plane of Hate), Slime Blood of Cazic Thule (Plane of Fear) →
  Tome of Instruction → Gkzzallk (Plane of Sky, island 3) → final turn-in
  to Kazen Fecae.

**Note:** the wiki flags that triggering Gkzzallk despawns that raid
guild's Plane of Sky island 3 boss and blocks it until respawn — a
raid-etiquette/scheduling consideration rather than an era-accuracy
detail, but worth knowing if this is ever built out for live play.

---

## Cross-cutting observations for later verification

- **Shaman's quest is structurally different from the other six** — it's
  faction-driven rather than item-chain-driven. If we ever want to verify
  or tune this quest, the True Spirit faction increment-per-turn-in is
  the single number that matters most, and reported community values for
  it vary widely.
- **Multiple quests reference planar content** (Plane of Fear, Hate, Sky)
  as required kill targets — worth cross-checking that these zones and
  their relevant NPCs exist correctly in our database before assuming any
  of these quests are completable end-to-end.
- **Several NPCs are described as "rare spawn" or having long timers**
  (Verina Tomb, Vessel Drozlin, Lord Bergurgle, Shmendrik Lavawalker,
  etc.) — worth checking spawn timer configuration matches these
  descriptions, not just NPC existence.
- **A recurring mechanical pattern**: several quests have a "wrong NPC
  eats your item" trap (Monk's mad vs. sane Kaiaren, Shaman's
  under-faction final turn-in). These are worth flagging in any
  documentation we eventually write for these quests, so they're not
  mistaken for bugs later.
