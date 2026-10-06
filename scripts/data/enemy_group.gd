class_name EnemyGroup
extends Resource
## Who the party fights in one battle. Enemies are normal UnitData files;
## the same enemy can appear more than once (the battle labels them A, B, C...).
## Each group is saved as its own .tres file in /data/enemy_groups/.

enum BattleType { NORMAL, ELITE, BOSS }

const MAX_ENEMIES: int = 4

@export var display_name: String = ""
## 1 to 4 enemies (MAX_ENEMIES). Bosses and elites are usually alone.
@export var enemies: Array[UnitData] = []
## Picks the default music: NORMAL and ELITE use the battle theme, BOSS uses the boss theme.
@export var battle_type: BattleType = BattleType.NORMAL

@export_group("Presentation")
## Empty = use the default battle background.
@export var background: Texture2D
## Empty = use the default theme for this battle type. Set it for special story fights.
@export var music_override: AudioStream
