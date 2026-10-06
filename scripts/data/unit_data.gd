
class_name UnitData
extends Resource
## The template for a party member or enemy: base stats, moves, and art.
## Each unit is saved as its own .tres file in /data/units/.
## This file is never changed during battle. Battles copy these values
## into a separate battle unit, so current HP etc. never overwrite the template.

@export var display_name: String = ""

@export_group("Stats")
@export var max_hp: int = 100
@export var atk: int = 10
@export var def: int = 10
@export var spd: int = 10
## Most characters use either ATK or MAG, not both. Kept on everyone for future expansion.
@export var mag: int = 10

@export_group("Hidden")
## Base crit chance (0.05 = 5%). Hidden from the player; rises as HP drops.
@export_range(0.0, 1.0, 0.01) var base_crit_chance: float = 0.05

@export_group("Moves")
@export var quick_attack: SkillData
@export var power_attack: SkillData
@export var special_attack: SkillData
## Any extra skills (heals, buffs...). Can stay empty for now.
@export var extra_skills: Array[SkillData] = []

@export_group("Art")
## Placeholders are fine until the real art arrives.
@export var portrait: Texture2D
@export var battle_sprite: Texture2D