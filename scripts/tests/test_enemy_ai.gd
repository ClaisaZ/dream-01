extends Node
## Enemy AI check: how often enemies of different smartness pick each hero.
## Run this scene (F6) and read the Output panel.

const HERO: UnitData = preload("res://data/units/test_hero.tres")
const SLIME: UnitData = preload("res://data/enemies/test_slime.tres")
const SLIMES: EnemyGroup = preload("res://data/enemy_groups/test_slimes.tres")
const PICKS: int = 3000


func _ready() -> void:
	var party_data: Array[UnitData] = [HERO, HERO, HERO]
	var battle := Battle.new(party_data, SLIMES)
	# Hero A at full HP, B at half, C nearly down.
	battle.party[1].take_damage(battle.party[1].max_hp / 2)
	battle.party[2].take_damage(roundi(battle.party[2].max_hp * 0.9))
	for hero: BattleUnit in battle.party:
		print("%s: %d / %d HP" % [hero.display_name, hero.current_hp, hero.max_hp])

	for smartness: float in [0.0, 0.2, 0.5, 1.0]:
		# A test-only copy, so the real slime file is never changed.
		var data := SLIME.duplicate() as UnitData
		data.ai_smartness = smartness
		var chooser := BattleUnit.new(data, false)
		var counts: Dictionary[BattleUnit, int] = {}
		for i: int in PICKS:
			var target: BattleUnit = battle._choose_target(chooser, battle.party)
			counts[target] = counts.get(target, 0) + 1
		var line: String = "Smartness %.1f:" % smartness
		for hero: BattleUnit in battle.party:
			line += "  %s %d%%" % [hero.display_name, roundi(100.0 * counts.get(hero, 0) / PICKS)]
		print(line)

	print("--- Quick or Power? ---")
	var healthy: BattleUnit = battle.party[0]
	var almost_down: BattleUnit = battle.party[2]
	almost_down.take_damage(almost_down.current_hp - 1)
	for smartness: float in [0.0, 0.5, 1.0]:
		var data := SLIME.duplicate() as UnitData
		data.ai_smartness = smartness
		var chooser := BattleUnit.new(data, false)
		print("Smartness %.1f:  vs full HP: Power %d%%   vs 1 HP: Quick %d%%" % [
			smartness, _share_of(battle, chooser, healthy, data.power_attack),
			_share_of(battle, chooser, almost_down, data.quick_attack)])


## How often (in %) the chooser picks this skill against the target.
func _share_of(battle: Battle, chooser: BattleUnit, target: BattleUnit, skill: SkillData) -> int:
	var hits: int = 0
	for i: int in PICKS:
		if battle._choose_attack(chooser, target) == skill:
			hits += 1
	return roundi(100.0 * hits / PICKS)
