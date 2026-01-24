extends ZoomStoreItem
class_name Mushroom

@export var piece_save_id: String = ""
@export var hotbar_type_id: String = ""
@export var mush_name_de: String = ""
@export var mush_name_en: String = ""
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	save_id = piece_save_id
	item_name_de = mush_name_de
	item_name_en = mush_name_en

	# hotbar_id hier nicht entscheidend, wir nutzen add_piece()
	hotbar_id = hotbar_type_id

	super._ready()

func _store_in_hotbar():
	if spawned_from_hotbar:
		queue_free()
		return
	mark_collected()
	hotbarglobal.add_piece(save_id, hotbar_type_id)
	queue_free()
