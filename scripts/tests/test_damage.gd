extends Node
## Piece 2a check: builds battle units from the test data and prints damage numbers.
## Run this scene (F6) and read the Output panel.

const HERO: UnitData = preload("res://data/units/test_hero.tres")
const SLIME: UnitData = preload("res://data/enemies/test_slime.tres")


func _ready() -> void:
	var hero := BattleUnit.new(HERO, true, "A")
	var slime := BattleUnit.new(SLIME, false, "B")
	hero.hp_changed.connect(_on_hp_changed)
	slime.hp_changed.connect(_on_hp_changed)
	slime.died.connect(_on_died)

	print("--- Stats (hero includes starting gear) ---")
	_print_stats(hero)
	_print_stats(slime)

	print("--- Damage ---")
	for skill: SkillData in [HERO.quick_attack, HERO.power_attack, HERO.special_attack]:
		print("%s -> %s with %s: %d" % [hero.display_name, slime.display_name, skill.display_name, hero.damage_against(slime, skill)])
	for skill: SkillData in [SLIME.quick_attack, SLIME.power_attack]:
		print("%s -> %s with %s: %d" % [slime.display_name, hero.display_name, skill.display_name, slime.damage_against(hero, skill)])

	print("--- Hero power-attacks the slime until it drops ---")
	while slime.is_alive():
		slime.take_damage(hero.damage_against(slime, HERO.power_attack))

	print("--- Template untouched? ---")
	print("Slime template max HP is still %d" % SLIME.max_hp)


func _print_stats(unit: BattleUnit) -> void:
	print("%s  HP %d  ATK %d  DEF %d  SPD %d  MAG %d" % [unit.display_name, unit.max_hp, unit.atk, unit.def, unit.spd, unit.mag])


func _on_hp_changed(unit: BattleUnit, current_hp: int, max_hp: int) -> void:
	print("  %s HP: %d / %d" % [unit.display_name, current_hp, max_hp])


func _on_died(unit: BattleUnit) -> void:
	print("  %s is defeated!" % unit.display_name)
