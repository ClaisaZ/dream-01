# Asset List

Everything the game needs from art and audio.

**You don't need to know any coding or open the game project.** Make the files, name them the way this page shows, and hand them over (see below). The programmer puts them into the game.

Until your files arrive, the game uses gray boxes and silence as stand-ins. Nothing you make is blocking anyone, so take your time.

**Status in the lists:** ⬜ not started · 🟨 in progress · ✅ done

---

## How to hand over your files

1. **Make the file** in whatever program you like.
2. **Export it** in the format listed below for your role.
3. **Name it** exactly like the list shows (see "Naming rules").
4. **Post it in our Discord** and mention what it is (e.g. "ATK up icon done"). If a file is too big for Discord to upload, tell the programmer and we'll sort it out.
5. **Keep your original working file** (Photoshop, Procreate, Aseprite, FL Studio, etc.) safe on your own computer. If something needs a tweak later, you'll want it.

(We may move to Google Drive later. This page will be updated if we do.)

**Fixing or redoing something?** Export it with the **exact same name** as before and replace the old one. The game picks up the new version automatically and nothing else needs to change.

### Naming rules

- All **lowercase**
- **Underscores** instead of spaces: `hp_potion`, not `HP Potion`
- No special characters (no `!`, `?`, `'`, `é`, etc.)
- Follow the pattern **what it is \_ who/what \_ which version**

| ✅ Good | ❌ Avoid |
|---|---|
| `portrait_mira_happy.png` | `Mira Happy FINAL v2.png` |
| `icon_stun.png` | `stun icon.png` |
| `sfx_quick_attack.wav` | `QuickAttack_sound(1).wav` |

(Mira is just an example name. Real character names aren't decided yet.)

---

## Before you start: decisions still open

- **Art style:** pixel art or illustrated? This decides the size of everything. Until it's chosen, sizes below say *TBD*. Sketches and concepts are still very welcome.
- **Characters and story:** names, looks, and how many party members and enemies there are aren't decided yet.

---

## Art (Cousin)

**Export format:** PNG.
- Characters, enemies, icons, and UI pieces: **transparent background** (no white box behind them).
- Backgrounds: no transparency needed.

### Party members (one set per character)

| What | File name | Notes | Status |
|---|---|---|---|
| Story portraits | `portrait_<name>_<expression>.png` | Shown during story scenes. One file per expression (e.g. neutral, happy, sad, angry). Check with the writer for which expressions each character needs. | ⬜ |
| Battle sprite | `sprite_<name>_idle.png` | The character standing in battle. | ⬜ |
| Special attack pose | `sprite_<name>_special.png` | A cool pose for their special move. Low priority, comes last. | ⬜ |

### Enemies and bosses (one set per enemy)

| What | File name | Notes | Status |
|---|---|---|---|
| Battle sprite | `sprite_<enemy>_idle.png` | | ⬜ |
| Boss portraits | `portrait_<boss>_<expression>.png` | Bosses talk during battle. | ⬜ |
| Boss wind-up pose | `sprite_<boss>_windup.png` | Warns the player a big attack is coming. | ⬜ |

### Status effect icons

Small symbols shown next to a character during battle. They need to be readable when tiny (about the size of a letter on screen).

| Effect | What it means | File name | Status |
|---|---|---|---|
| Stun | Skips their next turn | `icon_stun.png` | ⬜ |
| ATK up | Hits harder | `icon_atk_up.png` | ⬜ |
| ATK down | Hits weaker | `icon_atk_down.png` | ⬜ |
| DEF up | Takes less damage | `icon_def_up.png` | ⬜ |
| DEF down | Takes more damage | `icon_def_down.png` | ⬜ |

### Item icons

| Item | What it does | File name | Status |
|---|---|---|---|
| HP potion | Heals | `icon_hp_potion.png` | ⬜ |
| Skill meter boost | Fills the special attack meter | `icon_meter_boost.png` | ⬜ |
| ATK potion | Permanently raises attack | `icon_atk_potion.png` | ⬜ |
| DEF potion | Permanently raises defense | `icon_def_potion.png` | ⬜ |
| SPD potion | Permanently raises speed | `icon_spd_potion.png` | ⬜ |
| MAG potion | Permanently raises magic | `icon_mag_potion.png` | ⬜ |

### Battle screen pieces

| What | File name | Notes | Status |
|---|---|---|---|
| Action menu | `ui_action_menu.png` | Holds 5 choices: Quick attack, Power attack, Special, Item, Defend. | ⬜ |
| HP bar | `ui_hp_bar.png` | Shows each character's health. | ⬜ |
| Skill meter bar | `ui_skill_meter.png` | Fills up as the character fights. Should look exciting when full (that's when the special attack unlocks). | ⬜ |
| Target cursor | `ui_cursor.png` | Points at whoever the player is choosing. | ⬜ |

It's fine to start with rough versions. The programmer can show you how they look in the game and you can adjust from there.

### Backgrounds

| What | File name | Notes | Status |
|---|---|---|---|
| Battle backgrounds | `bg_<place>_<variant>.png` | e.g. `bg_forest_night.png`. List depends on the story. | ⬜ |
| Story scene backgrounds | `bg_<place>_<variant>.png` | Same naming. List depends on the story. | ⬜ |

### Effects (later)

Hit flash, critical hit, heal sparkle, buff/debuff, special attacks, tag-team attacks. Low priority. We'll talk about these once the basics are in.

---

## Audio (Friend)

**Export format:**
- Music: **OGG** (`.ogg`)
- Sound effects: **WAV** (`.wav`)

| What | File name | Notes | Status |
|---|---|---|---|
| Normal battle theme | `music_battle.ogg` | Battles last about 5 minutes, so it should **loop smoothly** (the end flows back into the start). | ⬜ |
| Boss battle theme | `music_boss.ogg` | Could get more intense in later phases of the fight. | ⬜ |
| Victory jingle | `music_victory.ogg` | Short, plays once. | ⬜ |
| Defeat jingle | `music_defeat.ogg` | Short, plays once. | ⬜ |
| Story scene music | `music_<mood>.ogg` | e.g. `music_calm.ogg`, `music_tense.ogg`. Moods TBD with the writer. | ⬜ |
| Attack sounds | `sfx_quick_attack.wav`, `sfx_power_attack.wav`, `sfx_special_attack.wav`, `sfx_crit.wav` | Quick = light and fast, power = heavy, special = big. Crit plays on a lucky extra-strong hit. | ⬜ |
| Battle sounds | `sfx_defend.wav`, `sfx_heal.wav`, `sfx_buff.wav`, `sfx_debuff.wav`, `sfx_stun.wav`, `sfx_item.wav` | | ⬜ |
| Menu sounds | `sfx_cursor.wav`, `sfx_confirm.wav`, `sfx_cancel.wav` | Moving through menus, picking something, going back. | ⬜ |

---

## Story (Sister)

Story scenes are built in a Godot plugin called **Dialogic**. The programmer will set it up and show you how to use it when you're ready. Until then, writing in any document is perfect.

Your writing also decides a lot of the list above, so please note down:

- Each character's **name** and the **expressions** their portraits need
- **Places** that need backgrounds
- Which **story moments unlock tag-team attacks** (two characters teaming up)
- What bosses **say during battle** (when they get angry, change phases, etc.)
