extends ZoomStoreItem
class_name FlashlightItem

func _ready() -> void:
	save_id = "flashlight_1"
	hotbar_id = "flashlight"

	item_name_de = "Taschenlampe"
	item_name_en = "Flashlight"

	super._ready()
