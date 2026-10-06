class_name BattleRules
extends Resource
## Battle-wide numbers that aren't tied to one unit or skill.
## There's one file, /data/battle_rules.tres. Tune it there, never in code.

@export_group("Defend")
## A defending unit's DEF is multiplied by this for the rest of the round.
@export var defend_def_multiplier: float = 1.5

@export_group("Skill Meter")
## A full meter. Specials need this much.
@export var meter_max: int = 100
## Meter gained each time a unit with a meter is hit.
@export var meter_gain_when_hit: int = 5
## Multiplies meter_gain_when_hit when the hit was a critical (used once crits exist).
@export var meter_crit_multiplier: float = 2.0
