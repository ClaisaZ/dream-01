class_name Item
extends Resource
## A usable item: HP potion, skill meter boost, permanent stat potions...
## Each item is saved as its own .tres file in /data/items/.

enum Effect { HEAL_HP, FILL_METER, RAISE_STAT }
enum Stat { ATK, DEF, SPD, MAG }

@export var display_name: String = ""
@export_multiline var description: String = ""
## Placeholder is fine until the real art arrives.
@export var icon: Texture2D

@export_group("Effect")
@export var effect: Effect = Effect.HEAL_HP
## What "amount" means depends on the effect:
## HEAL_HP = percent of max HP, FILL_METER = meter points (meter is 0-100), RAISE_STAT = stat points.
@export var amount: int = 0
## Only used when effect is RAISE_STAT.
@export var stat: Stat = Stat.ATK
@export var target_type: SkillData.TargetType = SkillData.TargetType.SINGLE_ALLY

@export_group("Usage")
@export var usable_in_battle: bool = true
@export var usable_outside_battle: bool = true
## Using an item takes the character's turn. 3 = acts first of all (before Defend +2).
@export var priority: int = 3

@export_group("Shop")
## 0 = not sold in shops (e.g. rare stat potions).
@export var price: int = 0
