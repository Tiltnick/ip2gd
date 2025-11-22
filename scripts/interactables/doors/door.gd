extends Interactable
class_name Door

@export_file("*.tscn") 
var target_scene_path: String = ""

@export 
var target_spawn_id: String = "start"   # Name des Spawnpoints in der Zielszene


func interact() -> void:
	open_door()  # Die Tür „öffnet sich“ beim Interagieren


# Diese Methode kann auch von Subklassen wie DoorWithCode aufgerufen werden
func open_door() -> void:
	if target_scene_path == "":
		push_warning("Keine Zielszene gesetzt für: %s" % name)
		return
	
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		push_warning("Kein Spieler gefunden")
		return
	
	# Szenenwechsel über SceneManager
	SceneManager.goto_scene(target_scene_path, target_spawn_id)
