extends Node
## Piece 2b check: 3 Test Heroes vs Three Slimes, both sides automatic.
## Run this scene (F6) and read the Output panel.

const HERO: UnitData = preload("res://data/units/test_hero.tres")
const SLIMES: EnemyGroup = preload("res://data/enemy_groups/test_slimes.tres")


func _ready() -> void:
	var party_data: Array[UnitData] = [HERO, HERO, HERO]
	var battle := Battle.new(party_data, SLIMES)
	battle.auto_party = true
	battle.round_started.connect(_on_round_started)
	battle.action_performed.connect(_on_action_performed)
	battle.unit_defeated.connect(_on_unit_defeated)
	battle.battle_ended.connect(_on_battle_ended)
	battle.run()


func _on_round_started(round_number: int) -> void:
	print("=== Round %d ===" % round_number)


func _on_action_performed(user: BattleUnit, target: BattleUnit, skill: SkillData, damage: int) -> void:
	print("%s uses %s on %s: %d damage (%d HP left)" % [
		user.display_name, skill.display_name, target.display_name, damage,
		maxi(0, target.current_hp - damage)])


func _on_unit_defeated(unit: BattleUnit) -> void:
	print("  >> %s is defeated!" % unit.display_name)


func _on_battle_ended(party_won: bool) -> void:
	print("=== %s ===" % ("VICTORY" if party_won else "DEFEAT"))
