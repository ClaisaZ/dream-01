class_name StatusEffect
extends Resource
## A temporary effect on a unit: Stun, ATK up/down, DEF up/down...
## Each status effect is saved as its own .tres file in /data/status_effects/.
## Rules like "can't be stunned two rounds in a row" or "bosses are immune to stun"
## live in the battle code, not here.

@export var display_name: String = ""
@export_multiline var description: String = ""
## Placeholder is fine until the real art arrives.
@export var icon: Texture2D

## How many turns the effect lasts on the affected unit.
@export_range(1, 10) var duration: int = 1

@export_group("Stat Changes")
## Percent change while active. 20 = +20%, -20 = -20%. 0 = no change.
@export_range(-100, 100, 1, "suffix:%") var atk_percent: int = 0
@export_range(-100, 100, 1, "suffix:%") var def_percent: int = 0
@export_range(-100, 100, 1, "suffix:%") var spd_percent: int = 0
@export_range(-100, 100, 1, "suffix:%") var mag_percent: int = 0

@export_group("Turn Effects")
## True for Stun: the unit skips its turn.
@export var skips_turn: bool = false
## HP change each turn, as a percent of max HP. Negative = damage (poison), positive = healing (regen).
## Simple version for now; to be expanded later.
@export_range(-100, 100, 1, "suffix:%") var hp_percent_per_turn: int = 0
