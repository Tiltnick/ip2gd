extends Interactable

@export_file("*.tscn") var target_scene_path: String = ""

func interact() -> void:
	if target_scene_path == "":
		print("Keine Zielszene gesetzt für:", name)
		return
	
	# Spieler finden
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		print("Kein Spieler im Baum gefunden!")
		return
	
	# Szene wechseln – GODOT 4 Version
	get_tree().change_scene_to_file(target_scene_path)
