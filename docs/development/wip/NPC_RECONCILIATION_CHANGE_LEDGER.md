# NPC Reconciliation: Consolidated Change Ledger

**Purpose:** Stage evidence-backed changes for one final, reviewable SQL
migration. This is not executable SQL and no listed change has been applied.

**Inclusion rule:** a change requires a field-specific classic source and an
active `zone.version = 0` / `spawn2.version = 0` consumer. Broad historical
tuning does not block a sourced correction.

## Confirmed NPC Stat Candidates

| NPC template | Active zone | Field | Live | Sourced target | Source | Status |
| ---: | --- | --- | ---: | ---: | --- | --- |
| 66047 | Lower Guk | `mindmg` | 1 | 13 | [P99](https://wiki.project1999.com/A_Froglok_Shin_Knight) | staged |
| 66047 | Lower Guk | `maxdmg` | 58 | 62 | [P99](https://wiki.project1999.com/A_Froglok_Shin_Knight) | staged |
| 66047 | Lower Guk | `AC` | 115 | 275 | [P99](https://wiki.project1999.com/A_Froglok_Shin_Knight) | staged |
| 94049 | Emerald Jungle | `maxdmg` | 85 | 94 | [P99](https://wiki.project1999.com/Greater_Spurbone) | staged |
| 94049 | Emerald Jungle | `AC` | 160 | 253 | [P99](https://wiki.project1999.com/Greater_Spurbone) | staged |
| 121000 | Crystal Caverns | `hp` | 1580 | 1131 | [P99](https://wiki.project1999.com/A_Ry%60Gorr_watchman) | staged |
| 121000 | Crystal Caverns | `maxdmg` | 62 | 58 | [P99](https://wiki.project1999.com/A_Ry%60Gorr_watchman) | staged |
| 121000 | Crystal Caverns | `AC` | 131 | 259 | [P99](https://wiki.project1999.com/A_Ry%60Gorr_watchman) | staged |
| 186000 | Plane of Hate | `level` | 55 | 51 | [P99](https://wiki.project1999.com/A_Forsaken_Revenant) | staged |
| 186000 | Plane of Hate | `hp` | 10120 | 10870 | [P99](https://wiki.project1999.com/A_Forsaken_Revenant) | staged |
| 186000 | Plane of Hate | `mindmg` | 46 | 74 | [P99](https://wiki.project1999.com/A_Forsaken_Revenant) | staged |
| 186000 | Plane of Hate | `maxdmg` | 234 | 203 | [P99](https://wiki.project1999.com/A_Forsaken_Revenant) | staged |
| 186000 | Plane of Hate | `AC` | 397 | 350 | [P99](https://wiki.project1999.com/A_Forsaken_Revenant) | staged |
| 186003 | Plane of Hate | `level` | 53 | 51 | [P99](https://wiki.project1999.com/A_Forsaken_Revenant) | staged |
| 186003 | Plane of Hate | `hp` | 10120 | 10870 | [P99](https://wiki.project1999.com/A_Forsaken_Revenant) | staged |
| 186003 | Plane of Hate | `mindmg` | 46 | 74 | [P99](https://wiki.project1999.com/A_Forsaken_Revenant) | staged |
| 186003 | Plane of Hate | `maxdmg` | 230 | 203 | [P99](https://wiki.project1999.com/A_Forsaken_Revenant) | staged |
| 186003 | Plane of Hate | `AC` | 383 | 350 | [P99](https://wiki.project1999.com/A_Forsaken_Revenant) | staged |
| 108037 | Veeshan's Peak | `hp` | 56000 | 21000 | [P99](https://wiki.project1999.com/A_Racnar) | staged |
| 108037 | Veeshan's Peak | `mindmg` | 181 | 240 | [P99](https://wiki.project1999.com/A_Racnar) | staged |
| 108037 | Veeshan's Peak | `maxdmg` | 713 | 500 | [P99](https://wiki.project1999.com/A_Racnar) | staged |
| 108037 | Veeshan's Peak | `AC` | 254 | 511 | [P99](https://wiki.project1999.com/A_Racnar) | staged |
| 108500 | Veeshan's Peak | `hp` | 56000 | 21000 | [P99](https://wiki.project1999.com/A_Racnar) | held — P99 `emu_id` identifies 108037, not this same-name template |
| 108500 | Veeshan's Peak | `mindmg` | 181 | 240 | [P99](https://wiki.project1999.com/A_Racnar) | held — P99 `emu_id` identifies 108037, not this same-name template |
| 108500 | Veeshan's Peak | `maxdmg` | 713 | 500 | [P99](https://wiki.project1999.com/A_Racnar) | held — P99 `emu_id` identifies 108037, not this same-name template |
| 108500 | Veeshan's Peak | `AC` | 254 | 511 | [P99](https://wiki.project1999.com/A_Racnar) | held — P99 `emu_id` identifies 108037, not this same-name template |
| 124044 | Temple of Veeshan | `hp` | 60000 | 45000 | [P99](https://wiki.project1999.com/A_cerulean_sky_gazer) | staged |
| 124044 | Temple of Veeshan | `mindmg` | 100 | 142 | [P99](https://wiki.project1999.com/A_cerulean_sky_gazer) | staged |
| 124044 | Temple of Veeshan | `maxdmg` | 290 | 340 | [P99](https://wiki.project1999.com/A_cerulean_sky_gazer) | staged |
| 124044 | Temple of Veeshan | `AC` | 441 | 511 | [P99](https://wiki.project1999.com/A_cerulean_sky_gazer) | staged |
| 124047 | Temple of Veeshan | `hp` | 65500 | 21000 | [P99](https://wiki.project1999.com/An_ancient_ice_wurm_defender) | staged |
| 124047 | Temple of Veeshan | `mindmg` | 100 | 144 | [P99](https://wiki.project1999.com/An_ancient_ice_wurm_defender) | staged |
| 124047 | Temple of Veeshan | `AC` | 455 | 527 | [P99](https://wiki.project1999.com/An_ancient_ice_wurm_defender) | staged |
| 97009 | Kurn's Tower | `maxdmg` | 44 | 42 | [P99](https://wiki.project1999.com/An_odd_mole) | staged |
| 97009 | Kurn's Tower | `AC` | 90 | 186 | [P99](https://wiki.project1999.com/An_odd_mole) | staged |
| 97061 | Kurn's Tower | `hp` | 430 | 375 | [P99](https://wiki.project1999.com/Thick_boned_skeleton) | staged |
| 97061 | Kurn's Tower | `maxdmg` | 34 | 30 | [P99](https://wiki.project1999.com/Thick_boned_skeleton) | staged |
| 97061 | Kurn's Tower | `AC` | 70 | 145 | [P99](https://wiki.project1999.com/Thick_boned_skeleton) | staged |
| 97062 | Kurn's Tower | `hp` | 365 | 336 | [P99](https://wiki.project1999.com/A_skeletal_cook) | staged |
| 97062 | Kurn's Tower | `maxdmg` | 32 | 28 | [P99](https://wiki.project1999.com/A_skeletal_cook) | staged |
| 97062 | Kurn's Tower | `AC` | 50 | 137 | [P99](https://wiki.project1999.com/A_skeletal_cook) | staged |
| 97064 | Kurn's Tower | `hp` | 365 | 336 | [P99](https://wiki.project1999.com/An_undead_jester) | staged |
| 97064 | Kurn's Tower | `maxdmg` | 32 | 28 | [P99](https://wiki.project1999.com/An_undead_jester) | staged |
| 97064 | Kurn's Tower | `AC` | 50 | 137 | [P99](https://wiki.project1999.com/An_undead_jester) | staged |
| 97071 | Kurn's Tower | `hp` | 257 | 231 | [P99](https://wiki.project1999.com/Fingered_skeleton) | staged |
| 97071 | Kurn's Tower | `maxdmg` | 26 | 22 | [P99](https://wiki.project1999.com/Fingered_skeleton) | staged |
| 97071 | Kurn's Tower | `AC` | 41 | 113 | [P99](https://wiki.project1999.com/Fingered_skeleton) | staged |
| 97075 | Kurn's Tower | `maxdmg` | 44 | 40 | [P99](https://wiki.project1999.com/Bargynn) | staged |
| 97075 | Kurn's Tower | `AC` | 90 | 186 | [P99](https://wiki.project1999.com/Bargynn) | staged |
| 97077 | Kurn's Tower | `maxdmg` | 36 | 32 | [P99](https://wiki.project1999.com/Undead_crusader) | staged |
| 97077 | Kurn's Tower | `AC` | 74 | 153 | [P99](https://wiki.project1999.com/Undead_crusader) | staged |
| 37157 | Oasis of Marr | `hp` | 15500 | 9750 | [P99](https://wiki.project1999.com/Cazel) | staged |
| 37157 | Oasis of Marr | `maxdmg` | 244 | 220 | [P99](https://wiki.project1999.com/Cazel) | staged |
| 37157 | Oasis of Marr | `AC` | 214 | 350 | [P99](https://wiki.project1999.com/Cazel) | staged |
| 37061 | Oasis of Marr | `hp` | 32000 | 20000 | [P99](https://wiki.project1999.com/Taldrik_Stumpystout) | staged |
| 37061 | Oasis of Marr | `maxdmg` | 335 | 283 | [P99](https://wiki.project1999.com/Taldrik_Stumpystout) | staged |
| 37061 | Oasis of Marr | `AC` | 400 | 415 | [P99](https://wiki.project1999.com/Taldrik_Stumpystout) | staged |
| 37064 | Oasis of Marr | `hp` | 750 | 20000 | [FV 2001 ShowEQ](https://fvproject.com/index.php/Classic_Spawn_List) | staged |
| 37060 | Oasis of Marr | `hp` | 5875 | 2475 | [P99](https://wiki.project1999.com/Gadallion) | staged |
| 37060 | Oasis of Marr | `maxdmg` | 139 | 135 | [P99](https://wiki.project1999.com/Gadallion) | staged |
| 37060 | Oasis of Marr | `AC` | 189 | 311 | [P99](https://wiki.project1999.com/Gadallion) | staged |
| 37058 | Oasis of Marr | `hp` | 5875 | 2475 | [P99](https://wiki.project1999.com/Innkeep_Tizzy) | staged |
| 37058 | Oasis of Marr | `maxdmg` | 139 | 135 | [P99](https://wiki.project1999.com/Innkeep_Tizzy) | staged |
| 37058 | Oasis of Marr | `AC` | 189 | 311 | [P99](https://wiki.project1999.com/Innkeep_Tizzy) | staged |
| 37046 | Oasis of Marr | `hp` | 1675 | 1575 | [P99](https://wiki.project1999.com/Isslana) | staged |
| 37046 | Oasis of Marr | `maxdmg` | 74 | 70 | [P99](https://wiki.project1999.com/Isslana) | staged |
| 37046 | Oasis of Marr | `AC` | 148 | 246 | [P99](https://wiki.project1999.com/Isslana) | staged |
| 37065 | Oasis of Marr | `hp` | 1675 | 1575 | [P99](https://wiki.project1999.com/Synthan) | staged |
| 37065 | Oasis of Marr | `maxdmg` | 74 | 80 | [P99](https://wiki.project1999.com/Synthan) | staged |
| 37065 | Oasis of Marr | `AC` | 148 | 246 | [P99](https://wiki.project1999.com/Synthan) | staged |
| 37057 | Oasis of Marr | `hp` | 1675 | 1575 | [P99](https://wiki.project1999.com/Transan) | staged |
| 37057 | Oasis of Marr | `maxdmg` | 74 | 70 | [P99](https://wiki.project1999.com/Transan) | staged |
| 37057 | Oasis of Marr | `AC` | 148 | 246 | [P99](https://wiki.project1999.com/Transan) | staged |
| 37104 | Oasis of Marr | `maxdmg` | 54 | 52 | [P99](https://wiki.project1999.com/Lockjaw) | staged |
| 37104 | Oasis of Marr | `AC` | 107 | 181 | [P99](https://wiki.project1999.com/Lockjaw) | staged |
| 37045 | Oasis of Marr | `maxdmg` | 76 | 88 | [P99](https://wiki.project1999.com/A_Deepwater_Goblin) | staged |
| 37045 | Oasis of Marr | `AC` | 152 | 253 | [P99](https://wiki.project1999.com/A_Deepwater_Goblin) | staged |
| 37019 | Oasis of Marr | `hp` | 1739 | 1526 | [P99](https://wiki.project1999.com/A_Spectre) | staged |
| 37019 | Oasis of Marr | `maxdmg` | 88 | 96 | [P99](https://wiki.project1999.com/A_Spectre) | staged |
| 37019 | Oasis of Marr | `AC` | 156 | 259 | [P99](https://wiki.project1999.com/A_Spectre) | staged |
| 37098 | Oasis of Marr | `maxdmg` | 36 | 32 | [P99](https://wiki.project1999.com/A_young_ronin) | staged |
| 37098 | Oasis of Marr | `AC` | 70 | 123 | [P99](https://wiki.project1999.com/A_young_ronin) | staged |
| 37015 | Oasis of Marr | `maxdmg` | 34 | 30 | [P99](https://wiki.project1999.com/An_Orc_Priest) | staged |
| 37015 | Oasis of Marr | `AC` | 66 | 116 | [P99](https://wiki.project1999.com/An_Orc_Priest) | staged |
| 17029 | Blackburrow | `maxdmg` | 48 | 44 | [P99](https://wiki.project1999.com/Lord_Elgnub) | staged |
| 17029 | Blackburrow | `AC` | 95 | 162 | [P99](https://wiki.project1999.com/Lord_Elgnub) | staged |
| 17023 | Blackburrow | `maxdmg` | 34 | 30 | [P99](https://wiki.project1999.com/Refugee_Splitpaw) | staged |
| 17023 | Blackburrow | `AC` | 66 | 116 | [P99](https://wiki.project1999.com/Refugee_Splitpaw) | staged |
| 17035 | Blackburrow | `maxdmg` | 34 | 32 | [P99](https://wiki.project1999.com/Splitpaw_Commander) | staged |
| 17035 | Blackburrow | `AC` | 66 | 116 | [P99](https://wiki.project1999.com/Splitpaw_Commander) | staged |
| 17042 | Blackburrow | `maxdmg` | 34 | 30 | [P99](https://wiki.project1999.com/The_gnoll_high_shaman) | staged |
| 17042 | Blackburrow | `AC` | 66 | 116 | [P99](https://wiki.project1999.com/The_gnoll_high_shaman) | staged |
| 17049 | Blackburrow | `maxdmg` | 32 | 28 | [P99](https://wiki.project1999.com/Master_Brewer) | staged |
| 17049 | Blackburrow | `AC` | 46 | 110 | [P99](https://wiki.project1999.com/Master_Brewer) | staged |
| 17036 | Blackburrow | `hp` | 250 | 270 | [P99](https://wiki.project1999.com/A_Gnoll_Brewer) | staged |
| 17036 | Blackburrow | `maxdmg` | 26 | 22 | [P99](https://wiki.project1999.com/A_Gnoll_Brewer) | staged |
| 17036 | Blackburrow | `AC` | 37 | 90 | [P99](https://wiki.project1999.com/A_Gnoll_Brewer) | staged |
| 17027 | Blackburrow | `maxdmg` | 32 | 28 | [P99](https://wiki.project1999.com/A_Gnoll_Tactician) | staged |
| 17027 | Blackburrow | `AC` | 46 | 110 | [P99](https://wiki.project1999.com/A_Gnoll_Tactician) | staged |
| 17021 | Blackburrow | `maxdmg` | 32 | 28 | [P99](https://wiki.project1999.com/A_Gnoll_Commander) | staged |
| 17021 | Blackburrow | `AC` | 46 | 110 | [P99](https://wiki.project1999.com/A_Gnoll_Commander) | staged |
| 17001 | Blackburrow | `maxdmg` | 30 | 26 | [P99](https://wiki.project1999.com/An_elite_gnoll_guard) | staged |
| 17001 | Blackburrow | `AC` | 43 | 103 | [P99](https://wiki.project1999.com/An_elite_gnoll_guard) | staged |
| 17009 | Blackburrow | `maxdmg` | 22 | 20 | [P99](https://wiki.project1999.com/A_Gnoll_Guardsman) | staged |
| 17009 | Blackburrow | `AC` | 31 | 77 | [P99](https://wiki.project1999.com/A_Gnoll_Guardsman) | staged |
| 17004 | Blackburrow | `AC` | 19 | 51 | [P99](https://wiki.project1999.com/A_Patrolling_Gnoll) | staged |
| 17025 | Blackburrow | `maxdmg` | 20 | 16 | [P99](https://wiki.project1999.com/A_Razorgill) | staged |
| 17025 | Blackburrow | `AC` | 28 | 71 | [P99](https://wiki.project1999.com/A_Razorgill) | staged |
| 17000 | Blackburrow | `maxdmg` | 14 | 12 | [P99](https://wiki.project1999.com/A_Scrawny_Gnoll) | staged |
| 17000 | Blackburrow | `AC` | 19 | 51 | [P99](https://wiki.project1999.com/A_Scrawny_Gnoll) | staged |
| 17003 | Blackburrow | `maxdmg` | 22 | 20 | [P99](https://wiki.project1999.com/A_Burly_Gnoll) | staged |
| 17003 | Blackburrow | `AC` | 31 | 77 | [P99](https://wiki.project1999.com/A_Burly_Gnoll) | staged |
| 17002 | Blackburrow | `AC` | 22 | 58 | [P99](https://wiki.project1999.com/A_Gnoll) | staged |
| 58020 | Crushbone | `hp` | 52 | 24 | [P99](https://wiki.project1999.com/A_dwarven_slave) | staged |
| 58020 | Crushbone | `maxdmg` | 8 | 4 | [P99](https://wiki.project1999.com/A_dwarven_slave) | staged |
| 58020 | Crushbone | `AC` | 10 | 32 | [P99](https://wiki.project1999.com/A_dwarven_slave) | staged |
| 58018 | Crushbone | `maxdmg` | 10 | 6 | [P99](https://wiki.project1999.com/A_dwarven_smith) | staged |
| 58018 | Crushbone | `AC` | 13 | 38 | [P99](https://wiki.project1999.com/A_dwarven_smith) | staged |
| 58007 | Crushbone | `maxdmg` | 10 | 6 | [P99](https://wiki.project1999.com/An_elven_slave) | staged |
| 58007 | Crushbone | `AC` | 13 | 38 | [P99](https://wiki.project1999.com/An_elven_slave) | staged |
| 58056 | Crushbone | `maxdmg` | 22 | 18 | [P99](https://wiki.project1999.com/Kelynn) | staged |
| 58056 | Crushbone | `AC` | 31 | 77 | [P99](https://wiki.project1999.com/Kelynn) | staged |
| 58028 | Crushbone | `hp` | 380 | 336 | [P99](https://wiki.project1999.com/Lord_Darish) | staged |
| 58028 | Crushbone | `maxdmg` | 32 | 28 | [P99](https://wiki.project1999.com/Lord_Darish) | staged |
| 58028 | Crushbone | `AC` | 46 | 110 | [P99](https://wiki.project1999.com/Lord_Darish) | staged |
| 58032 | Crushbone | `hp` | 700 | 504 | [P99](https://wiki.project1999.com/Emperor_Crush) | staged |
| 58032 | Crushbone | `maxdmg` | 38 | 36 | [P99](https://wiki.project1999.com/Emperor_Crush) | staged |
| 58032 | Crushbone | `AC` | 78 | 136 | [P99](https://wiki.project1999.com/Emperor_Crush) | staged |
| 58032 | Crushbone | `aggroradius` | 50 | 40 | [P99](https://wiki.project1999.com/Emperor_Crush) | staged |
| 58017 | Crushbone | `hp` | 430 | 416 | [P99](https://wiki.project1999.com/Retlon_Brenclog) | staged |
| 58017 | Crushbone | `maxdmg` | 36 | 32 | [P99](https://wiki.project1999.com/Retlon_Brenclog) | staged |
| 58017 | Crushbone | `AC` | 70 | 123 | [P99](https://wiki.project1999.com/Retlon_Brenclog) | staged |
| 58010 | Crushbone | `hp` | 220 | 171 | [P99](https://wiki.project1999.com/Rondo_Dunfire) | staged |
| 58010 | Crushbone | `maxdmg` | 22 | 18 | [P99](https://wiki.project1999.com/Rondo_Dunfire) | staged |
| 58010 | Crushbone | `AC` | 31 | 77 | [P99](https://wiki.project1999.com/Rondo_Dunfire) | staged |
| 58031 | Crushbone | `maxdmg` | 38 | 34 | [P99](https://wiki.project1999.com/The_Prophet) | staged |
| 58031 | Crushbone | `AC` | 74 | 129 | [P99](https://wiki.project1999.com/The_Prophet) | staged |
| 58031 | Crushbone | `aggroradius` | 50 | 40 | [P99](https://wiki.project1999.com/The_Prophet) | staged |
| 58025 | Crushbone | `maxdmg` | 34 | 30 | [P99](https://wiki.project1999.com/Orc_Emissary) | staged |
| 58025 | Crushbone | `AC` | 66 | 116 | [P99](https://wiki.project1999.com/Orc_Emissary) | staged |
| 58025 | Crushbone | `aggroradius` | 50 | 40 | [P99](https://wiki.project1999.com/Orc_Emissary) | staged |
| 58042 | Crushbone | `hp` | 310 | 264 | [P99](https://wiki.project1999.com/Orc_Scoutsman) | staged |
| 58042 | Crushbone | `maxdmg` | 28 | 24 | [P99](https://wiki.project1999.com/Orc_Scoutsman) | staged |
| 58042 | Crushbone | `AC` | 40 | 97 | [P99](https://wiki.project1999.com/Orc_Scoutsman) | staged |
| 58042 | Crushbone | `aggroradius` | 50 | 40 | [P99](https://wiki.project1999.com/Orc_Scoutsman) | staged |
| 58011 | Crushbone | `maxdmg` | 24 | 20 | [P99](https://wiki.project1999.com/Orc_Slaver) | staged |
| 58011 | Crushbone | `AC` | 34 | 84 | [P99](https://wiki.project1999.com/Orc_Slaver) | staged |
| 58011 | Crushbone | `aggroradius` | 50 | 40 | [P99](https://wiki.project1999.com/Orc_Slaver) | staged |
| 58040 | Crushbone | `maxdmg` | 32 | 28 | [P99](https://wiki.project1999.com/Orc_Taskmaster) | staged |
| 58040 | Crushbone | `AC` | 46 | 110 | [P99](https://wiki.project1999.com/Orc_Taskmaster) | staged |
| 58040 | Crushbone | `aggroradius` | 50 | 40 | [P99](https://wiki.project1999.com/Orc_Taskmaster) | staged |
| 58013 | Crushbone | `AC` | 40 | 97 | [P99](https://wiki.project1999.com/Orc_Trainer) | staged |
| 58013 | Crushbone | `aggroradius` | 50 | 40 | [P99](https://wiki.project1999.com/Orc_Trainer) | staged |
| 58002 | Crushbone | `maxdmg` | 36 | 32 | [P99](https://wiki.project1999.com/Orc_Warlord) | staged |
| 58002 | Crushbone | `AC` | 70 | 123 | [P99](https://wiki.project1999.com/Orc_Warlord) | staged |
| 58002 | Crushbone | `aggroradius` | 50 | 40 | [P99](https://wiki.project1999.com/Orc_Warlord) | staged |
| 58030 | Crushbone | `aggroradius` | 50 | 40 | [P99](https://wiki.project1999.com/Royal_guard) | staged |
| spawn2 48 (NPC 58028) | Crushbone | `x` | 20 | 90 | [P99](https://wiki.project1999.com/Lord_Darish) (P99 `(Y, X)` coordinates) | staged |
| spawn2 48 (NPC 58028) | Crushbone | `y` | 165 | 250 | [P99](https://wiki.project1999.com/Lord_Darish) (P99 `(Y, X)` coordinates) | staged |
| 54017 | Greater Faydark | `hp` | 16 | 11 | [P99](https://wiki.project1999.com/A_giant_wasp_drone) | staged |
| 54017 | Greater Faydark | `AC` | 8 | 25 | [P99](https://wiki.project1999.com/A_giant_wasp_drone) | staged |
| 54007 | Greater Faydark | `hp` | 160 | 119 | [P99](https://wiki.project1999.com/A_giant_wasp_warrior) | staged |
| 54005 | Greater Faydark | `AC` | 13 | 51 | [P99](https://wiki.project1999.com/A_giant_wasp_worker) | staged |
| 54056 | Greater Faydark | `hp` | 32 | 24 | [P99](https://wiki.project1999.com/A_fae_drake_hatchling) | staged |
| 54056 | Greater Faydark | `maxdmg` | 8 | 4 | [P99](https://wiki.project1999.com/A_fae_drake_hatchling) | staged |
| 54056 | Greater Faydark | `AC` | 10 | 32 | [P99](https://wiki.project1999.com/A_fae_drake_hatchling) | staged |
| 54022 | Greater Faydark | `hp` | 25 | 24 | [P99](https://wiki.project1999.com/A_pixie_trickster) | staged |
| 54022 | Greater Faydark | `maxdmg` | 8 | 4 | [P99](https://wiki.project1999.com/A_pixie_trickster) | staged |
| 54022 | Greater Faydark | `AC` | 10 | 32 | [P99](https://wiki.project1999.com/A_pixie_trickster) | staged |
| 54039 | Greater Faydark | `maxdmg` | 28 | 24 | [P99](https://wiki.project1999.com/An_orc_arsonist) | staged |
| 54039 | Greater Faydark | `AC` | 40 | 97 | [P99](https://wiki.project1999.com/An_orc_arsonist) | staged |
| 54238 | Greater Faydark | `maxdmg` | 42 | 40 | [P99](https://wiki.project1999.com/A_faerie_duchess) | staged |
| 54238 | Greater Faydark | `AC` | 82 | 142 | [P99](https://wiki.project1999.com/A_faerie_duchess) | staged |
| 54239 | Greater Faydark | `maxdmg` | 46 | 45 | [P99](https://wiki.project1999.com/A_faerie_royal_guard) | staged |
| 54239 | Greater Faydark | `AC` | 91 | 155 | [P99](https://wiki.project1999.com/A_faerie_royal_guard) | staged |
| 57122 | Lesser Faydark | `maxdmg` | 40 | 36 | [P99](https://wiki.project1999.com/Bracken_Underbrush) | staged |
| 57122 | Lesser Faydark | `AC` | 78 | 136 | [P99](https://wiki.project1999.com/Bracken_Underbrush) | staged |
| 57028 | Lesser Faydark | `hp` | 330 | 299 | [P99](https://wiki.project1999.com/Cognoggin) | staged |
| 57028 | Lesser Faydark | `maxdmg` | 30 | 26 | [P99](https://wiki.project1999.com/Cognoggin) | staged |
| 57028 | Lesser Faydark | `AC` | 43 | 103 | [P99](https://wiki.project1999.com/Cognoggin) | staged |
| 57113 | Lesser Faydark | `maxdmg` | 44 | 40 | [P99](https://wiki.project1999.com/Ivie_Bramblefoot) | staged |
| 57113 | Lesser Faydark | `AC` | 86 | 149 | [P99](https://wiki.project1999.com/Ivie_Bramblefoot) | staged |
| 57109 | Lesser Faydark | `maxdmg` | 48 | 44 | [P99](https://wiki.project1999.com/Kalayia_Woodwhisper) | staged |
| 57109 | Lesser Faydark | `AC` | 95 | 162 | [P99](https://wiki.project1999.com/Kalayia_Woodwhisper) | staged |
| 57115 | Lesser Faydark | `maxdmg` | 38 | 34 | [P99](https://wiki.project1999.com/Larik_Z%60Vole) | staged |
| 57115 | Lesser Faydark | `AC` | 74 | 129 | [P99](https://wiki.project1999.com/Larik_Z%60Vole) | staged |
| 57120 | Lesser Faydark | `hp` | 620 | 600 | [P99](https://wiki.project1999.com/Mina_Glimmerwing) | staged |
| 57120 | Lesser Faydark | `maxdmg` | 44 | 40 | [P99](https://wiki.project1999.com/Mina_Glimmerwing) | staged |
| 57120 | Lesser Faydark | `AC` | 86 | 149 | [P99](https://wiki.project1999.com/Mina_Glimmerwing) | staged |
| 57108 | Lesser Faydark | `maxdmg` | 28 | 24 | [P99](https://wiki.project1999.com/Old_Dimshimmer) | staged |
| 57108 | Lesser Faydark | `AC` | 40 | 97 | [P99](https://wiki.project1999.com/Old_Dimshimmer) | staged |
| 57010 | Lesser Faydark | `maxdmg` | 52 | 48 | [P99](https://wiki.project1999.com/Princess_Joleena) | staged |
| 57010 | Lesser Faydark | `AC` | 103 | 175 | [P99](https://wiki.project1999.com/Princess_Joleena) | staged |
| 57005 | Lesser Faydark | `hp` | 310 | 200 | [P99](https://wiki.project1999.com/Queen_Nasheeji) | staged |
| 57005 | Lesser Faydark | `maxdmg` | 24 | 20 | [P99](https://wiki.project1999.com/Queen_Nasheeji) | staged |
| 57005 | Lesser Faydark | `AC` | 34 | 84 | [P99](https://wiki.project1999.com/Queen_Nasheeji) | staged |
| 57025 | Lesser Faydark | `maxdmg` | 48 | 44 | [P99](https://wiki.project1999.com/Saben_Tucross) | staged |
| 57025 | Lesser Faydark | `AC` | 95 | 162 | [P99](https://wiki.project1999.com/Saben_Tucross) | staged |
| 57059 | Lesser Faydark | `maxdmg` | 46 | 42 | [P99](https://wiki.project1999.com/Trudo_Frugrin) | staged |
| 57059 | Lesser Faydark | `AC` | 91 | 155 | [P99](https://wiki.project1999.com/Trudo_Frugrin) | staged |
| 57002 | Lesser Faydark | `maxdmg` | 36 | 32 | [P99](https://wiki.project1999.com/Whimsy_Larktwitter) | staged |
| 57002 | Lesser Faydark | `AC` | 70 | 123 | [P99](https://wiki.project1999.com/Whimsy_Larktwitter) | staged |
| 57041 | Lesser Faydark | `hp` | 651 | 504 | [P99](https://wiki.project1999.com/Orc_Chief) | staged |
| 57041 | Lesser Faydark | `maxdmg` | 46 | 36 | [P99](https://wiki.project1999.com/Orc_Chief) | staged |
| 57041 | Lesser Faydark | `AC` | 78 | 136 | [P99](https://wiki.project1999.com/Orc_Chief) | staged |

## Confirmed Content-Flag Candidates

| Target | Proposed disabled flag | Era evidence | Rows currently affected | Status |
| --- | --- | --- | ---: | --- |
| 37858, 37859, 58067, 58068 | `GatesOfDiscord_GlobalDrops` | [EQ Traders](https://www.eqtraders.com/articles/article_page.php?article=g232) | 12,677 | staged |
| 34885, 34912 | `SecretsOfFaydwer_GlobalDrops` | [SoF cultural-material source](https://mobilis.wordpress.com/secret-of-faydwer-cultural-armors-augmentation-hp330/) | 1,100 | staged |
| 27 active `spawnentry` rows / 24 Fabled templates in Classic, Kunark, and Velious zones | `Fabled_NPCs` | [Official EverQuest anniversary announcement](https://www.everquest.com/news/fabed-mobs-anniversary-content-2014) identifies Fabled mobs as limited-time anniversary content introduced after Velious. | 27 | staged in Phase 1 SQL |
| Oasis `spawnentry` 275178 / NPC 37152 (`#Keelee_Rayin`) | `PostVelious_Oasis_NPCs` | [2007 archived Magelo South Ro listing](https://web.archive.org/web/20070213030235/http://eq.magelo.com/zone/393/index.html) identifies Keelee Rayin at level 65; it is absent from P99 and the 2001 ShowEQ list. | 1 | staged |
| Greater Faydark `spawnentry` 5841 / NPC 54002 (`#Second_Fragment_of_Igok`) | `PostVelious_GreaterFaydark_NPCs` | Spawn is gated at database expansion 5 and absent from P99/2001 ShowEQ data. | 1 | staged |
| Greater Faydark `spawnentry` 110236 / NPC 54305 (`a_Frostfell_Goblin`) | `PostVelious_GreaterFaydark_NPCs` | Frostfell is post-Velious seasonal content; spawn is absent from P99/2001 ShowEQ data. | 1 | staged |
| Greater Faydark `spawnentry` 110253 / NPC 54306 (`Hargar_the_Velium_Chef`) | `PostVelious_GreaterFaydark_NPCs` | Spawn is gated at database expansion 11 and absent from P99/2001 ShowEQ data. | 1 | staged |
| Greater Faydark `spawnentry` 110270 / NPC 54307 (`Fireworks_Engineer_Fabdabus`) | `PostVelious_GreaterFaydark_NPCs` | Spawn is gated at database expansion 11 and absent from P99/2001 ShowEQ data. | 1 | staged |
| Greater Faydark `spawnentry` 275172 / NPC 54308 (`#Feyana_Lightwing`) | `PostVelious_GreaterFaydark_NPCs` | [2004 archived Epic 2.0 walkthrough](https://web.archive.org/web/20041021003657/http://www.therunes.net/forums/viewtopic.php?t=5762) documents Feyana Lightwing; the NPC is absent from P99/2001 ShowEQ data. | 1 | staged |
| Castle Mistmoore `spawnentry` 2669 / NPC 59047 (`#Sir_Bronthas`) | `PostVelious_Mistmoore_NPCs` | Spawn is gated at database expansion 5 and absent from P99/2001 ShowEQ data. | 1 | staged |
| Castle Mistmoore `spawnentry` 48345 / NPC 59157 (`Nate`) | `PostVelious_Mistmoore_NPCs` | Spawn is gated at database expansion 9 and absent from P99/2001 ShowEQ data. | 1 | staged |

Phase 1 migration: `scripts/2026-08-06_npc_reconciliation_phase_1.sql`.
It contains transaction control, preflight snapshots, guarded updates, targeted
verification, and ends with `COMMIT;` for HeidiSQL execution.

## Held for Further Evidence

- `attack_count = -1` versus P99 attacks-per-round fields: verify EQEmu
  runtime semantics before staging a value.
- NPC special-ability strings: verify the EQEmu mapping before comparing P99
  behavior labels.
- All P99-known-loot absences: establish the template, zone, and drop-context
  match before staging additions.
- Any apparent post-Velious item without a field-appropriate era source.
- NPC template 108500 (`a racnar`): P99's exact `emu_id` is 108037; do not
  transfer 108037's values to this same-name template without independent
  evidence.

## Phase 2 Working Candidates

These entries are deliberately excluded from the Phase 1 SQL. They remain
subject to the same P99-first and exact-template requirements until the Phase
2 batch is closed.

| NPC template | Active zone | Field | Live | Sourced target | Source | Status |
| ---: | --- | --- | ---: | ---: | --- | --- |
| 68059 | Butcherblock Mountains | `AC` | 25 | 64 | [P99](https://wiki.project1999.com/Aqua_goblin_marauder) | staged for Phase 2 |
| 68040 | Butcherblock Mountains | `maxdmg` | 26 | 22 | [P99](https://wiki.project1999.com/Barma_Dunfire) | staged for Phase 2 |
| 68040 | Butcherblock Mountains | `AC` | 37 | 90 | [P99](https://wiki.project1999.com/Barma_Dunfire) | staged for Phase 2 |
| 68146 | Butcherblock Mountains | `hp` | 200 | 119 | [P99](https://wiki.project1999.com/Corflunk) | staged for Phase 2 |
| 68146 | Butcherblock Mountains | `maxdmg` | 18 | 14 | [P99](https://wiki.project1999.com/Corflunk) | staged for Phase 2 |
| 68146 | Butcherblock Mountains | `AC` | 25 | 64 | [P99](https://wiki.project1999.com/Corflunk) | staged for Phase 2 |
| 68027 | Butcherblock Mountains | `AC` | 31 | 77 | [P99](https://wiki.project1999.com/Crytil_Dunfire) | staged for Phase 2 |
| 68035 | Butcherblock Mountains | `maxdmg` | 26 | 22 | [P99](https://wiki.project1999.com/Glynda_Smeltpot) | staged for Phase 2 |
| 68035 | Butcherblock Mountains | `AC` | 37 | 90 | [P99](https://wiki.project1999.com/Glynda_Smeltpot) | staged for Phase 2 |
| 68037 | Butcherblock Mountains | `maxdmg` | 22 | 18 | [P99](https://wiki.project1999.com/Glynn_Smeltpot) | staged for Phase 2 |
| 68037 | Butcherblock Mountains | `AC` | 31 | 77 | [P99](https://wiki.project1999.com/Glynn_Smeltpot) | staged for Phase 2 |
| 68100 | Butcherblock Mountains | `maxdmg` | 22 | 18 | [P99](https://wiki.project1999.com/Gundl) | staged for Phase 2 |
| 68100 | Butcherblock Mountains | `AC` | 31 | 77 | [P99](https://wiki.project1999.com/Gundl) | staged for Phase 2 |
| 68012 | Butcherblock Mountains | `maxdmg` | 20 | 16 | [P99](https://wiki.project1999.com/Keldyn_Dunfire) | staged for Phase 2 |
| 68012 | Butcherblock Mountains | `AC` | 28 | 71 | [P99](https://wiki.project1999.com/Keldyn_Dunfire) | staged for Phase 2 |
| 68033 | Butcherblock Mountains | `maxdmg` | 26 | 22 | [P99](https://wiki.project1999.com/Margyl_Darklin) | staged for Phase 2 |
| 68033 | Butcherblock Mountains | `AC` | 37 | 90 | [P99](https://wiki.project1999.com/Margyl_Darklin) | staged for Phase 2 |
| 68062 | Butcherblock Mountains | `maxdmg` | 22 | 18 | [P99](https://wiki.project1999.com/Qued) | staged for Phase 2 |
| 68062 | Butcherblock Mountains | `AC` | 31 | 77 | [P99](https://wiki.project1999.com/Qued) | staged for Phase 2 |
| 68029 | Butcherblock Mountains | `hp` | 280 | 231 | [P99](https://wiki.project1999.com/Stump_Rundl) | staged for Phase 2 |
| 68029 | Butcherblock Mountains | `AC` | 37 | 90 | [P99](https://wiki.project1999.com/Stump_Rundl) | staged for Phase 2 |
| 68185 | Butcherblock Mountains | `hp` | 280 | 200 | [P99](https://wiki.project1999.com/Zarchoomi) | staged for Phase 2 |
| 68185 | Butcherblock Mountains | `maxdmg` | 24 | 20 | [P99](https://wiki.project1999.com/Zarchoomi) | staged for Phase 2 |
| 68185 | Butcherblock Mountains | `AC` | 34 | 84 | [P99](https://wiki.project1999.com/Zarchoomi) | staged for Phase 2 |
| 68002 | Butcherblock Mountains | `hp` | 16 | 11 | [P99](https://wiki.project1999.com/A_decaying_dwarf_skeleton) | staged for Phase 2 |
| 68002 | Butcherblock Mountains | `maxdmg` | 6 | 2 | [P99](https://wiki.project1999.com/A_decaying_dwarf_skeleton) | staged for Phase 2 |
| 68002 | Butcherblock Mountains | `AC` | 8 | 25 | [P99](https://wiki.project1999.com/A_decaying_dwarf_skeleton) | staged for Phase 2 |
| 68001 | Butcherblock Mountains | `hp` | 16 | 11 | [P99](https://wiki.project1999.com/A_goblin_whelp) | staged for Phase 2 |
| 68001 | Butcherblock Mountains | `maxdmg` | 6 | 2 | [P99](https://wiki.project1999.com/A_goblin_whelp) | staged for Phase 2 |
| 68001 | Butcherblock Mountains | `AC` | 8 | 25 | [P99](https://wiki.project1999.com/A_goblin_whelp) | staged for Phase 2 |
| 68072 | Butcherblock Mountains | `hp` | 1675 | 1575 | [P99](https://wiki.project1999.com/Balen_Kalgunn) | staged for Phase 2 |
| 68072 | Butcherblock Mountains | `maxdmg` | 74 | 92 | [P99](https://wiki.project1999.com/Balen_Kalgunn) | staged for Phase 2 |
| 68072 | Butcherblock Mountains | `AC` | 148 | 246 | [P99](https://wiki.project1999.com/Balen_Kalgunn) | staged for Phase 2 |
| 68111 | Butcherblock Mountains | `hp` | 5875 | 2475 | [P99](https://wiki.project1999.com/Ellona) | staged for Phase 2 |
| 68111 | Butcherblock Mountains | `maxdmg` | 139 | 135 | [P99](https://wiki.project1999.com/Ellona) | staged for Phase 2 |
| 68111 | Butcherblock Mountains | `AC` | 189 | 311 | [P99](https://wiki.project1999.com/Ellona) | staged for Phase 2 |
| 68108 | Butcherblock Mountains | `maxdmg` | 68 | 64 | [P99](https://wiki.project1999.com/Fugan_Mumfur) | staged for Phase 2 |
| 68108 | Butcherblock Mountains | `AC` | 136 | 227 | [P99](https://wiki.project1999.com/Fugan_Mumfur) | staged for Phase 2 |
| 68081 | Butcherblock Mountains | `maxdmg` | 54 | 50 | [P99](https://wiki.project1999.com/Guard_Gonin) | staged for Phase 2 |
| 68081 | Butcherblock Mountains | `AC` | 107 | 181 | [P99](https://wiki.project1999.com/Guard_Gonin) | staged for Phase 2 |
| 68095 | Butcherblock Mountains | `maxdmg` | 68 | 64 | [P99](https://wiki.project1999.com/Iglan_Thranon) | staged for Phase 2 |
| 68095 | Butcherblock Mountains | `AC` | 136 | 227 | [P99](https://wiki.project1999.com/Iglan_Thranon) | staged for Phase 2 |
| 68066 | Butcherblock Mountains | `AC` | 99 | 185 | [P99](https://wiki.project1999.com/Kanthuk_Ogrebane) | staged for Phase 2 |
| 68103 | Butcherblock Mountains | `hp` | 8475 | 5335 | [P99](https://wiki.project1999.com/Nyzil_Bloodforge) | staged for Phase 2 |
| 68103 | Butcherblock Mountains | `maxdmg` | 139 | 135 | [P99](https://wiki.project1999.com/Nyzil_Bloodforge) | staged for Phase 2 |
| 68103 | Butcherblock Mountains | `AC` | 189 | 311 | [P99](https://wiki.project1999.com/Nyzil_Bloodforge) | staged for Phase 2 |
| 68032 | Butcherblock Mountains | `maxdmg` | 34 | 30 | [P99](https://wiki.project1999.com/Peg_Leg) | staged for Phase 2 |
| 68032 | Butcherblock Mountains | `AC` | 66 | 116 | [P99](https://wiki.project1999.com/Peg_Leg) | staged for Phase 2 |
| 68075 | Butcherblock Mountains | `maxdmg` | 54 | 50 | [P99](https://wiki.project1999.com/Siltria_Marwind) | staged for Phase 2 |
| 68075 | Butcherblock Mountains | `AC` | 107 | 181 | [P99](https://wiki.project1999.com/Siltria_Marwind) | staged for Phase 2 |
| 68087 | Butcherblock Mountains | `hp` | 14000 | 6500 | [P99](https://wiki.project1999.com/Walnan) | staged for Phase 2 |
| 68087 | Butcherblock Mountains | `maxdmg` | 145 | 141 | [P99](https://wiki.project1999.com/Walnan) | staged for Phase 2 |
| 68087 | Butcherblock Mountains | `AC` | 197 | 324 | [P99](https://wiki.project1999.com/Walnan) | staged for Phase 2 |

### Phase 2 Content-Flag Candidates

| Target | Proposed disabled flag | Era evidence | Rows currently affected | Status |
| --- | --- | --- | ---: | --- |
| Butcherblock `spawnentry` 13197, 13198, 13199, 13200, 13201, 13202 / NPC 68237 (`Emeraldman`) | `PostVelious_Butcherblock_NPCs` | All six spawns are database-gated at expansion 3 (Luclin), outside the Classic/Kunark/Velious target. | 6 | staged for Phase 2 |

### Phase 2 — Steamfont Mountains Working Candidates

| NPC template | Active zone | Field | Live | Sourced target | Source | Status |
| ---: | --- | --- | ---: | ---: | --- | --- |
| 56010 | Steamfont Mountains | `hp` | 175 | 144 | [P99](https://wiki.project1999.com/A_giant_diseased_rat) | staged for Phase 2 |
| 56056 | Steamfont Mountains | `hp` | 16 | 11 | [P99](https://wiki.project1999.com/A_gnome_skeleton) | staged for Phase 2 |
| 56056 | Steamfont Mountains | `maxdmg` | 6 | 2 | [P99](https://wiki.project1999.com/A_gnome_skeleton) | staged for Phase 2 |
| 56056 | Steamfont Mountains | `AC` | 8 | 25 | [P99](https://wiki.project1999.com/A_gnome_skeleton) | staged for Phase 2 |
| 56100 | Steamfont Mountains | `maxdmg` | 10 | 6 | [P99](https://wiki.project1999.com/A_gnome_slave) | staged for Phase 2 |
| 56100 | Steamfont Mountains | `AC` | 13 | 38 | [P99](https://wiki.project1999.com/A_gnome_slave) | staged for Phase 2 |
| 56035 | Steamfont Mountains | `maxdmg` | 14 | 10 | [P99](https://wiki.project1999.com/A_kobold_scout) | staged for Phase 2 |
| 56035 | Steamfont Mountains | `AC` | 19 | 51 | [P99](https://wiki.project1999.com/A_kobold_scout) | staged for Phase 2 |
| 56069 | Steamfont Mountains | `maxdmg` | 12 | 8 | [P99](https://wiki.project1999.com/A_krag_chick) | staged for Phase 2 |
| 56069 | Steamfont Mountains | `AC` | 16 | 45 | [P99](https://wiki.project1999.com/A_krag_chick) | staged for Phase 2 |
| 56014 | Steamfont Mountains | `hp` | 210 | 200 | [P99](https://wiki.project1999.com/A_mountain_brownie) | staged for Phase 2 |
| 56014 | Steamfont Mountains | `maxdmg` | 24 | 20 | [P99](https://wiki.project1999.com/A_mountain_brownie) | staged for Phase 2 |
| 56014 | Steamfont Mountains | `AC` | 34 | 84 | [P99](https://wiki.project1999.com/A_mountain_brownie) | staged for Phase 2 |
| 56044 | Steamfont Mountains | `maxdmg` | 18 | 14 | [P99](https://wiki.project1999.com/A_mountain_lion) | staged for Phase 2 |
| 56044 | Steamfont Mountains | `AC` | 25 | 64 | [P99](https://wiki.project1999.com/A_mountain_lion) | staged for Phase 2 |
| 56051 | Steamfont Mountains | `hp` | 17 | 11 | [P99](https://wiki.project1999.com/A_runaway_clockwork) | staged for Phase 2 |
| 56051 | Steamfont Mountains | `maxdmg` | 6 | 2 | [P99](https://wiki.project1999.com/A_runaway_clockwork) | staged for Phase 2 |
| 56051 | Steamfont Mountains | `AC` | 8 | 25 | [P99](https://wiki.project1999.com/A_runaway_clockwork) | staged for Phase 2 |
| 56159 | Steamfont Mountains | `hp` | 190 | 144 | [P99](https://wiki.project1999.com/Berinsan) | staged for Phase 2 |
| 56159 | Steamfont Mountains | `maxdmg` | 20 | 16 | [P99](https://wiki.project1999.com/Berinsan) | staged for Phase 2 |
| 56159 | Steamfont Mountains | `AC` | 28 | 71 | [P99](https://wiki.project1999.com/Berinsan) | staged for Phase 2 |
| 56157 | Steamfont Mountains | `hp` | 208 | 250 | [P99](https://wiki.project1999.com/Bugglegupp) | staged for Phase 2 |
| 56157 | Steamfont Mountains | `maxdmg` | 24 | 22 | [P99](https://wiki.project1999.com/Bugglegupp) | staged for Phase 2 |
| 56157 | Steamfont Mountains | `AC` | 34 | 84 | [P99](https://wiki.project1999.com/Bugglegupp) | staged for Phase 2 |
| 56110 | Steamfont Mountains | `hp` | 210 | 144 | [P99](https://wiki.project1999.com/Dimlore_Stormhammer) | staged for Phase 2 |
| 56110 | Steamfont Mountains | `maxdmg` | 20 | 16 | [P99](https://wiki.project1999.com/Dimlore_Stormhammer) | staged for Phase 2 |
| 56110 | Steamfont Mountains | `AC` | 28 | 71 | [P99](https://wiki.project1999.com/Dimlore_Stormhammer) | staged for Phase 2 |
| 56136 | Steamfont Mountains | `maxdmg` | 18 | 14 | [P99](https://wiki.project1999.com/Lodrand_Dindlenod) | staged for Phase 2 |
| 56136 | Steamfont Mountains | `AC` | 25 | 64 | [P99](https://wiki.project1999.com/Lodrand_Dindlenod) | staged for Phase 2 |
| 56135 | Steamfont Mountains | `maxdmg` | 18 | 14 | [P99](https://wiki.project1999.com/Thetherthag_Wakintrob) | staged for Phase 2 |
| 56135 | Steamfont Mountains | `AC` | 25 | 64 | [P99](https://wiki.project1999.com/Thetherthag_Wakintrob) | staged for Phase 2 |

### Phase 2 — Steamfont Content-Flag Candidates

| Target | Proposed disabled flag | Era evidence | Rows currently affected | Status |
| --- | --- | --- | ---: | --- |
| Steamfont `spawnentry` 52172 / NPC 56177 (`#Meldraths_Paige`) | `PostVelious_Steamfont_NPCs` | Spawn is gated at database expansion 12, outside the Classic/Kunark/Velious target. | 1 | staged for Phase 2 |
| Steamfont `spawnentry` 111136 / NPC 56187 (`#Smith_Numden`) | `PostVelious_Steamfont_NPCs` | Spawn is gated at database expansion 8, outside the Classic/Kunark/Velious target. | 1 | staged for Phase 2 |

### Phase 2 — Estate of Unrest Working Candidates

| NPC template | Active zone | Field | Live | Sourced target | Source | Status |
| ---: | --- | --- | ---: | ---: | --- | --- |
| 63017 | The Estate of Unrest | `hp` | 550 | 504 | [P99](https://wiki.project1999.com/An_undead_brewer) | staged for Phase 2 |
| 63017 | The Estate of Unrest | `maxdmg` | 38 | 36 | [P99](https://wiki.project1999.com/An_undead_brewer) | staged for Phase 2 |
| 63017 | The Estate of Unrest | `AC` | 78 | 136 | [P99](https://wiki.project1999.com/An_undead_brewer) | staged for Phase 2 |
| 63058 | The Estate of Unrest | `AC` | 78 | 136 | [P99](https://wiki.project1999.com/A_lurking_mummy) | staged for Phase 2 |
| 63003 | The Estate of Unrest | `hp` | 790 | 874 | [P99](https://wiki.project1999.com/An_undead_knight_of_Unrest) | staged for Phase 2 |
| 63003 | The Estate of Unrest | `maxdmg` | 64 | 56 | [P99](https://wiki.project1999.com/An_undead_knight_of_Unrest) | staged for Phase 2 |
| 63003 | The Estate of Unrest | `AC` | 119 | 201 | [P99](https://wiki.project1999.com/An_undead_knight_of_Unrest) | staged for Phase 2 |
| 63033 | The Estate of Unrest | `AC` | 115 | 194 | [P99](https://wiki.project1999.com/A_greater_dark_bone) | staged for Phase 2 |
| 63010 | The Estate of Unrest | `hp` | 875 | 810 | [P99](https://wiki.project1999.com/An_undead_barkeep) | staged for Phase 2 |
| 63010 | The Estate of Unrest | `maxdmg` | 54 | 50 | [P99](https://wiki.project1999.com/An_undead_barkeep) | staged for Phase 2 |
| 63010 | The Estate of Unrest | `AC` | 107 | 181 | [P99](https://wiki.project1999.com/An_undead_barkeep) | staged for Phase 2 |
| 63062 | The Estate of Unrest | `hp` | 1975 | 1675 | [P99](https://wiki.project1999.com/Garanel_Rucksif) | staged for Phase 2 |
| 63062 | The Estate of Unrest | `maxdmg` | 74 | 80 | [P99](https://wiki.project1999.com/Garanel_Rucksif) | staged for Phase 2 |
| 63062 | The Estate of Unrest | `AC` | 148 | 246 | [P99](https://wiki.project1999.com/Garanel_Rucksif) | staged for Phase 2 |
| 63082 | The Estate of Unrest | `maxdmg` | 74 | 80 | [P99](https://wiki.project1999.com/Khrix_Fritchoff) | staged for Phase 2 |
| 63082 | The Estate of Unrest | `AC` | 148 | 246 | [P99](https://wiki.project1999.com/Khrix_Fritchoff) | staged for Phase 2 |
| 63086 | The Estate of Unrest | `hp` | 859 | 562 | [P99](https://wiki.project1999.com/Reclusive_ghoul_magus) | staged for Phase 2 |
| 63086 | The Estate of Unrest | `AC` | 99 | 168 | [P99](https://wiki.project1999.com/Reclusive_ghoul_magus) | staged for Phase 2 |

### Phase 2 — Estate of Unrest Content-Flag Candidates

| Target | Proposed disabled flag | Era evidence | Rows currently affected | Status |
| --- | --- | --- | ---: | --- |
| Unrest `spawnentry` 48349 / NPC 63109 (`Halloween_Trigger`) | `PostVelious_Unrest_NPCs` | Seasonal Halloween trigger; not classic-era content. | 1 | staged for Phase 2 |
| Unrest `spawnentry` 5036/63023, 5034/63080, 5028/63023, 5028/63054 (`a_jack_o_lantern`) | `PostVelious_Unrest_NPCs` | Seasonal Halloween NPC variants; not classic-era content. | 4 | staged for Phase 2 |

### Phase 2 — Befallen Working Candidates

| NPC template | Active zone | Field | Live | Sourced target | Source | Status |
| ---: | --- | --- | ---: | ---: | --- | --- |
| 36103 | Befallen | `maxdmg` | 44 | 52 | [P99](https://wiki.project1999.com/Gynok_Moltor) | staged for Phase 2 |
| 36103 | Befallen | `AC` | 103 | 218 | [P99](https://wiki.project1999.com/Gynok_Moltor) | staged for Phase 2 |
| 36095 | Befallen | `maxdmg` | 38 | 34 | [P99](https://wiki.project1999.com/Priest_Amiaz) | staged for Phase 2 |
| 36095 | Befallen | `AC` | 74 | 161 | [P99](https://wiki.project1999.com/Priest_Amiaz) | staged for Phase 2 |
| 36002 | Befallen | `hp` | 80 | 75 | [P99](https://wiki.project1999.com/A_cracked_skeleton) | staged for Phase 2 |
| 36002 | Befallen | `maxdmg` | 14 | 10 | [P99](https://wiki.project1999.com/A_cracked_skeleton) | staged for Phase 2 |
| 36002 | Befallen | `AC` | 19 | 64 | [P99](https://wiki.project1999.com/A_cracked_skeleton) | staged for Phase 2 |
| 36034 | Befallen | `maxdmg` | 22 | 18 | [P99](https://wiki.project1999.com/A_dread_bone) | staged for Phase 2 |
| 36034 | Befallen | `AC` | 31 | 96 | [P99](https://wiki.project1999.com/A_dread_bone) | staged for Phase 2 |
| 36001 | Befallen | `hp` | 150 | 144 | [P99](https://wiki.project1999.com/A_sturdy_skeleton) | staged for Phase 2 |
| 36001 | Befallen | `maxdmg` | 20 | 16 | [P99](https://wiki.project1999.com/A_sturdy_skeleton) | staged for Phase 2 |
| 36001 | Befallen | `AC` | 28 | 88 | [P99](https://wiki.project1999.com/A_sturdy_skeleton) | staged for Phase 2 |

### Phase 2 — Befallen Content-Flag Candidates

| Target | Proposed disabled flag | Era evidence | Rows currently affected | Status |
| --- | --- | --- | ---: | --- |
| Befallen `spawnentry` 48348 / NPC 36098 (`Wraps_McGee`) | `PostVelious_Befallen_NPCs` | Spawn is gated at database expansion 9, outside the Classic/Kunark/Velious target. | 1 | staged for Phase 2 |

### Phase 2 — Nektulos Forest Working Candidates

| NPC template | Active zone | Field | Live | Sourced target | Source | Status |
| ---: | --- | --- | ---: | ---: | --- | --- |
| 25102 | The Nektulos Forest | `AC` | 46 | 110 | [P99](https://wiki.project1999.com/A_darkwater_piranha) | staged for Phase 2 |
| 25310 | The Nektulos Forest | `AC` | 8 | 25 | [P99](https://wiki.project1999.com/An_araneidae_spiderling) | staged for Phase 2 |
| 25353 | The Nektulos Forest | `maxdmg` | 20 | 16 | [P99](https://wiki.project1999.com/A_rotting_citizen) | staged for Phase 2 |
| 25353 | The Nektulos Forest | `AC` | 25 | 64 | [P99](https://wiki.project1999.com/A_rotting_citizen) | staged for Phase 2 |
| 25323 | The Nektulos Forest | `maxdmg` | 20 | 16 | [P99](https://wiki.project1999.com/A_rotting_initiate) | staged for Phase 2 |
| 25323 | The Nektulos Forest | `AC` | 25 | 64 | [P99](https://wiki.project1999.com/A_rotting_initiate) | staged for Phase 2 |

### Phase 2 — West Commonlands Working Candidates

| NPC template | Active zone | Field | Live | Sourced target | Source | Status |
| ---: | --- | --- | ---: | ---: | --- | --- |
| 21021 | West Commonlands | `hp` | 330 | 299 | [P99](https://wiki.project1999.com/A_Dervish_Cutthroat) | staged for Phase 2 |
| 21021 | West Commonlands | `maxdmg` | 30 | 26 | [P99](https://wiki.project1999.com/A_Dervish_Cutthroat) | staged for Phase 2 |
| 21021 | West Commonlands | `AC` | 43 | 103 | [P99](https://wiki.project1999.com/A_Dervish_Cutthroat) | staged for Phase 2 |
| 21015 | West Commonlands | `hp` | 390 | 375 | [P99](https://wiki.project1999.com/A_Dervish_Thug) | staged for Phase 2 |
| 21015 | West Commonlands | `maxdmg` | 34 | 30 | [P99](https://wiki.project1999.com/A_Dervish_Thug) | staged for Phase 2 |
| 21015 | West Commonlands | `AC` | 66 | 116 | [P99](https://wiki.project1999.com/A_Dervish_Thug) | staged for Phase 2 |
| 21033 | West Commonlands | `hp` | 120 | 75 | [P99](https://wiki.project1999.com/A_large_rattlesnake) | staged for Phase 2 |
| 21043 | West Commonlands | `maxdmg` | 62 | 58 | [P99](https://wiki.project1999.com/Jahsohn_Aksot) | staged for Phase 2 |
| 21043 | West Commonlands | `AC` | 123 | 207 | [P99](https://wiki.project1999.com/Jahsohn_Aksot) | staged for Phase 2 |
| 21006 | West Commonlands | `maxdmg` | 40 | 38 | [P99](https://wiki.project1999.com/Kizdean_Gix) | staged for Phase 2 |
| 21006 | West Commonlands | `AC` | 78 | 136 | [P99](https://wiki.project1999.com/Kizdean_Gix) | staged for Phase 2 |
| 21040 | West Commonlands | `maxdmg` | 62 | 58 | [P99](https://wiki.project1999.com/Timtok_Tonsmith) | staged for Phase 2 |
| 21040 | West Commonlands | `AC` | 123 | 207 | [P99](https://wiki.project1999.com/Timtok_Tonsmith) | staged for Phase 2 |
| 21049 | West Commonlands | `AC` | 107 | 181 | [P99](https://wiki.project1999.com/Wallin_Slyfoot) | staged for Phase 2 |
| 21016 | West Commonlands | `hp` | 150 | 96 | [P99](https://wiki.project1999.com/A_plains_cat) | staged for Phase 2 |
| 21016 | West Commonlands | `maxdmg` | 16 | 12 | [P99](https://wiki.project1999.com/A_plains_cat) | staged for Phase 2 |
| 21016 | West Commonlands | `AC` | 22 | 58 | [P99](https://wiki.project1999.com/A_plains_cat) | staged for Phase 2 |
| 21027 | West Commonlands | `hp` | 110 | 75 | [P99](https://wiki.project1999.com/A_puma) | staged for Phase 2 |
| 21027 | West Commonlands | `maxdmg` | 14 | 10 | [P99](https://wiki.project1999.com/A_puma) | staged for Phase 2 |
| 21027 | West Commonlands | `AC` | 19 | 51 | [P99](https://wiki.project1999.com/A_puma) | staged for Phase 2 |
| 21037 | West Commonlands | `maxdmg` | 24 | 20 | [P99](https://wiki.project1999.com/An_asp) | staged for Phase 2 |
| 21037 | West Commonlands | `AC` | 34 | 84 | [P99](https://wiki.project1999.com/An_asp) | staged for Phase 2 |
| 21039 | West Commonlands | `maxdmg` | 8 | 4 | [P99](https://wiki.project1999.com/Orc_apprentice) | staged for Phase 2 |
| 21039 | West Commonlands | `AC` | 10 | 32 | [P99](https://wiki.project1999.com/Orc_apprentice) | staged for Phase 2 |
| 21155 | West Commonlands | `hp` | 290 | 171 | [P99](https://wiki.project1999.com/Orc_weaponsmith) | staged for Phase 2 |
| 21155 | West Commonlands | `maxdmg` | 24 | 18 | [P99](https://wiki.project1999.com/Orc_weaponsmith) | staged for Phase 2 |
| 21155 | West Commonlands | `AC` | 31 | 77 | [P99](https://wiki.project1999.com/Orc_weaponsmith) | staged for Phase 2 |

### Phase 2 — East Commonlands Working Candidates

| NPC template | Active zone | Field | Live | Sourced target | Source | Status |
| ---: | --- | --- | ---: | ---: | --- | --- |
| 22036 | East Commonlands | `hp` | 170 | 144 | [P99](https://wiki.project1999.com/A_giant_rattlesnake) | staged for Phase 2 |
| 22036 | East Commonlands | `maxdmg` | 20 | 16 | [P99](https://wiki.project1999.com/A_giant_rattlesnake) | staged for Phase 2 |
| 22036 | East Commonlands | `AC` | 28 | 71 | [P99](https://wiki.project1999.com/A_giant_rattlesnake) | staged for Phase 2 |
| 22011 | East Commonlands | `hp` | 50 | 39 | [P99](https://wiki.project1999.com/A_young_plains_cat) | staged for Phase 2 |
| 22011 | East Commonlands | `maxdmg` | 10 | 6 | [P99](https://wiki.project1999.com/A_young_plains_cat) | staged for Phase 2 |
| 22011 | East Commonlands | `AC` | 13 | 38 | [P99](https://wiki.project1999.com/A_young_plains_cat) | staged for Phase 2 |

### Phase 2 — West Commonlands Content-Flag Candidates

| Target | Proposed disabled flag | Era evidence | Rows currently affected | Status |
| --- | --- | --- | ---: | --- |
| West Commonlands `spawnentry` 466 / NPC 21070 (`Bealya_Tanilsuia`) | `PostVelious_WestCommonlands_NPCs` | Spawn is gated at database expansion 7, outside the Classic/Kunark/Velious target. | 1 | staged for Phase 2 |
| West Commonlands `spawnentry` 13080 / NPC 21162 (`Sasha_the_Seer`) | `PostVelious_WestCommonlands_NPCs` | Spawn is gated at database expansion 14, outside the Classic/Kunark/Velious target. | 1 | staged for Phase 2 |
| West Commonlands `spawnentry` 52567 / NPC 21158 (`Brizzenoth_Scyth`) | `PostVelious_WestCommonlands_NPCs` | Spawn is gated at database expansion 9, outside the Classic/Kunark/Velious target. | 1 | staged for Phase 2 |
| West Commonlands `spawnentry` 98970 / NPC 21163 (`A_Legendary_Hill_Giant`) | `PostVelious_WestCommonlands_NPCs` | Spawn is gated at database expansion 11, outside the Classic/Kunark/Velious target. | 1 | staged for Phase 2 |
