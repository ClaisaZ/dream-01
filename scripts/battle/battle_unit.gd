class_name BattleUnit
extends RefCounted
## One fighter during a battle: a party member or an enemy.
## Copies its numbers from a UnitData template when the battle starts, so
## changes here (like losing HP) never touch the template file.

signal hp_changed(unit: BattleUnit, current_hp: int, max_hp: int)
signal died(unit: BattleUnit)
signal meter_changed(unit: BattleUnit, meter: int, meter_max: int)

var data: UnitData
## Shown in battle, e.g. "Test Slime B" when the same enemy appears more than once.
var display_name: String
var is_party: bool

var max_hp: int
var current_hp: int
var atk: int
var def: int
var spd: int
var mag: int

## Units without a meter (basic enemies) always stay at 0.
var has_meter: bool
var meter: int = 0
var meter_max: int = 100


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


## How much damage this unit's skill would deal to the target.
func damage_against(target: BattleUnit, skill: SkillData) -> int:
	var attack_stat: int = mag if skill.damage_type == SkillData.DamageType.MAGIC else atk
	return calculate_damage(skill.power, attack_stat, target.def)


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
