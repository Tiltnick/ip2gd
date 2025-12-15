extends Interactable

@export_file("*.tscn") 
var replace_object_scene: String = ""


func interact() -> void:
	if is_in_group("stones"):
		if hotbarglobal.inventory_items.has("shovel"):
			remove_stones()
		else:
			DialogManager.start_dialog("res://dialog/outside2/no_shovel.json")
			
	elif not is_in_group("stones"):
		remove_stones()

func remove_stones():
	if replace_object_scene != "":
		var new_scene = load(replace_object_scene).instantiate()
		
		# Position und Parent des aktuellen Objekts übernehmen
		var parent = get_parent()
		new_scene.global_position = global_position
		parent.add_child(new_scene)
		
		# aktuelles Objekt entfernen
		queue_free()
	else:
		print("Keine Ersatzszene angegeben!")
		queue_free()  # Optional: entferne einfach die Steine, wenn keine Szene gesetzt ist
