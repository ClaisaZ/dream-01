extends Control
## Bare title screen: the game's name and a Start button that opens the test battle.
## The title text is a placeholder until the team picks a working title.

const BATTLE_SCENE: String = "res://scenes/battle/battle_screen.tscn"

@onready var _start_button: Button = %StartButton


func _ready() -> void:
	_start_button.pressed.connect(_on_start_pressed)


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(BATTLE_SCENE)
