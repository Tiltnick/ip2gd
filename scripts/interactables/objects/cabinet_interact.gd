extends Interactable
class_name CabinetGiveTelescope

const SAVE_KEY := "telescope1"
const ITEM_ID  := "telescope"

@export var dialog_path := "res://dialog/innerMonologue/discovering_telescope.json"

@onready var anim: AnimatedSprite2D = $anim

var opened := false


func _ready() -> void:
	super._ready()

	# Lade gespeicherten Zustand
	opened = bool(GameState.puzzle_state.get(SAVE_KEY, false))

	if opened:
		_set_open_visual()


func interact() -> void:
	SfxPlayer.ui_click_sound()

	# schon geöffnet? dann nix mehr tun
	if opened:
		return

	opened = true
	GameState.puzzle_state[SAVE_KEY] = true

	# Visuell öffnen
	_set_open_visual()

	# Item geben
	hotbarglobal.add_item(ITEM_ID)

	# Innerer Monolog
	if dialog_path != "":
		call_deferred("_play_dialog")


func _set_open_visual() -> void:
	if anim.sprite_frames.has_animation("open"):
		anim.play("open")
	else:
		# Fallback: letzter Frame
		anim.frame = anim.sprite_frames.get_frame_count("open") - 1
		anim.stop()


func _play_dialog() -> void:
	DialogManager.start_dialog(dialog_path)
