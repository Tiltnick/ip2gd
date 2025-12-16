extends Interactable

@export_file("*.tscn") 
var replace_object_scene: String = ""

@export var save_id: String = ""

func _ready():
	super._ready()
	
	if GameState.puzzle_state.get(save_id, false):
		queue_free()


func interact() -> void:
	if is_in_group("stones"):
		if hotbarglobal.inventory_items.has("shovel"):
			GameState.puzzle_state[save_id] = true
		
			remove_stones()
			
			
		else:
			DialogManager.start_dialog("res://dialog/innerMonologue/no_shovel.json")
			
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
