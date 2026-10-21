class_name Battle
extends RefCounted
## Runs one battle: rounds, turn order, attacks, win or lose.
## Holds no visuals. It reports what happens through signals, and a battle
## screen (or a test scene) listens and shows it.
##
## Party members wait for the player (see party_turn_started / submit_action /
## submit_item), unless auto_party is on. Items come from the party's shared bag.
## Enemies pick a random Quick or Power attack on a random living target.
## Skills can cause status effects (Bleed, Poison, Stun, stat ups/downs).
## Two unlocked partners hitting the same enemy in one round may trigger a
## tag-team attack (at most one per round, never for enemies, fills no meter).

signal round_started(round_number: int)
## A party member needs a choice. Answer with submit_action().
signal party_turn_started(unit: BattleUnit)
signal _action_submitted
signal action_performed(user: BattleUnit, target: BattleUnit, skill: SkillData, damage: int, critical: bool)
signal unit_defeated(unit: BattleUnit)
signal unit_defended(unit: BattleUnit)
## amount = HP restored or meter added, depending on the item.
signal item_used(user: BattleUnit, target: BattleUnit, item: Item, amount: int)
## The item had no valid target left, so it went back in the bag.
signal item_returned(user: BattleUnit, item: Item)
signal effect_applied(unit: BattleUnit, effect: StatusEffect)
## End-of-round HP change from an effect. amount < 0 = damage (bleed, poison), > 0 = healing.
signal effect_hp_changed(unit: BattleUnit, effect: StatusEffect, amount: int)
## The unit is stunned and loses this turn.
signal unit_stunned(unit: BattleUnit)
signal tag_team_performed(first: BattleUnit, second: BattleUnit, target: BattleUnit, tag_team: TagTeamData, damage: int)
signal battle_ended(party_won: bool)

## Safety stop so a bug can never loop forever.
const MAX_ROUNDS: int = 100
const RULES: BattleRules = preload("res://data/battle_rules.tres")
## The Defend action. Its priority and meter gain live in the data file.
const DEFEND: SkillData = preload("res://data/skills/defend.tres")

var party: Array[BattleUnit] = []
var enemies: Array[BattleUnit] = []
var round_number: int = 0
## True = party members also pick randomly (used by the text test).
var auto_party: bool = false
## Seconds to wait after each action so the player can follow along. 0 = instant.
var action_delay: float = 0.0

## This battle's own copy of the bag: Item -> count. The bag file is never changed.
var item_counts: Dictionary[Item, int] = {}
## Tag-teams the party has unlocked (from story progress; a test list for now).
var unlocked_tag_teams: Array[TagTeamData] = []

## This round: enemy -> party members who already hit it with an attack.
var _hits_this_round: Dictionary[BattleUnit, Array] = {}
var _tag_team_used_this_round: bool = false

var _submitted_action: Action


## One unit's choice for the round: a skill, or an item (then skill is null).
class Action:
	var user: BattleUnit
	var skill: SkillData
	var item: Item
	var target: BattleUnit

	func _init(p_user: BattleUnit, p_skill: SkillData, p_target: BattleUnit, p_item: Item = null) -> void:
		user = p_user
		skill = p_skill
		target = p_target
		item = p_item

	func priority() -> int:
		return item.priority if item != null else skill.priority


func _init(party_data: Array[UnitData], enemy_group: EnemyGroup, bag: ItemBag = null) -> void:
	party = _make_units(party_data, true)
	enemies = _make_units(enemy_group.enemies, false)
	if bag != null:
		item_counts = bag.items.duplicate()
	for unit: BattleUnit in party + enemies:
		unit.died.connect(_on_unit_died)


## Plays the whole battle until one side is defeated.
func run() -> void:
	while not is_over() and round_number < MAX_ROUNDS:
		await _run_round()
	battle_ended.emit(is_party_alive())


## The player's choice for the party member named in party_turn_started.
func submit_action(user: BattleUnit, skill: SkillData, target: BattleUnit) -> void:
	_submitted_action = Action.new(user, skill, target)
	_action_submitted.emit()


## The player's item choice. The item is taken from the bag right away, so two
## party members can't both use the last one in the same round.
func submit_item(user: BattleUnit, item: Item, target: BattleUnit) -> void:
	item_counts[item] -= 1
	_submitted_action = Action.new(user, null, target, item)
	_action_submitted.emit()


## Items the party can use in battle right now: at least one left, and at
## least one party member it would work on.
func usable_items() -> Array[Item]:
	var usable: Array[Item] = []
	for item: Item in item_counts:
		if item.usable_in_battle and item_counts[item] > 0 \
				and party.any(func(u: BattleUnit) -> bool: return can_use_item_on(item, u)):
			usable.append(item)
	return usable


## Can this item target this unit? Never a fallen unit; a meter item never
## someone without a meter or with a full one.
func can_use_item_on(item: Item, unit: BattleUnit) -> bool:
	if not unit.is_alive():
		return false
	if item.effect == Item.Effect.FILL_METER:
		return unit.has_meter and not unit.is_meter_full()
	return true


func is_over() -> bool:
	return not is_party_alive() or not _any_alive(enemies)


func is_party_alive() -> bool:
	return _any_alive(party)


func _run_round() -> void:
	round_number += 1
	# Defending lasts for the round it was used in.
	for unit: BattleUnit in party + enemies:
		unit.set_defending(false)
	_hits_this_round.clear()
	_tag_team_used_this_round = false
	round_started.emit(round_number)

	var actions: Array[Action] = []
	for unit: BattleUnit in party:
		if not unit.is_alive():
			continue
		# A stunned party member isn't asked: their turn will be skipped anyway.
		if auto_party or unit.is_stunned():
			actions.append(_choose_action(unit))
		else:
			party_turn_started.emit(unit)
			await _action_submitted
			actions.append(_submitted_action)
	for unit: BattleUnit in enemies:
		if unit.is_alive():
			actions.append(_choose_action(unit))
	actions.sort_custom(_goes_before)

	for action: Action in actions:
		if is_over():
			return
		if not action.user.is_alive() or action.user.is_stunned():
			if action.item != null:
				item_counts[action.item] += 1  # never used, so it goes back in the bag
			if action.user.is_alive():
				action.user.consume_stun()
				unit_stunned.emit(action.user)
				await _pause()
			continue
		if action.item != null:
			_use_item(action)
			await _pause()
			continue
		if action.skill == DEFEND:
			action.user.set_defending(true)
			action.user.add_meter(DEFEND.skill_meter_gain)
			unit_defended.emit(action.user)
			await _pause()
			continue
		# If the chosen target already fell this round, hit someone else on that side.
		if not action.target.is_alive():
			action.target = _random_alive(_opponents_of(action.user))
		var critical: bool = randf() < action.user.crit_chance()
		var multiplier: float = RULES.crit_damage_multiplier if critical else 1.0
		var damage: int = action.user.damage_against(action.target, action.skill, multiplier)
		if action.skill.requires_full_meter:
			action.user.empty_meter()
		action.user.add_meter(action.skill.skill_meter_gain)
		action_performed.emit(action.user, action.target, action.skill, damage, critical)
		action.target.take_damage(damage)
		if action.target.is_alive():
			var hit_gain: float = RULES.meter_gain_when_hit * (RULES.meter_crit_multiplier if critical else 1.0)
			action.target.add_meter(roundi(hit_gain))
		_try_inflict(action)
		await _pause()
		if action.user.is_party:
			await _try_tag_team(action.user, action.target, critical)

	await _end_of_round_effects()


## Called after a party member's attack. If a partner already hit the same enemy
## this round and their tag-team is unlocked, roll the chance and, on success,
## the tag-team fires right away. Both must be standing; at most one per round.
func _try_tag_team(attacker: BattleUnit, target: BattleUnit, critical: bool) -> void:
	var earlier: Array = _hits_this_round.get(target, [])
	_hits_this_round[target] = earlier + [attacker]
	if _tag_team_used_this_round or not target.is_alive() or not attacker.is_alive():
		return
	# One roll per hit, even if several partners already hit this enemy:
	# the first standing partner with an unlocked tag-team is the one who links up.
	for partner: BattleUnit in earlier:
		if partner == attacker or not partner.is_alive():
			continue
		var tag_team: TagTeamData = _find_tag_team(partner, attacker)
		if tag_team == null:
			continue
		if randf() >= _tag_team_chance(attacker, target, critical):
			return
		_tag_team_used_this_round = true
		var damage: int = _tag_team_damage(partner, attacker, target, tag_team.attack)
		tag_team_performed.emit(partner, attacker, target, tag_team, damage)
		target.take_damage(damage)
		_try_inflict(Action.new(attacker, tag_team.attack, target))
		await _pause()
		return


func _find_tag_team(a: BattleUnit, b: BattleUnit) -> TagTeamData:
	for tag_team: TagTeamData in unlocked_tag_teams:
		if tag_team.is_pair(a.data, b.data):
			return tag_team
	return null


func _tag_team_chance(attacker: BattleUnit, target: BattleUnit, critical: bool) -> float:
	var chance: float = RULES.tag_team_base_chance
	if critical:
		chance += RULES.tag_team_crit_bonus
	if float(attacker.current_hp) / attacker.max_hp < RULES.tag_team_low_hp_threshold:
		chance += RULES.tag_team_low_hp_attacker_bonus
	if float(target.current_hp) / target.max_hp < RULES.tag_team_low_hp_threshold:
		chance += RULES.tag_team_low_hp_enemy_bonus
	return chance


## Uses the pair's average attack stat (MAG for magic tag-teams) with the tag-team's power.
func _tag_team_damage(a: BattleUnit, b: BattleUnit, target: BattleUnit, attack: SkillData) -> int:
	var magic: bool = attack.damage_type == SkillData.DamageType.MAGIC
	var stat_a: int = a.current_mag() if magic else a.current_atk()
	var stat_b: int = b.current_mag() if magic else b.current_atk()
	return BattleUnit.calculate_damage(attack.power, roundi((stat_a + stat_b) / 2.0), target.effective_def())


## Rolls the skill's status effect chance and applies it to the target (or the
## user, for self-buffs). Each stun a unit has received lowers its stun chance.
func _try_inflict(action: Action) -> void:
	var effect: StatusEffect = action.skill.inflicts
	if effect == null:
		return
	var recipient: BattleUnit = action.user if action.skill.inflict_on_user else action.target
	if not recipient.is_alive():
		return
	var chance: float = action.skill.inflict_chance
	if effect.skips_turn:
		chance *= pow(RULES.stun_chance_after_stun, recipient.stuns_received)
	if randf() < chance and recipient.apply_effect(effect):
		effect_applied.emit(recipient, effect)


## Bleed, poison, regen... change HP, then every effect counts down one round.
func _end_of_round_effects() -> void:
	for unit: BattleUnit in party + enemies:
		if not unit.is_alive():
			continue
		for effect: StatusEffect in unit.effects.keys():
			if effect.hp_percent_per_turn == 0 or not unit.is_alive():
				continue
			var amount: int = maxi(1, roundi(unit.max_hp * absi(effect.hp_percent_per_turn) / 100.0))
			if effect.hp_percent_per_turn < 0:
				effect_hp_changed.emit(unit, effect, -amount)
				unit.take_damage(amount)
			else:
				effect_hp_changed.emit(unit, effect, unit.heal(amount))
			await _pause()
		unit.tick_effects()


func _use_item(action: Action) -> void:
	# If the target can't take the item anymore (e.g. they fell), pick a new one.
	if not can_use_item_on(action.item, action.target):
		action.target = _fallback_item_target(action.item)
	if action.target == null:
		item_counts[action.item] += 1
		item_returned.emit(action.user, action.item)
		return
	var amount: int = 0
	match action.item.effect:
		Item.Effect.HEAL_HP:
			var heal: int = maxi(1, roundi(action.target.max_hp * action.item.amount / 100.0))
			amount = action.target.heal(heal)
		Item.Effect.FILL_METER:
			var before: int = action.target.meter
			action.target.add_meter(action.item.amount)
			amount = action.target.meter - before
	item_used.emit(action.user, action.target, action.item, amount)


## Prototype choice: the special as soon as the meter is full, otherwise a
## random Quick/Power attack. Always a random living target.
func _choose_action(unit: BattleUnit) -> Action:
	var target: BattleUnit = _random_alive(_opponents_of(unit))
	if unit.can_use(unit.data.special_attack):
		return Action.new(unit, unit.data.special_attack, target)
	var skills: Array[SkillData] = []
	for skill: SkillData in [unit.data.quick_attack, unit.data.power_attack]:
		if skill != null:
			skills.append(skill)
	return Action.new(unit, skills.pick_random(), target)


## Turn order: higher priority first, then higher SPD, then the party wins ties.
func _goes_before(a: Action, b: Action) -> bool:
	if a.priority() != b.priority():
		return a.priority() > b.priority()
	if a.user.current_spd() != b.user.current_spd():
		return a.user.current_spd() > b.user.current_spd()
	return a.user.is_party and not b.user.is_party


## Waits action_delay seconds so the player can follow along (no wait in tests).
func _pause() -> void:
	if action_delay > 0.0:
		await (Engine.get_main_loop() as SceneTree).create_timer(action_delay).timeout


func _opponents_of(unit: BattleUnit) -> Array[BattleUnit]:
	return enemies if unit.is_party else party


func _random_alive(units: Array[BattleUnit]) -> BattleUnit:
	return units.filter(func(u: BattleUnit) -> bool: return u.is_alive()).pick_random()


## Who gets an item whose target can't take it:
## healing goes to the lowest HP ally, a meter item to the meter closest to full.
func _fallback_item_target(item: Item) -> BattleUnit:
	if item.effect == Item.Effect.FILL_METER:
		return _closest_to_full_meter(party, item)
	return _lowest_hp_alive(party)


## The ally with the highest meter that isn't full yet, so the item is most
## likely to unlock their special. Null if nobody can take it.
func _closest_to_full_meter(units: Array[BattleUnit], item: Item) -> BattleUnit:
	var best: BattleUnit = null
	for unit: BattleUnit in units:
		if can_use_item_on(item, unit) and (best == null or unit.meter > best.meter):
			best = unit
	return best


## Lowest HP as a share of max HP, so units with different max HP compare fairly.
## On a tie, the first one in the list wins.
func _lowest_hp_alive(units: Array[BattleUnit]) -> BattleUnit:
	var lowest: BattleUnit = null
	for unit: BattleUnit in units:
		if not unit.is_alive():
			continue
		if lowest == null or float(unit.current_hp) / unit.max_hp < float(lowest.current_hp) / lowest.max_hp:
			lowest = unit
	return lowest


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
		var unit := BattleUnit.new(template, on_party, suffix)
		unit.meter_max = RULES.meter_max
		unit.defend_multiplier = RULES.defend_def_multiplier
		unit.crit_low_hp_bonus = RULES.crit_low_hp_bonus
		units.append(unit)
	return units


func _on_unit_died(unit: BattleUnit) -> void:
	unit_defeated.emit(unit)
