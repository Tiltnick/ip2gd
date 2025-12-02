extends Control

@export var show_key_label := false

var slots: Array = []

func _ready():
	# display ist der contaienr der alle slots enthält
	var display = find_child("Display", true, false)
	if display:
		slots = display.get_children()
	else:
		print("Inventory Display nicht gefunden!")
		return

	# Referenz für Hotbar/Inventory-System
	hotbarglobal.inventory = self

	# Slots initialisieren
	for i in range(slots.size()):
		var slot = slots[i]

		if slot.has_method("set_slot_index"):
			slot.set_slot_index(i)

		# Callback setzen → dieser Slot zeigt Infos an
		if slot.has_method("set_click_callback"):
			slot.set_click_callback(_on_slot_clicked)

	update_slots()


func update_slots():
	for i in range(slots.size()):
		var item_id = hotbarglobal.inventory_items[i]

		if item_id:
			slots[i].set_item_icon(item_id)
		else:
			slots[i].clear_icon()


func _on_slot_clicked(index: int):
	print("Inventory-Slot geklickt:", index)

	var item_id = hotbarglobal.inventory_items[index]
	if not item_id:
		return

	if not ItemDatabase.DATA.has(item_id):
		print("Item nicht in Datenbank:", item_id)
		return

	var data = ItemDatabase.DATA[item_id]

	# beschreibung updaten
	$Description/Title.text = data.get("name", "Unknown")
	$Description/Text.text = data.get("description", "Keine Beschreibung")

	# icon im aktuell ausgewählten slot anzeigen
	if $Description/Slot17.has_method("set_item_icon"):
		$Description/Slot17.set_item_icon(item_id)
