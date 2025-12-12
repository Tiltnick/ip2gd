extends NPC
class_name npc_dialog_process_champignon


const DIALOG_BY_SCENE := {
	"Outside1": "res://dialog/dialogueMrBlob/outside_1.json",
	"Outside2": "res://dialog/dialogueMrBlob/outside_2_part_1.json",
	"Outside3": "",
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	outline.visible = player_inside

	if player_inside:
		outline.frame = anim.frame
		if not dialog_active and Input.is_action_just_pressed("interact"):
			
			# Popup ausblenden
			if e_popup_node:
				e_popup_node.visible = false

			# aktuelle szene rausfinden
			var scene: Node = get_tree().current_scene
			var scene_name: String = scene.name if scene != null else ""

			
			var dialog_path: String = ""

			if scene_name == "Outside2":
				if not GameState.puzzle_state.get("blob_intro_done", false):
					dialog_path = "res://dialog/dialogueMrBlob/outside_2_part_1.json"
				elif not GameState.puzzle_state.get("blob_clue_done", false):
					dialog_path = "res://dialog/cluesMrBlob/clue_stone_pile.json"
				elif not GameState.puzzle_state.get("blob_revelation_done", false):
					dialog_path = "res://dialog/dialogueMrBlob/outside_2_part_2.json"
				
			else:
				if DIALOG_BY_SCENE.has(scene_name):
					dialog_path = DIALOG_BY_SCENE[scene_name]
				else:
					dialog_path = "res://dialog/dialogueMrBlob/outside_1.json"


			if dialog_path != "":
				DialogManager.start_dialog(dialog_path)
				dialog_active = true
