class_name BattleUnit
extends RefCounted
## One fighter during a battle: a party member or an enemy.
## Copies its numbers from a UnitData template when the battle starts, so
## changes here (like losing HP) never touch the template file.

signal hp_changed(unit: BattleUnit, current_hp: int, max_hp: int)
signal died(unit: BattleUnit)
signal meter_changed(unit: BattleUnit, meter: int, meter_max: int)
signal defending_changed(unit: BattleUnit, defending: bool)
## Status effects were added, removed, or counted down.
signal effects_changed(unit: BattleUnit)

var data: UnitData
## Shown in battle, e.g. "Test Slime B" when the same enemy appears more than once.
var display_name: String
var is_party: bool

## Base stats (template + gear). Status effects adjust them through
## current_atk() / current_def() / current_spd() / current_mag().
var max_hp: int
var current_hp: int
var atk: int
var def: int
var spd: int
var mag: int

## Active status effects -> rounds left (for Stun: turns left to skip).
var effects: Dictionary[StatusEffect, int] = {}
## How many times this unit was stunned this battle (each one lowers the next chance).
var stuns_received: int = 0

## Units without a meter (basic enemies) always stay at 0.
var has_meter: bool
var meter: int = 0
var meter_max: int = 100

## Hidden. Party members gain up to this much extra crit chance as HP drops (set by Battle).
var crit_low_hp_bonus: float = 0.0

## While defending, DEF counts as def × defend_multiplier (set by Battle).
var defending: bool = false
var defend_multiplier: float = 1.5


func _init(unit_data: UnitData, on_party: bool, name_suffix: String = "") -> void:
	data = unit_data
	is_party = on_party
	display_name = unit_data.display_name
	if name_suffix != "":
		display_name += " " + name_suffix

	max_hp = unit_data.max_hp
	atk = unit_data.atk
	def = unit_data.def
	spd = unit_data.spd
	mag = unit_data.mag
	# Until game progress exists, party members wear their starting gear (tier 0).
	if not unit_data.weapons.is_empty():
		_add_gear_bonuses(unit_data.weapons[0])
	if not unit_data.armors.is_empty():
		_add_gear_bonuses(unit_data.armors[0])
	current_hp = max_hp
	has_meter = unit_data.has_skill_meter


func is_alive() -> bool:
	return current_hp > 0


func is_meter_full() -> bool:
	return has_meter and meter >= meter_max


## Can this unit use the skill right now? Specials need a full meter.
func can_use(skill: SkillData) -> bool:
	return skill != null and (not skill.requires_full_meter or is_meter_full())


## Adds meter (capped at full). Does nothing for units without a meter.
func add_meter(amount: int) -> void:
	if not has_meter or amount == 0:
		return
	meter = clampi(meter + amount, 0, meter_max)
	meter_changed.emit(self, meter, meter_max)


func set_defending(value: bool) -> void:
	if defending == value:
		return
	defending = value
	defending_changed.emit(self, defending)


## DEF used when this unit is hit: status effects, then the Defend boost.
func effective_def() -> int:
	return roundi(current_def() * defend_multiplier) if defending else current_def()


func current_atk() -> int:
	return _with_effects(atk, &"atk_percent")


func current_def() -> int:
	return _with_effects(def, &"def_percent")


func current_spd() -> int:
	return _with_effects(spd, &"spd_percent")


func current_mag() -> int:
	return _with_effects(mag, &"mag_percent")


## Adds a status effect (or resets its timer if the unit already has it).
## No stacking: an effect that changes the same stat as this one is removed first.
## Returns false if the unit is immune (bosses and Stun).
func apply_effect(effect: StatusEffect) -> bool:
	if effect.skips_turn and data.immune_to_stun:
		return false
	for old: StatusEffect in effects.keys():
		if old != effect and old.shares_stat_with(effect):
			effects.erase(old)
	effects[effect] = effect.duration
	if effect.skips_turn:
		stuns_received += 1
	effects_changed.emit(self)
	return true


func is_stunned() -> bool:
	return effects.keys().any(func(e: StatusEffect) -> bool: return e.skips_turn)


## Uses up one skipped turn from a Stun-like effect (called when the turn is skipped).
func consume_stun() -> void:
	for effect: StatusEffect in effects.keys():
		if effect.skips_turn:
			effects[effect] -= 1
			if effects[effect] <= 0:
				effects.erase(effect)
	effects_changed.emit(self)


## End of round: counts every effect down by one and removes finished ones.
## Stun-like effects only count down when a turn is actually skipped.
func tick_effects() -> void:
	if effects.is_empty():
		return
	for effect: StatusEffect in effects.keys():
		if effect.skips_turn:
			continue
		effects[effect] -= 1
		if effects[effect] <= 0:
			effects.erase(effect)
	effects_changed.emit(self)


## Applies a status effect's percent changes to one base stat.
func _with_effects(base: int, percent_field: StringName) -> int:
	var percent: int = 0
	for effect: StatusEffect in effects:
		percent += effect.get(percent_field)
	if percent == 0:
		return base
	return maxi(0, roundi(base * (1.0 + percent / 100.0)))


func empty_meter() -> void:
	if not has_meter:
		return
	meter = 0
	meter_changed.emit(self, meter, meter_max)


## Lowers HP (never below 0) and returns the damage actually taken.
func take_damage(amount: int) -> int:
	var taken: int = mini(amount, current_hp)
	current_hp -= taken
	hp_changed.emit(self, current_hp, max_hp)
	if current_hp == 0:
		died.emit(self)
	return taken


## Raises HP (never above max) and returns the HP actually restored.
func heal(amount: int) -> int:
	var healed: int = mini(amount, max_hp - current_hp)
	current_hp += healed
	hp_changed.emit(self, current_hp, max_hp)
	return healed


## Chance this unit's next hit is critical. Base chance, plus (party only) a
## bonus that grows as HP drops: none at full HP, the whole bonus at 0 HP.
func crit_chance() -> float:
	var missing_hp: float = 1.0 - float(current_hp) / max_hp
	var bonus: float = crit_low_hp_bonus * missing_hp if is_party else 0.0
	return data.base_crit_chance + bonus


## How much damage this unit's skill would deal to the target.
## multiplier scales the skill's power (e.g. 1.5 for a critical hit).
func damage_against(target: BattleUnit, skill: SkillData, multiplier: float = 1.0) -> int:
	var attack_stat: int = current_mag() if skill.damage_type == SkillData.DamageType.MAGIC else current_atk()
	return calculate_damage(skill.power * multiplier, attack_stat, target.effective_def())


## damage = power × ATK × ATK ÷ (ATK + DEF), rounded, minimum 1.
static func calculate_damage(power: float, attack_stat: int, defense: int) -> int:
	if attack_stat + defense <= 0:
		return 1
	var raw: float = power * attack_stat * attack_stat / float(attack_stat + defense)
	return maxi(1, roundi(raw))


func _add_gear_bonuses(gear: Equipment) -> void:
	max_hp += gear.max_hp_bonus
	atk += gear.atk_bonus
	def += gear.def_bonus
	spd += gear.spd_bonus
	mag += gear.mag_bonus
