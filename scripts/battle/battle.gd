class_name Battle
extends RefCounted
## Runs one battle: rounds, turn order, attacks, win or lose.
## Holds no visuals. It reports what happens through signals, and a battle
## screen (or a test scene) listens and shows it.
##
## For now both sides pick automatically: a random Quick or Power attack on a
## random living target. Player choices come with the battle screen.

signal round_started(round_number: int)
signal action_performed(user: BattleUnit, target: BattleUnit, skill: SkillData, damage: int)
signal unit_defeated(unit: BattleUnit)
signal battle_ended(party_won: bool)

## Safety stop so a bug can never loop forever.
const MAX_ROUNDS: int = 100

var party: Array[BattleUnit] = []
var enemies: Array[BattleUnit] = []
var round_number: int = 0


## One unit's choice for the round.
class Action:
	var user: BattleUnit
	var skill: SkillData
	var target: BattleUnit

	func _init(p_user: BattleUnit, p_skill: SkillData, p_target: BattleUnit) -> void:
		user = p_user
		skill = p_skill
		target = p_target


func _init(party_data: Array[UnitData], enemy_group: EnemyGroup) -> void:
	party = _make_units(party_data, true)
	enemies = _make_units(enemy_group.enemies, false)
	for unit: BattleUnit in party + enemies:
		unit.died.connect(_on_unit_died)


## Plays the whole battle until one side is defeated.
func run() -> void:
	while not is_over() and round_number < MAX_ROUNDS:
		_run_round()
	battle_ended.emit(is_party_alive())


func is_over() -> bool:
	return not is_party_alive() or not _any_alive(enemies)


func is_party_alive() -> bool:
	return _any_alive(party)


func _run_round() -> void:
	round_number += 1
	round_started.emit(round_number)

	var actions: Array[Action] = []
	for unit: BattleUnit in party + enemies:
		if unit.is_alive():
			actions.append(_choose_action(unit))
	actions.sort_custom(_goes_before)

	for action: Action in actions:
		if is_over():
			return
		if not action.user.is_alive():
			continue
		# If the chosen target already fell this round, hit someone else on that side.
		if not action.target.is_alive():
			action.target = _random_alive(_opponents_of(action.user))
		var damage: int = action.user.damage_against(action.target, action.skill)
		action_performed.emit(action.user, action.target, action.skill, damage)
		action.target.take_damage(damage)


## Prototype choice for both sides: random Quick/Power attack, random living target.
func _choose_action(unit: BattleUnit) -> Action:
	var skills: Array[SkillData] = []
	for skill: SkillData in [unit.data.quick_attack, unit.data.power_attack]:
		if skill != null:
			skills.append(skill)
	return Action.new(unit, skills.pick_random(), _random_alive(_opponents_of(unit)))


## Turn order: higher priority first, then higher SPD, then the party wins ties.
func _goes_before(a: Action, b: Action) -> bool:
	if a.skill.priority != b.skill.priority:
		return a.skill.priority > b.skill.priority
	if a.user.spd != b.user.spd:
		return a.user.spd > b.user.spd
	return a.user.is_party and not b.user.is_party


func _opponents_of(unit: BattleUnit) -> Array[BattleUnit]:
	return enemies if unit.is_party else party


func _random_alive(units: Array[BattleUnit]) -> BattleUnit:
	return units.filter(func(u: BattleUnit) -> bool: return u.is_alive()).pick_random()


func _any_alive(units: Array[BattleUnit]) -> bool:
	return units.any(func(u: BattleUnit) -> bool: return u.is_alive())


## Builds battle units. When the same template appears more than once,
## each copy gets a letter: "Test Slime A", "Test Slime B"...
func _make_units(templates: Array[UnitData], on_party: bool) -> Array[BattleUnit]:
	var units: Array[BattleUnit] = []
	var seen: Dictionary[UnitData, int] = {}
	for template: UnitData in templates:
		var suffix: String = ""
		if templates.count(template) > 1:
			suffix = char("A".unicode_at(0) + seen.get(template, 0))
			seen[template] = seen.get(template, 0) + 1
		units.append(BattleUnit.new(template, on_party, suffix))
	return units


func _on_unit_died(unit: BattleUnit) -> void:
	unit_defeated.emit(unit)
