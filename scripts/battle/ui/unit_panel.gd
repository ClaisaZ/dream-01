class_name UnitPanel
extends Button
## Gray-box stand-in for one unit on the battle screen: name, HP bar, HP numbers,
## and a skill meter bar for units that have one.
## It's a Button so enemies can be clicked as targets.
## Listens to its BattleUnit's signals; never changes the unit itself.

const SIZE := Vector2(220, 90)
const SIZE_WITH_METER := Vector2(220, 130)
const ACTIVE_COLOR := Color(1.0, 0.9, 0.4)
## Placeholder for the "meter full" lightning effect.
const METER_FULL_COLOR := Color(0.4, 0.8, 1.0)

var unit: BattleUnit

var _name_label: Label
var _hp_bar: ProgressBar
var _hp_label: Label
var _meter_bar: ProgressBar
var _meter_label: Label


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


func _on_died(_unit: BattleUnit) -> void:
	disabled = true
	modulate = Color(1, 1, 1, 0.35)
