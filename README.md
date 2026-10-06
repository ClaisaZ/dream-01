<div align="center">

# ✦ dream-01 ✦

**A short, story-driven, turn-based RPG where every battle is a chapter.**

*Working title. The real name is still being dreamed up.*

![Godot 4.7.2](https://img.shields.io/badge/Godot-4.7.2-478CBF?logo=godotengine&logoColor=white)
![GDScript](https://img.shields.io/badge/GDScript-static%20typed-355570)
![Dialogic 2](https://img.shields.io/badge/Dialogic-2-8A63D2)
![Status](https://img.shields.io/badge/status-combat%20prototype-orange)

</div>

---

## The game

A JRPG-inspired adventure of about five hours. The story is told through visual novel scenes, and the fights are turn-based battles that *are* the story, not breaks from it.

Three pillars guide every decision:

| | Pillar | What it means |
|:---:|---|---|
| 📖 | **Every battle tells a story** | Fights matter to the plot. Big battles are story moments, not filler. |
| ⏳ | **Respect the player's time** | Battles take about 5 minutes. No grinding. |
| 🤝 | **Stronger together** | The party's bond is part of how you win: tag-team attacks unlock through the story. |

## How battles play

- **Round-based turns.** Everyone acts once per round. Faster moves jump the line, heavy ones go last.
- **Quick, Power, or Special.** Quick hits early, Power hits hard but late, and Special lands a big hit once your skill meter is full.
- **Skill meter.** Fills as you attack and take hits. Fill it, then cash it in.
- **Defend and items.** Brace for a big hit, or patch up an ally from the party's shared bag.
- **No running away.** Every battle is part of the story.
- **Coming soon:** hidden critical hits, status effects, tag-team attacks, boss phases with telegraphed wind-ups, and timed "cool moves".

## Progress

```
[██████████] Step 1  Game data: units, skills, items, gear, status effects, enemy groups
[██████████] Step 2  First playable battle + title screen
[████░░░░░░] Step 3  Battle extras: meter ✓ special ✓ defend ✓ items ✓ · crits, status effects, tag-teams, AI, bosses
[░░░░░░░░░░] Step 4  Timed cool moves
```

Everything is built with **gray-box placeholders** first, so programming never waits on art, music, or story.

## The team

A team of four making this as a passion project, with no deadline.

| Role | Who |
|---|---|
| 💻 Programming and systems | Clayton |
| ✍️ Story, script, and characters | Rachel |
| 🎨 Party portraits, sprites, and items | Joli |
| 👾 Enemies, bosses, and attacks | Macy |
| 🎵 Music and sound | *Open! We're looking for someone.* |

Want to see what everyone's working on? The **[Bible](BIBLE.md)** has the plan and each person's task list.

## Run it yourself

1. Install **[Godot 4.7.2](https://godotengine.org/download)** (standard version, not .NET).
2. Install **[Git LFS](https://git-lfs.com/)** (art and audio files are stored with it), then:
   ```bash
   git lfs install
   git clone https://github.com/ClaisaZ/dream-01.git
   ```
3. Open Godot, click **Import**, and pick `project.godot`.
4. Press **F5**. Title screen → **Start** → fight!

## Under the hood

- **Data-driven:** units, skills, items, gear, status effects, and enemy groups are Godot Resources saved as `.tres` files. Balancing is done in data, never in code.
- **Templates stay templates:** battles copy data into their own runtime objects, so nothing on disk changes while you play.
- **Signals between logic and UI:** the battle logic never touches the screen, and the screen never reaches into the battle.
- **Story through Dialogic 2:** timelines start battles, and battles hand back to timelines.

```
addons/     plugins (Dialogic)
art/        portraits, sprites, backgrounds, UI
audio/      music and sound effects
data/       .tres game data: units, skills, items, enemies...
dialogue/   Dialogic timelines and characters
scenes/     battle, menus, story scenes
scripts/    game code (scripts/data = data types, scripts/battle = combat)
```

## Branches

| Branch | Purpose |
|---|---|
| `main` | Stable, playable builds |
| `dev` | Finished features come together here |
| `feature/*` | One branch per feature, merged into `dev` by pull request |

---

<div align="center">

*Made with ✦ by a small team with a big dream.*

</div>
