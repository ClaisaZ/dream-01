class_name BattleRules
extends Resource
## Battle-wide numbers that aren't tied to one unit or skill.
## There's one file, /data/battle_rules.tres. Tune it there, never in code.

@export_group("Critical Hits")
## Damage multiplier for a critical hit.
@export var crit_damage_multiplier: float = 1.5
## Extra crit chance for party members at (almost) 0 HP. It grows smoothly as HP
## drops: at half HP they get half of it. Enemies never get this bonus.
@export_range(0.0, 1.0, 0.01) var crit_low_hp_bonus: float = 0.20

@export_group("Tag-Team Attacks")
## Chance a tag-team triggers when two unlocked partners hit the same enemy in one round.
@export_range(0.0, 1.0, 0.01) var tag_team_base_chance: float = 0.15
## Extra chance if the second hit was a critical.
@export_range(0.0, 1.0, 0.01) var tag_team_crit_bonus: float = 0.15
## Extra chance if the second attacker is low on HP.
@export_range(0.0, 1.0, 0.01) var tag_team_low_hp_attacker_bonus: float = 0.10
## Extra chance if the enemy is low on HP.
@export_range(0.0, 1.0, 0.01) var tag_team_low_hp_enemy_bonus: float = 0.10
## "Low on HP" means below this share of max HP (0.3 = 30%).
@export_range(0.0, 1.0, 0.05) var tag_team_low_hp_threshold: float = 0.3

@export_group("Status Effects")
## Each stun a unit receives multiplies the chance of stunning it again this
## battle by this (0.5 = halves it every time).
@export_range(0.0, 1.0, 0.05) var stun_chance_after_stun: float = 0.5

@export_group("Defend")
## A defending unit's DEF is multiplied by this for the rest of the round.
@export var defend_def_multiplier: float = 1.5

@export_group("Skill Meter")
## A full meter. Specials need this much.
@export var meter_max: int = 100
## Meter gained each time a unit with a meter is hit.
@export var meter_gain_when_hit: int = 5
## Multiplies meter_gain_when_hit when the hit was a critical.
@export var meter_crit_multiplier: float = 2.0
