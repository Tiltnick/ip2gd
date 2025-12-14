extends ZoomStoreItem
class_name ShovelItem

func _ready() -> void:
	save_id = "shovel_1"
	hotbar_id = "shovel"

	item_name_de = "Schaufel"
	item_name_en = "Shovel"

	super._ready()
