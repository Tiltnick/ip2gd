extends ZoomStoreItem
class_name Fluxomat

func _ready() -> void:
	save_id = "fluxomat"
	hotbar_id = "fluxomat"

	item_name_de = "Fluxomat"
	item_name_en = "Fluxomat"
	super._ready()

func interact() -> void:
	# In der Welt: direkt einsammeln, kein Zoom
	if not spawned_from_hotbar:
		_store_in_hotbar()
		_on_interacted()
		return

	# Aus der Hotbar: normale Zoom-Logik
	super.interact()

func _on_interacted() -> void:
	DialogManager.start_dialog("res://dialog/outside2/find_fluxomat.json")
