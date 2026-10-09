class_name StatusEffect
extends Resource
## A temporary effect on a unit: Stun, ATK up/down, DEF up/down, Bleed, Poison...
## Each status effect is saved as its own .tres file in /data/status_effects/.
## No stacking: getting the same effect again resets its timer, and a new effect
## replaces any old one that changes the same stat (ATK down replaces ATK up).
## Stun resistance lives in BattleRules; stun immunity in UnitData.

@export var display_name: String = ""
@export_multiline var description: String = ""
## Placeholder is fine until the real art arrives.
@export var icon: Texture2D
## Short label for the placeholder icon until real icons exist, e.g. "PSN".
@export var short_name: String = ""

## Rounds the effect lasts. For effects that skip turns (Stun): turns skipped.
@export_range(1, 10) var duration: int = 1

@export_group("Stat Changes")
## Percent change while active. 20 = +20%, -20 = -20%. 0 = no change.
@export_range(-100, 100, 1, "suffix:%") var atk_percent: int = 0
@export_range(-100, 100, 1, "suffix:%") var def_percent: int = 0
@export_range(-100, 100, 1, "suffix:%") var spd_percent: int = 0
@export_range(-100, 100, 1, "suffix:%") var mag_percent: int = 0

@export_group("Turn Effects")
## True for Stun: the unit skips its next turn.
@export var skips_turn: bool = false
## HP change at the end of each round, as a percent of max HP.
## Negative = damage (bleed, poison), positive = healing (regen).
## Simple version for now; to be expanded later.
@export_range(-100, 100, 1, "suffix:%") var hp_percent_per_turn: int = 0


## True if both effects change at least one of the same stats.
## Used for "no stacking": the newer one replaces the older one.
func shares_stat_with(other: StatusEffect) -> bool:
	return (atk_percent != 0 and other.atk_percent != 0) \
			or (def_percent != 0 and other.def_percent != 0) \
			or (spd_percent != 0 and other.spd_percent != 0) \
			or (mag_percent != 0 and other.mag_percent != 0)
