class_name SkillData
extends Resource
## A move a unit can use in battle: quick attack, power attack, special attack, heals, buffs...
## Each skill is saved as its own .tres file in /data/skills/.

enum DamageType { PHYSICAL, MAGIC }
enum TargetType { SINGLE_ENEMY, ALL_ENEMIES, SINGLE_ALLY, ALL_ALLIES, SELF }

@export var display_name: String = ""
@export_multiline var description: String = ""

@export_group("Combat")
## PHYSICAL uses ATK in the damage formula, MAGIC uses MAG.
@export var damage_type: DamageType = DamageType.PHYSICAL
@export var target_type: TargetType = TargetType.SINGLE_ENEMY
## Damage multiplier. Starting values: quick 0.8, power 1.3, special 2.0. Use 0 for non-damage skills.
@export var power: float = 1.0
## +1 acts earlier in the round, -1 acts later. Quick attack +1, power attack -1.
@export var priority: int = 0

@export_group("Skill Meter")
## How much skill meter the user gains when using this skill.
@export var skill_meter_gain: float = 0.0
## True for special attacks: needs a full skill meter and empties it.
@export var requires_full_meter: bool = false