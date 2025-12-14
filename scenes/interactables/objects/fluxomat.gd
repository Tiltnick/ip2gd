extends ZoomStoreItem
class_name Fluxomat

func _ready() -> void:
	save_id = "fluxomat"
	hotbar_id = "fluxomat"

	item_name_de = "Fluxomat"
	item_name_en = "Fluxomat"
	super._ready()


func _on_interacted() -> void:
	DialogManager.start_dialog("res://dialog/outside2/find_fluxomat.json")
