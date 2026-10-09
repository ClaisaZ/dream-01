extends Control
## Gray-box battle screen: party on the left, enemies on the right,
## a message line and action buttons at the bottom. Mouse only for now.
##
## Flow for each party member:
## - Quick / Power / Special: click the button, then click an enemy.
## - Defend: click the button (no target).
## - Item: click Item, pick an item from the list, then click a party member.
## Talks to Battle only through its signals, submit_action() and submit_item().

const PARTY: Array[UnitData] = [
	preload("res://data/units/test_hero.tres"),
	preload("res://data/units/test_hero.tres"),
	preload("res://data/units/test_hero.tres"),
]
const ENEMY_GROUP: EnemyGroup = preload("res://data/enemy_groups/test_golem_and_slimes.tres")
const TEST_BAG: ItemBag = preload("res://data/items/test_bag.tres")
## Treated as unlocked until story progress exists.
const TEST_TAG_TEAMS: Array[TagTeamData] = [preload("res://data/tag_teams/test_twin_strike.tres")]
const TITLE_SCENE: String = "res://scenes/menus/title_screen.tscn"
## Retune once attack animations exist; they'll add their own time.
const ACTION_DELAY: float = 0.8

var _battle: Battle
var _panels: Dictionary[BattleUnit, UnitPanel] = {}
var _active_unit: BattleUnit
var _chosen_skill: SkillData
var _chosen_item: Item

var _message: Label
var _item_menu: HBoxContainer
var _quick_button: Button
var _power_button: Button
var _special_button: Button
var _defend_button: Button
var _item_button: Button
var _restart_button: Button
var _title_button: Button


func _ready() -> void:
	_battle = Battle.new(PARTY, ENEMY_GROUP, TEST_BAG)
	_battle.action_delay = ACTION_DELAY
	_battle.unlocked_tag_teams = TEST_TAG_TEAMS
	_build_layout()

	_battle.round_started.connect(_on_round_started)
	_battle.party_turn_started.connect(_on_party_turn_started)
	_battle.action_performed.connect(_on_action_performed)
	_battle.unit_defeated.connect(_on_unit_defeated)
	_battle.unit_defended.connect(_on_unit_defended)
	_battle.item_used.connect(_on_item_used)
	_battle.item_returned.connect(_on_item_returned)
	_battle.effect_applied.connect(_on_effect_applied)
	_battle.effect_hp_changed.connect(_on_effect_hp_changed)
	_battle.unit_stunned.connect(_on_unit_stunned)
	_battle.tag_team_performed.connect(_on_tag_team_performed)
	_battle.battle_ended.connect(_on_battle_ended)
	_battle.run()


func _build_layout() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	var background := ColorRect.new()
	background.color = Color(0.18, 0.18, 0.2)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	for side: String in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 24)
	add_child(margin)

	var rows := VBoxContainer.new()
	margin.add_child(rows)

	# Field: party column, empty middle, enemy column.
	var field := HBoxContainer.new()
	field.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rows.add_child(field)
	field.add_child(_make_side(_battle.party))
	var middle := Control.new()
	middle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	field.add_child(middle)
	field.add_child(_make_side(_battle.enemies))

	# Bottom bar: message line, item list (hidden until Item is clicked), buttons.
	_message = Label.new()
	_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message.add_theme_font_size_override("font_size", 22)
	rows.add_child(_message)

	_item_menu = HBoxContainer.new()
	_item_menu.alignment = BoxContainer.ALIGNMENT_CENTER
	_item_menu.hide()
	rows.add_child(_item_menu)

	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.custom_minimum_size.y = 56
	rows.add_child(buttons)
	_quick_button = _make_button("Quick Attack", buttons, _on_skill_pressed.bind(&"quick_attack"))
	_power_button = _make_button("Power Attack", buttons, _on_skill_pressed.bind(&"power_attack"))
	_special_button = _make_button("Special Attack", buttons, _on_skill_pressed.bind(&"special_attack"))
	_defend_button = _make_button("Defend", buttons, _on_defend_pressed)
	_item_button = _make_button("Item", buttons, _on_item_button_pressed)
	_restart_button = _make_button("Play Again", buttons, get_tree().reload_current_scene)
	_title_button = _make_button("Title Screen", buttons, get_tree().change_scene_to_file.bind(TITLE_SCENE))
	_restart_button.hide()
	_title_button.hide()
	_set_action_buttons_enabled(false)

	# Testing shortcut: leave the battle at any time. Top-right corner.
	var back_button := Button.new()
	back_button.text = "Back to Title"
	back_button.focus_mode = Control.FOCUS_NONE
	back_button.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, 8)
	back_button.pressed.connect(get_tree().change_scene_to_file.bind(TITLE_SCENE))
	add_child(back_button)


func _make_side(units: Array[BattleUnit]) -> VBoxContainer:
	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 16)
	for unit: BattleUnit in units:
		var panel := UnitPanel.new(unit)
		if unit.is_party:
			panel.pressed.connect(_on_ally_pressed.bind(unit))
		else:
			panel.pressed.connect(_on_enemy_pressed.bind(unit))
		column.add_child(panel)
		_panels[unit] = panel
	return column


func _make_button(text: String, parent: Container, on_pressed: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(180, 48)
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(on_pressed)
	parent.add_child(button)
	return button


# --- Player input ---

func _on_party_turn_started(unit: BattleUnit) -> void:
	_active_unit = unit
	_clear_choice()
	_panels[unit].set_active(true)
	_message.text = "%s: choose an action" % unit.display_name
	_set_action_buttons_enabled(true)


## slot is the UnitData property holding the skill: quick_attack, power_attack, or special_attack.
func _on_skill_pressed(slot: StringName) -> void:
	_clear_choice()
	_chosen_skill = _active_unit.data.get(slot)
	_message.text = "%s: %s. Click an enemy" % [_active_unit.display_name, _chosen_skill.display_name]
	_set_enemy_targets_enabled(true)


## Defend needs no target: it's submitted right away.
func _on_defend_pressed() -> void:
	_clear_choice()
	_chosen_skill = Battle.DEFEND
	_submit(_active_unit)


## Shows one button per usable item, with how many are left.
func _on_item_button_pressed() -> void:
	_clear_choice()
	for item: Item in _battle.usable_items():
		var label: String = "%s x%d" % [item.display_name, _battle.item_counts[item]]
		_make_button(label, _item_menu, _on_item_chosen.bind(item))
	_item_menu.show()
	_message.text = "%s: choose an item" % _active_unit.display_name


func _on_item_chosen(item: Item) -> void:
	_chosen_item = item
	_message.text = "%s: %s. Click a party member" % [_active_unit.display_name, item.display_name]
	_set_ally_targets_enabled(item)


func _on_enemy_pressed(target: BattleUnit) -> void:
	if _active_unit != null and _chosen_skill != null:
		_submit(target)


func _on_ally_pressed(target: BattleUnit) -> void:
	if _active_unit != null and _chosen_item != null:
		_submit(target)


func _submit(target: BattleUnit) -> void:
	var user: BattleUnit = _active_unit
	var skill: SkillData = _chosen_skill
	var item: Item = _chosen_item
	_panels[user].set_active(false)
	_active_unit = null
	_clear_choice()
	_set_action_buttons_enabled(false)
	if item != null:
		_battle.submit_item(user, item, target)
	else:
		_battle.submit_action(user, skill, target)


## Forgets a half-made choice (e.g. switching from Power to Item) and resets targets.
func _clear_choice() -> void:
	_chosen_skill = null
	_chosen_item = null
	for child: Node in _item_menu.get_children():
		_item_menu.remove_child(child)
		child.queue_free()
	_item_menu.hide()
	_set_enemy_targets_enabled(false)
	_set_ally_targets_enabled(null)


## Special stays grayed out until the meter is full; Item until something usable is left.
func _set_action_buttons_enabled(enabled: bool) -> void:
	_quick_button.disabled = not enabled
	_power_button.disabled = not enabled
	_defend_button.disabled = not enabled
	_special_button.disabled = not (enabled and _active_unit != null
			and _active_unit.can_use(_active_unit.data.special_attack))
	_item_button.disabled = not (enabled and not _battle.usable_items().is_empty())


func _set_enemy_targets_enabled(enabled: bool) -> void:
	for unit: BattleUnit in _battle.enemies:
		_panels[unit].disabled = not (enabled and unit.is_alive())


## Party members the item would work on become clickable. null = none.
func _set_ally_targets_enabled(item: Item) -> void:
	for unit: BattleUnit in _battle.party:
		_panels[unit].disabled = item == null or not _battle.can_use_item_on(item, unit)


# --- Battle events ---

func _on_round_started(round_number: int) -> void:
	_message.text = "Round %d" % round_number


func _on_action_performed(user: BattleUnit, target: BattleUnit, skill: SkillData, damage: int, critical: bool) -> void:
	_message.text = "%s uses %s on %s: %d damage!" % [user.display_name, skill.display_name, target.display_name, damage]
	if critical:
		_message.text = "CRITICAL HIT! " + _message.text


func _on_unit_defended(unit: BattleUnit) -> void:
	_message.text = "%s defends!" % unit.display_name


func _on_item_used(user: BattleUnit, target: BattleUnit, item: Item, amount: int) -> void:
	var what: String = "HP" if item.effect == Item.Effect.HEAL_HP else "meter"
	_message.text = "%s uses %s on %s: +%d %s" % [user.display_name, item.display_name, target.display_name, amount, what]


func _on_item_returned(user: BattleUnit, item: Item) -> void:
	_message.text = "%s's %s had no one to use it on and went back in the bag" % [user.display_name, item.display_name]


func _on_effect_applied(unit: BattleUnit, effect: StatusEffect) -> void:
	_message.text += "  %s gets %s!" % [unit.display_name, effect.display_name]


func _on_effect_hp_changed(unit: BattleUnit, effect: StatusEffect, amount: int) -> void:
	if amount < 0:
		_message.text = "%s takes %d damage from %s" % [unit.display_name, -amount, effect.display_name]
	else:
		_message.text = "%s recovers %d HP from %s" % [unit.display_name, amount, effect.display_name]


func _on_tag_team_performed(first: BattleUnit, second: BattleUnit, target: BattleUnit, tag_team: TagTeamData, damage: int) -> void:
	_message.text = "TAG-TEAM! %s + %s: %s on %s for %d damage!" % [
		first.display_name, second.display_name, tag_team.display_name, target.display_name, damage]


func _on_unit_stunned(unit: BattleUnit) -> void:
	_message.text = "%s is stunned and can't move!" % unit.display_name


func _on_unit_defeated(unit: BattleUnit) -> void:
	_message.text += "  %s is defeated!" % unit.display_name


func _on_battle_ended(party_won: bool) -> void:
	_message.text = "VICTORY!" if party_won else "DEFEAT..."
	_clear_choice()
	_set_action_buttons_enabled(false)
	for button: Button in [_quick_button, _power_button, _special_button, _defend_button, _item_button]:
		button.hide()
	_restart_button.show()
	_title_button.show()
