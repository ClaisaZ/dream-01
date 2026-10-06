# CLAUDE.md

Guidance for Claude Code when working in this repo (dream-01).

## How to work with me

- **Go step by step, at a slow pace.** Do one step, explain it in plain language, then stop and wait for me before the next one. Don't build several features in one go.
- I'm learning Godot. Briefly explain new Godot or Git concepts the first time they come up.
- Ask before anything destructive: deleting files, force pushes, rewriting history, or large refactors.
- When a design question isn't answered below, ask me instead of guessing. Design decisions are made with the team.

## The project

A short (~5 hour) JRPG-inspired, turn-based game where the story is told through visual novel scenes. Built by a team of four as a passion project (no deadline):

- **Me:** programming and systems (engine, combat, menus, saves, integrating everyone's work)
- **Sister:** story and writing (writes scenes as Dialogic timelines)
- **Cousin:** art (portraits, sprites, backgrounds, UI, effects)
- **Friend:** music and audio

Art, story, and audio arrive later. Programming comes first, **built with placeholders** (gray boxes, temp numbers) so nobody waits on anybody.

The full design doc lives on claude.ai (Game Design Doc). This file summarizes what matters for code.

### Design pillars

1. **Every battle tells a story.** Battles matter to the plot; big fights are story moments, not filler.
2. **Respect the player's time.** Short battles (~5 min), no grinding.
3. **Stronger together.** The party's bond is part of the gameplay.

If a feature doesn't support at least one pillar, flag it.

## Tech stack

- **Godot 4.7.2** (standard, not .NET). Don't suggest features from other versions.
- **GDScript with static typing everywhere** (typed variables, parameters, and return types).
- **Dialogic 2** (Alpha 20 or newer) for all story scenes. Installed in `/addons/dialogic/`. Don't modify files inside `/addons/`.
- **Renderer:** Compatibility (2D game).
- **Git LFS** tracks `*.png`, `*.ogg`, `*.wav`.

## Folder structure

```
/addons      plugins (Dialogic). Don't edit.
/scenes      battle, overworld, menus, VN scenes
/scripts     gameplay code
/scripts/data  Resource class scripts (UnitData, SkillData, ...)
/data        .tres files: units, skills, items, enemies, status effects
/art         portraits, sprites, backgrounds, ui
/audio       music, sfx
/dialogue    Dialogic timelines and characters
```

Asset naming: `type_name_variant.png`, e.g. `portrait_mira_happy.png`, `bg_forest_night.png`.

## Architecture rules

- **Data-driven.** Units, skills, items, equipment, status effects, enemy groups, and boss phases are Godot Resources saved as `.tres` files. Balancing should never require code changes.
- **Data files are templates and are never modified at runtime.** Battles copy values into separate runtime objects (e.g. a battle unit with current HP).
- **Scalable by default.** New content (a new status effect, enemy, or boss) should be a new data file, not new code.
- **Signals connect combat logic and UI.** Neither knows the other's internals.
- **Story ↔ battle hand-off goes through Dialogic.** Timelines send signals (e.g. `start_rival_battle`) to start battles; code starts timelines after battles and for boss dialogue.

## Combat design (current decisions)

**Turns:** round-based. Everyone acts once per round, ordered by SPD, adjusted by skill priority.

**Actions:** Quick attack, Power attack, Special attack (only when skill meter is full), Item, Defend. **No fleeing**: every battle is part of the story.

| | Quick attack | Power attack | Special attack |
|---|---|---|---|
| Power (starting) | 0.8 | 1.3 | 2.0 |
| Priority | +1 | -1 | 0 |
| Skill meter | fills a little | fills more | needs full meter, empties it |

**Damage formula:**
```
damage = power × ATK × ATK ÷ (ATK + DEF)    # rounded, minimum 1
```
Magic skills use MAG instead of ATK. (A separate magic defense may be added later.)

**Skill meter:** one per character, 0–100. Resets to empty every battle. Starting gains (to tune): quick attack +10, power attack +20. Fills from attacking, taking damage, and supporting allies (heals, buffs); Defend fills it only a little.

**Defend:** raises the character's DEF until their next turn (exact boost tuned in testing).

**Crits:** hidden from the player. Each character has a small base crit chance that rises as their HP drops. Crits deal ×1.5 damage and make tag-teams more likely.

**Tag-team attacks:** when two party members hit the same enemy in the same round, they can link into a tag-team attack. Each pair's tag-team is **unlocked by story events**, not available from the start. Trigger chance rises on crits, when the attacker is low on HP, or when the enemy is low on HP. (Exact rules to be tuned in the prototype.)

**Timed cool moves:** only special attacks and tag-teams get the pose + timed button press. Normal attacks stay fast. Build this last.

**Status effects (starting set):** Stun (skip next turn), ATK up/down, DEF up/down. Each lasts a set number of turns. A unit can't be stunned two rounds in a row. Every status effect is its own `.tres` file built from the same fields (duration, stat changes, skips turn, per-turn effect, icon).

**Enemy AI:** weighted randomness. Each move and target gets a score (strong attacks and low-HP targets score higher), then the enemy picks with some randomness. How "smart" each enemy is lives in its data file. Maybe later: a front/back-line formation.

**Bosses:** immune to stun, not to debuffs. Phases at HP thresholds (more attacks per round, stronger attacks, and/or party debuffs). Wind-up attacks telegraphed one round ahead. Battle dialogue via short Dialogic timelines on phase changes and reactions. Each phase is data on the boss, not new code.

**Items:** HP potion, skill meter boost, and permanent stat potions (ATK, DEF, SPD, MAG) that are rare rewards, not sold in shops.

**Equipment:** one weapon and one armor set per character. Shops sell the next tier up.

**Leveling:** +1 to every stat and +5 HP per level, plus 1 extra stat point the player assigns. Story moments grant new skills or passives. No catch-up XP for now.

## Build order for the combat prototype

1. Data Resources (UnitData, SkillData, then StatusEffect, Item, Equipment, EnemyGroup)
2. Basic battle: rounds, turn order with priority, quick and power attacks, damage formula, win/lose
3. Then layer on: skill meter + special attack, Defend, items, status effects, crits, tag-teams, enemy AI, boss phases
4. Timed cool moves last

Each step should leave the game playable.

## Git workflow

- `main`: stable. Only updated from `dev` through a pull request when a playable build is ready. **Never commit or push to `main` directly.**
- `dev`: where finished features come together.
- `feature/<name>`: one branch per feature (e.g. `feature/battle-data`), branched from `dev`, merged back into `dev` through a pull request.
- Before switching branches, remind me to save and close Godot (or reload from disk afterward).
- Never commit `.godot/` or `/builds/`.
- Short, clear commit messages describing what changed.

## Current status

- Project created, folders set up, Git LFS configured, `dev` branch created.
- Dialogic 2 installed and merged into `dev`.
- Working on `feature/battle-data`: `UnitData` and `SkillData` scripts in `scripts/data/`. First data files: `data/skills/` (quick, power, special attack) and `data/units/test_hero.tres` (placeholder unit).
- Next: remaining data Resources (StatusEffect, Item, Equipment, EnemyGroup).
- Still undecided (don't assume): working title, story/characters, pixel art vs. illustrated (sets base resolution: 640×360 or 1920×1080), elements, release target.
