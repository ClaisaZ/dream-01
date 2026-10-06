# Dream-01 Bible

Shared copy for the team: https://claude.ai/code/artifact/5fd09cc9-2285-4313-84de-62fb7a318b79
(This file and the shared doc should match. Update both.)

## The game

A short (about 5 hours) turn-based RPG where the story is told through visual novel scenes. A passion project with no deadline.

**Three rules every idea is checked against:**

1. **Every battle tells a story.** Fights matter to the plot. Big fights are story moments, not filler.
2. **Respect the player's time.** Battles take about 5 minutes. No grinding.
3. **Stronger together.** The party's bond is part of how you win.

**The team:**

| Who | Does |
|---|---|
| Clayton | Programming: battles, menus, saving, putting everyone's work into the game |
| Rachel | Story, script, dialogue, creating the characters |
| Joli | Character portraits and battle sprites, later armor, potions, and items |
| Macy | Enemies, bosses, and attack effects, more later |
| Open | Music and sound (we're looking for someone) |

## The plan

**Programming goes first, using stand-ins.** Gray boxes and silence fill in until real art and music arrive, so nobody waits on anybody.

**Build order:**

1. Game data: characters, moves, items, status effects *(mostly done)*
2. A basic battle you can play from start to win or lose
3. Add the extras one at a time: special attacks, defending, items, status effects, critical hits, tag-team attacks, smarter enemies, boss phases
4. Cool timed moves (press a button at the right moment) come last

Each step leaves the game playable.

**Still to decide as a team:**

- [ ] Working title
- [ ] Art style: pixel art or illustrated (this sets the size of every picture)
- [ ] Main characters and story outline
- [ ] Elements (fire, water, etc.): yes or no?
- [ ] Where and when to release
- [ ] Who makes music and sound

## How battles work

Everyone acts once per round. Faster characters go first, but some moves jump the line or go last.

| Action | What it does |
|---|---|
| Quick attack | Weaker, but goes early |
| Power attack | Stronger, but goes late |
| Special attack | Big hit. Needs a full skill meter |
| Item | Use a potion. Goes first of all |
| Defend | Take less damage until your next turn |

There's no running away: every battle is part of the story.

- **Skill meter:** fills as you attack, get hit, or help a friend. When full, the special attack unlocks. Empty at the start of every battle.
- **Status effects:** Stun (skip a turn), Attack up/down, Defense up/down. Each lasts a few turns.
- **Critical hits:** hidden lucky hits that do extra damage. More likely when a character is hurt.
- **Tag-team attacks:** two party members hitting the same enemy can team up. Each pair's team-up is unlocked by a story moment.
- **Bosses:** change phases as they lose health (stronger, more attacks), warn before big attacks, and talk during the fight.
- **Items:** HP potion (heals 30%), meter boost, and rare potions that raise a stat forever.
- **Gear:** one weapon and one armor per character, made for that character only. Beating a boss unlocks the next upgrade in the shop.
- **Leveling up:** every stat goes up by 1, plus 1 bonus point the player chooses.

## Rachel: story and characters

Your writing decides what Joli and Macy draw, so the first tasks are the ones that unblock them. Write in any document for now. Clayton will show you the story tool (Dialogic Software) later.

**Start here:**

- [ ] Story outline: beginning, middle, end (about 5 hours of play)
- [ ] Main party: names, personalities, rough look, how they fight (weapon choice)
- [ ] Main enemies and bosses: who they are and why they fight the party

**Then, for the artists:**

- [ ] A short description of each character for Joli (look, outfit, colors, vibe)
- [ ] Which expressions each character's portrait needs (happy, sad, angry...)
- [ ] A short description of each enemy and boss for Macy
- [ ] A list of places that need backgrounds

**Then, for battles:**

- [ ] Which story moments unlock each pair's tag-team attack
- [ ] What bosses say during fights (phase changes, reactions)
- [ ] Scene scripts

**Later:** title ideas, item and gear names.

## Joli: 2D main characters, Attack sprites and items

The party is waiting on Rachel's character list, so start with style tests. Sizes are set once the art style is chosen.

**Start here:**

- [ ] Style tests: try pixel art and illustrated so the team can pick one
- [ ] Concept sketches once Rachel shares the main characters

**For each party member:**

- [ ] Portraits, one per expression: `portrait_<name>_<expression>.png`
- [ ] Battle sprite, standing: `sprite_<name>_idle.png`
- [ ] Special attack pose (low priority): `sprite_<name>_special.png`

**Attack animations for each party member (after the basics work):**

- [ ] Quick attack, power attack, and special attack
- [ ] Tag-team attacks with each partner (pairs unlock through the story)
- [ ] Shared effects: hit flash, critical hit, heal sparkle, buff and debuff
- [ ] Defend
- [ ] Getting hit
- [ ] Victory pose after winning a battle: `sprite_<name>_victory.png`

Glows and color changes are done in code. Only draw frames for real movement.

**Items (any time):**

- [ ] HP potion: `icon_hp_potion.png`
- [ ] Meter boost: `icon_meter_boost.png`
- [ ] Stat potions: `icon_atk_potion.png`, `icon_def_potion.png`, `icon_spd_potion.png`, `icon_mag_potion.png`

**Later:** an icon for each weapon and armor upgrade: `icon_<name>_weapon_<tier>.png`, `icon_<name>_armor_<tier>.png` (one per boss, plus starting gear).

## Macy: enemies, bosses, and attacks

Enemies come from Rachel's story, so start with style tests and rough ideas.

**Start here:**

- [ ] Style tests (match whatever style the team picks with Joli)
- [ ] Rough enemy ideas once Rachel shares the main enemies

**For each enemy:**

- [ ] Battle sprite: `sprite_<enemy>_idle.png`

**For each boss:**

- [ ] Battle sprite: `sprite_<boss>_idle.png`
- [ ] Portraits, bosses talk during battle: `portrait_<boss>_<expression>.png`
- [ ] Wind-up pose that warns a big attack is coming: `sprite_<boss>_windup.png`

**Enemy and boss attacks (after the basics work):**

- [ ] Attack animations for each enemy and boss
- [ ] Shared effects: hit flash, critical hit, heal sparkle, buff and debuff

**Tip:** glows, growing, and color changes are done in code. Only draw extra frames when something really moves (a flag waving, fire flickering).

## Music and sound (open, we're looking)

Nobody has this role yet. The game uses free stand-in sounds until someone joins. This list is ready for them on day one.

Music is `.ogg`, sound effects are `.wav`.

**Music:**

- [ ] Battle theme, loops smoothly: `music_battle.ogg`
- [ ] Boss theme, could build up in later phases: `music_boss.ogg`
- [ ] Victory and defeat jingles, short: `music_victory.ogg`, `music_defeat.ogg`
- [ ] Story scene music by mood (moods come from Rachel): `music_<mood>.ogg`

**Sound effects:**

- [ ] Attacks: `sfx_quick_attack.wav`, `sfx_power_attack.wav`, `sfx_special_attack.wav`, `sfx_crit.wav`
- [ ] Battle: `sfx_defend.wav`, `sfx_heal.wav`, `sfx_buff.wav`, `sfx_debuff.wav`, `sfx_stun.wav`, `sfx_item.wav`
- [ ] Menus: `sfx_cursor.wav`, `sfx_confirm.wav`, `sfx_cancel.wav`

## Clayton: programming

**Game data:**

- [x] Characters and moves
- [x] Status effects (Stun, Attack up/down, Defense up/down)
- [x] Items
- [x] Weapons and armor
- [x] Enemy groups

**Battles:**

- [x] Basic battle: rounds, turn order, quick and power attacks, win or lose
- [ ] Skill meter and special attacks
- [ ] Defend and items
- [ ] Status effects and critical hits
- [ ] Tag-team attacks
- [ ] Smarter enemies, boss phases
- [ ] Timed cool moves

**Main hub and menus:**

- [ ] Title screen: New Game, Continue, Settings, Quit (a bare one with Start exists)
- [ ] Main hub: the map where you pick the next place (hover shows the name and a short description, click to go)
- [ ] Party menu: stats, level-up bonus point, equipment, items (stat potions are used here)
- [ ] Shop: buy the next gear tier and potions
- [ ] Save and load
- [ ] Pause menu during battles and story scenes
- [ ] Settings: music and sound volume, text speed, fullscreen

Art this needs (not assigned yet): title logo, title screen background, hub map, menu frames.

**Later (gaps to fill when each feature is built):**

- [ ] Skills that heal, buff, or cause status effects (Stun, Attack down...)
- [ ] Defend: how much it raises DEF
- [ ] Skill meter: filling it from taking damage and helping allies
- [ ] Per-turn effects like poison and regen (only a simple version exists)
- [ ] Levels and XP: character levels, XP needed per level, XP from enemies
- [ ] Money: rewards from battles, connect shop prices
- [ ] Enemy AI settings: how smart each enemy is
- [ ] Boss phases: what changes at each health threshold
- [ ] Game progress: party levels, gear owned, items, bosses beaten, story progress (needed for saving and the shop)
- [ ] Battle music: play the battle theme or boss theme by battle type, plus special songs for story fights
- [ ] Default battle background when a fight doesn't set one
- [ ] Maybe: a small high/low roll on damage (right now every hit does the same damage)
- [ ] Smarter enemy choices (right now enemies pick a random move and target)
- [ ] Keyboard and controller controls in battle (right now mouse only)
- [ ] Retune the pause between battle actions once attack animations exist

**Not assigned yet (art):**

- Status effect icons: `icon_stun.png`, `icon_atk_up.png`, `icon_atk_down.png`, `icon_def_up.png`, `icon_def_down.png`
- Battle screen pieces: action menu, HP bar, skill meter bar, target cursor
- Backgrounds for battles and story scenes: `bg_<place>_<variant>.png`

## Handing in your work

No coding needed. Make it, name it, send it, and Clayton puts it in the game.

1. **Export** it: pictures as PNG (transparent background for characters, enemies, icons), music as OGG, sounds as WAV.
2. **Name** it like your task list shows.
3. **Post** it in our Discord and say what it is ("HP potion icon done"). Too big for Discord? Tell Clayton.
4. **Keep** your original working file (Photoshop, Procreate, etc.) safe for later fixes.

**Fixing something?** Export with the exact same name and send it again. It replaces the old one automatically.

**Naming rules:** lowercase, underscores instead of spaces, no special characters.

| Good | Avoid |
|---|---|
| `portrait_mira_happy.png` | `Mira Happy FINAL v2.png` |
| `icon_stun.png` | `stun icon.png` |

("Mira" is just an example name.)
