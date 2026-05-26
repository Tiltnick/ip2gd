extends Control

@export var show_key_label := false

var slots: Array = []
var selected_slot := -1


func _ready():
	var display = find_child("Display", true, false)
	if display:
		slots = display.get_children()
	else:
		print("Inventory Display nicht gefunden!")
		return

	hotbarglobal.inventory = self

	for i in range(slots.size()):
		var slot = slots[i]

		if slot.has_method("set_slot_index"):
			slot.set_slot_index(i)

		if slot.has_method("set_click_callback"):
			slot.set_click_callback(_on_slot_clicked)

	update_slots()

	await get_tree().process_frame





func update_slots():
	for i in range(slots.size()):
		var item_id = hotbarglobal.inventory_items[i]

		if item_id:
			slots[i].set_item_icon(item_id)
		else:
			slots[i].clear_icon()

	_update_selected_visuals()




func _on_slot_clicked(index: int):
	if GameState.should_block_gameplay_input():
		return
	
	selected_slot = index
	_update_selected_visuals()

	var lang = TranslationServer.get_locale().substr(0, 2)
	
	var item_id = hotbarglobal.inventory_items[index]

	# Wwelcher slot wurde geklickt
	var slot_number_for_label = index + 1


	# slot ist leer
	if not item_id:
		if lang == "en":
			$Description/Title.text = "Empty Slot"
			$Description/Text.text = "Oops, this slot has not been filled with anything yet. Nothing to see here, just an empty slot!"
		elif lang == "de":
			$Description/Title.text = "Leerer Slot"
			$Description/Text.text = "Ups, dieser Slot wurde noch mit nichts gefüllt. Hier gibt es nichts zu sehen, nur ein leerer Slot!"
		
		# Icon anzeigen für empty
		
		$Description/Slot17.set_item_icon("empty")

		# Slot number anzeigen
		$Description/Slot17/"Label for Keys".text = str(slot_number_for_label)

		return


	# slot hat item
	if not ItemDatabase.DATA.has(item_id):
		print("Item nicht in Datenbank:", item_id)
		return

	var data = ItemDatabase.DATA[item_id]
	

	# Titel & Beschreibung setzen
	if data:
		if lang == "en":
			$Description/Title.text = data.get("name_en", "Unknown")
			$Description/Text.text = data.get("description_en", "Keine Beschreibung")
		elif lang == "de":
			$Description/Title.text = data.get("name_de", "Unknown")
			$Description/Text.text = data.get("description_de", "Keine Beschreibung")
	# Icon setzen
	$Description/Slot17.set_item_icon(item_id)

	# Hotbarkeys anzeigen
	var hotbar_index: int = hotbarglobal.get_hotbar_index_of_item(item_id)

	if hotbar_index != -1:
		# item liegt in der Hotbar , dann hotbar key anzeigen 1 bis 4
		$Description/Slot17/"Label for Keys".text = str(hotbar_index + 1)
	else:
		# item nicht in der Hotbar dann Inventar-Slotnummer anzeigen 1 bis 16
		$Description/Slot17/"Label for Keys".text = str(slot_number_for_label)






func _update_selected_visuals():
	for i in range(slots.size()):
		var border = slots[i].get_node("Border")
		if border == null:
			continue

		if i == selected_slot:
			border.self_modulate = Color(1, 1, 1, 1)    # aktiv
		else:
			border.self_modulate = Color(0.6, 0.6, 0.6) # inaktiv



func _select_first_item():
	# zeige erstes item im inevtar an 
	for i in range(hotbarglobal.inventory_items.size()):
		if hotbarglobal.inventory_items[i] != null:
			_on_slot_clicked(i)
			return

	# wenn kein item dann slot als emptty
	selected_slot = 0
	_on_slot_clicked(0)
	
	# sobald inventory visible, item in slot nr. 1 zeigen
func _on_visibility_changed():
	if visible:
		_select_first_item()
