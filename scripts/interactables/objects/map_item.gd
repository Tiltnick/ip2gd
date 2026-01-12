extends ZoomStoreItem
class_name MapItem

func _ready() -> void:
	save_id = "minimap_item"
	hotbar_id = "map"
	item_name_de = "Karte"
	item_name_en = "Map"
	
	super._ready()  

func hotbar_activate():
	MiniMap.open()
