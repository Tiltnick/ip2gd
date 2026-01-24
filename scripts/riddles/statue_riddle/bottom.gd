extends Node2D

@onready var anim: AnimatedSprite2D = $anim
@onready var area: Area2D = $anim/Area2D

# 0,2,4,6 = Idle/Symbole
# 1,3,5,7 = Turn/Zwischenframes
# WICHTIG: Wenn du nur Frames bis 6 hast, nimm TURN_FRAMES := [1,3,5] und IDLE_FRAMES := [0,2,4,6]
const IDLE_FRAMES := [0, 2, 4, 6]
const TURN_FRAMES := [1, 3, 5, 7]

var state: int = 0
var mouse_over := false
var busy := false
var locked := false

func _ready() -> void:
	# stop zuerst, dann frame setzen
	anim.stop()
	anim.frame = IDLE_FRAMES[state]

	area.mouse_entered.connect(func(): mouse_over = true)
	area.mouse_exited.connect(func(): mouse_over = false)

func _unhandled_input(event: InputEvent) -> void:
	if busy or locked:
		return

	if mouse_over and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		SfxPlayer.stone_grinding()
		rotate_next()

func rotate_next() -> void:
	busy = true

	# Zwischenframe anzeigen (drehen)
	anim.frame = TURN_FRAMES[state]
	await get_tree().create_timer(0.8).timeout

	# nächsten Zustand auswählen
	state = (state + 1) % IDLE_FRAMES.size()

	# Idle-Frame setzen (NICHT stop() danach!)
	anim.frame = IDLE_FRAMES[state]

	busy = false

func lock() -> void:
	locked = true

func get_idle_frame() -> int:
	return IDLE_FRAMES[state]
