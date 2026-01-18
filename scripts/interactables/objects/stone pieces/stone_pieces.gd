extends ZoomStoreItem
class_name StonePiece

@export var piece_save_id: String = "stone_piece_1"
@export var hotbar_type_id: String = "stonepanel"

func _ready() -> void:
	save_id = piece_save_id
	item_name_de = "Stück Stein"
	item_name_en = "Piece of Stone"
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
	QuestManager.add_quest("quest_3") # stone pieces
