extends Interactable
class_name ColorLamp

signal lamp_changed(index: int, value: int)

@export var puzzle_id: String = "color_code_2151"
@export var lamp_index: int = 0      
@export var start_value: int = 0     
@export var max_value: int = 5       
@onready var anim: AnimatedSprite2D = $anim

var value: int = 0        

func _ready() -> void:
	super._ready()

	var key := "%s_lamp_%d" % [puzzle_id, lamp_index]
	value = int(GameState.puzzle_state.get(key, start_value))
	value = clamp(value, 0, max_value)

	_update_visual()

func interact() -> void:
	if GameState.puzzle_state.get(puzzle_id, false):
		return

	value += 1
	if value > max_value:
		value = 0

	var key := "%s_lamp_%d" % [puzzle_id, lamp_index]
	GameState.puzzle_state[key] = value

	_update_visual()
	emit_signal("lamp_changed", lamp_index, value)

func _update_visual() -> void:
	anim.stop()
	anim.frame = value
