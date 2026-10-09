class_name UnitPanel
extends Button
## Gray-box stand-in for one unit on the battle screen: name, HP bar, HP numbers,
## and a skill meter bar for units that have one.
## It's a Button so enemies can be clicked as targets.
## Listens to its BattleUnit's signals; never changes the unit itself.

const SIZE := Vector2(220, 112)
const SIZE_WITH_METER := Vector2(220, 152)
const ACTIVE_COLOR := Color(1.0, 0.9, 0.4)
## Placeholder for the "meter full" lightning effect.
const METER_FULL_COLOR := Color(0.4, 0.8, 1.0)
## Placeholder icon colors until real status icons exist.
const BUFF_COLOR := Color(0.2, 0.6, 0.3)
const DEBUFF_COLOR := Color(0.7, 0.25, 0.25)
const DAMAGE_OVER_TIME_COLOR := Color(0.5, 0.3, 0.7)
const STUN_COLOR := Color(0.75, 0.6, 0.15)

var unit: BattleUnit

var _name_label: Label
var _hp_bar: ProgressBar
var _hp_label: Label
var _meter_bar: ProgressBar
var _meter_label: Label
var _effect_row: HBoxContainer


func _init(battle_unit: BattleUnit) -> void:
	unit = battle_unit
	custom_minimum_size = SIZE
	focus_mode = Control.FOCUS_NONE
	disabled = true

	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 8)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(box)

	_name_label = Label.new()
	_name_label.text = unit.display_name
	box.add_child(_name_label)

	_hp_bar = ProgressBar.new()
	_hp_bar.max_value = unit.max_hp
	_hp_bar.show_percentage = false
	_hp_bar.custom_minimum_size.y = 16
	box.add_child(_hp_bar)

	_hp_label = Label.new()
	box.add_child(_hp_label)

	if unit.has_meter:
		custom_minimum_size = SIZE_WITH_METER
		_meter_bar = ProgressBar.new()
		_meter_bar.max_value = unit.meter_max
		_meter_bar.show_percentage = false
		_meter_bar.custom_minimum_size.y = 10
		box.add_child(_meter_bar)
		_meter_label = Label.new()
		box.add_child(_meter_label)
		unit.meter_changed.connect(_on_meter_changed)
		_on_meter_changed(unit, unit.meter, unit.meter_max)

	for child: Node in box.get_children():
		(child as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Status effect icons. Hovering one shows its name, description, and rounds left.
	_effect_row = HBoxContainer.new()
	_effect_row.mouse_filter = Control.MOUSE_FILTER_PASS
	box.add_child(_effect_row)
	unit.effects_changed.connect(_on_effects_changed)

	unit.hp_changed.connect(_on_hp_changed)
	unit.died.connect(_on_died)
	unit.defending_changed.connect(_on_defending_changed)
	_on_hp_changed(unit, unit.current_hp, unit.max_hp)


## Yellow tint = this party member is choosing right now.
func set_active(active: bool) -> void:
	modulate = ACTIVE_COLOR if active else Color.WHITE


func _on_hp_changed(_unit: BattleUnit, current_hp: int, max_hp: int) -> void:
	_hp_bar.value = current_hp
	_hp_label.text = "HP %d / %d" % [current_hp, max_hp]


func _on_meter_changed(_unit: BattleUnit, meter: int, meter_max: int) -> void:
	_meter_bar.value = meter
	var full: bool = meter >= meter_max
	_meter_label.text = "METER FULL!" if full else "Meter %d / %d" % [meter, meter_max]
	_meter_bar.modulate = METER_FULL_COLOR if full else Color.WHITE
	_meter_label.modulate = METER_FULL_COLOR if full else Color.WHITE


func _on_defending_changed(_unit: BattleUnit, defending: bool) -> void:
	_name_label.text = unit.display_name + ("  [DEFENDING]" if defending else "")


## Rebuilds the row of effect icons. Uses the effect's icon if it has one,
## otherwise a colored square with its short name.
func _on_effects_changed(_unit: BattleUnit) -> void:
	for child: Node in _effect_row.get_children():
		_effect_row.remove_child(child)
		child.queue_free()
	for effect: StatusEffect in unit.effects:
		var rounds: int = unit.effects[effect]
		var unit_word: String = "turn" if effect.skips_turn else "round"
		if rounds != 1:
			unit_word += "s"
		var tooltip: String = "%s: %s\n%d %s left" % [effect.display_name, effect.description, rounds, unit_word]
		var chip: Control
		if effect.icon != null:
			var icon := TextureRect.new()
			icon.texture = effect.icon
			icon.custom_minimum_size = Vector2(20, 20)
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			chip = icon
		else:
			chip = _placeholder_icon(effect)
		chip.tooltip_text = tooltip
		chip.mouse_filter = Control.MOUSE_FILTER_PASS
		_effect_row.add_child(chip)


func _placeholder_icon(effect: StatusEffect) -> Control:
	var style := StyleBoxFlat.new()
	style.bg_color = _placeholder_color(effect)
	style.set_corner_radius_all(3)
	style.set_content_margin_all(2)
	var chip := PanelContainer.new()
	chip.add_theme_stylebox_override("panel", style)
	var label := Label.new()
	label.text = effect.short_name if effect.short_name != "" else effect.display_name.left(3).to_upper()
	label.add_theme_font_size_override("font_size", 11)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip.add_child(label)
	return chip


func _placeholder_color(effect: StatusEffect) -> Color:
	if effect.skips_turn:
		return STUN_COLOR
	if effect.hp_percent_per_turn < 0:
		return DAMAGE_OVER_TIME_COLOR
	var total: int = effect.atk_percent + effect.def_percent + effect.spd_percent + effect.mag_percent
	return DEBUFF_COLOR if total < 0 else BUFF_COLOR


func _on_died(_unit: BattleUnit) -> void:
	disabled = true
	modulate = Color(1, 1, 1, 0.35)
