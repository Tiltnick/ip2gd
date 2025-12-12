extends Control

@onready var slots := $Background/HBoxContainer.get_children()
var selected_slot := 0

# Aktuelles aktives Item
var active_item: Node = null


func _ready():
	hotbarglobal.hotbar = self

	# Slots initialisieren
	for i in range(slots.size()):
		var slot = slots[i]

		# Slot Index setzen für die keylabels
		if slot.has_method("set_slot_index"):
			slot.set_slot_index(i)

		# Klickfunktion macht genau dasselbe wie Tastendruck
		if slot.has_method("set_click_callback"):
			slot.set_click_callback(_on_slot_clicked)

	update_slots()


func _unhandled_input(event):
	for i in range(slots.size()):
		if event.is_action_pressed("hotbar_%d" % (i + 1)):
			_on_slot_triggered(i)   # gleiche fnkt wie klick


func update_slots():
	for i in range(slots.size()):
		var item_id = hotbarglobal.hotbar_items[i]

		if item_id:
			slots[i].set_item_icon(item_id)
		else:
			slots[i].clear_icon()

		# Border färben
		var border := slots[i].get_node("Border")
		if border:
			if item_id:
				border.modulate = Color(0.851, 0.816, 0.655, 1.0)  # belegt: gelb
			else:
				border.modulate = Color(0.357, 0.83, 0.783, 1.0)   # leer: türkis

	_update_selected_visuals()


func _on_slot_clicked(index: int):
	_on_slot_triggered(index)


func _on_slot_triggered(index: int):
	selected_slot = index
	_update_selected_visuals()
	use_slot(index)


func _update_selected_visuals():
	for i in range(slots.size()):
		var border := slots[i].get_node("Border")
		if border == null:
			continue

		if i == selected_slot:
			border.self_modulate = Color(1, 1, 1, 1)        # aktiv
		else:
			border.self_modulate = Color(0.7, 0.7, 0.7, 1)  # inaktiv


func use_slot(slot_index: int):
	var item_id = hotbarglobal.hotbar_items[slot_index]
	if not item_id:
		return

	# Wenn bereits ein aktives Item existiert danninteragieren
	if active_item and is_instance_valid(active_item):
		if active_item.has_method("interact"):
			active_item.interact()
		return

	# Item muss in der Datenbank existieren
	if not ItemDatabase.DATA.has(item_id):
		print("Hotbar: Item nicht in Datenbank:", item_id)
		return

	var data = ItemDatabase.DATA[item_id]
	var scene_path: String = data.get("world_scene", "")

	if scene_path == "" or not ResourceLoader.exists(scene_path):
		print("Hotbar: Kein gültiges world_scene für:", item_id, " path:", scene_path)
		return

	# Instanzieren 
	var scene: PackedScene = load(scene_path)
	var inst: Node = scene.instantiate()

	# Als Hotbar-Spawn markieren
	var has_spawned := false
	for p in inst.get_property_list():
		if p.name == "spawned_from_hotbar":
			has_spawned = true
			break

	if has_spawned:
		inst.set("spawned_from_hotbar", true)

	# Jetzt  in den SceneTree hängen (triggert _ready)
	get_tree().current_scene.add_child(inst)

	active_item = inst

	#active_item zurücksetzen wenn es sich selber schließt (queue_free)
	inst.tree_exited.connect(func():
		if active_item == inst:
			active_item = null
	)

	# Hotbar Activation (zoom etc.)
	if inst.has_method("hotbar_activate"):
		inst.hotbar_activate()
	elif inst.has_method("interact"):
		# fallback: direkt interact
		inst.interact()
