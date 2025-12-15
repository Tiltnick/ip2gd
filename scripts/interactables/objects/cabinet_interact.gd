extends ZoomStoreItem
class_name telescopeItem

#@onready var anim: AnimatedSprite2D = $anim

#var opened := false

func _ready() -> void:
	save_id = "telescope1"
	hotbar_id = "telescope"

	item_name_de = "Teleskop"
	item_name_en = "Telescope"
	super._ready()

	## Falls schon geöffnet gespeichert:
	#if save_id != "" and GameState.puzzle_state.get(save_id, false):
		#opened = true
		#anim.frame = anim.sprite_frames.get_frame_count("open") - 1
		#anim.stop()

#func interact() -> void:
	#if opened:
		#return
#
	#opened = true
	#if save_id != "":
		#GameState.puzzle_state[save_id] = true
#
	#anim.play("open")
	
