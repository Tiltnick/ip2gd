extends ZoomStoreItem
class_name FireMushroom


@export var hotbar_type_id: String = ""
@export var mush_name_de: String = ""
@export var mush_name_en: String = ""
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	
	item_name_de = mush_name_de
	item_name_en = mush_name_en
	hotbar_id = hotbar_type_id

func get_mush():
	_store_in_hotbar()
