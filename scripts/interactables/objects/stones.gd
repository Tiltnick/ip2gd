extends Interactable

@export var save_id: String = ""
@export var item_path: NodePath

@onready var stone_sprite: Sprite2D = $Sprite2D
@onready var stone_outline: Sprite2D = $Outline
@onready var grave_texture: Texture2D = preload("res://assets/sprites/map/Outside_2/sams_grave.png")

var item: ZoomStoreItem


func _ready():
	super._ready()

	# Optional: falls du bei anderen Stones ein Item referenzierst
	if item_path != NodePath("") and is_in_group("stones"):
		item = get_node(item_path) as ZoomStoreItem

	# Wenn Puzzle schon gelöst:
	# - stone3 bleibt bestehen und bekommt das Grab-Sprite
	# - normale Stones werden entfernt
	if GameState.puzzle_state.get(save_id, false):
		if is_in_group("stone3"):
			change_sprite()
		else:
			queue_free()


func interact() -> void:
	# Priorität: stone3 zuerst behandeln
	if is_in_group("stone3"):
		if not hotbarglobal.inventory_items.has("shovel"):
			DialogManager.start_dialog("res://dialog/innerMonologue/no_shovel.json")
			return

		# Wenn schon einmal ausgegraben -> neuer Dialog
		if GameState.puzzle_state.get(save_id, false):
			DialogManager.start_dialog("res://dialog/innerMonologue/after_grave.json")
			return

		# Erstes Mal (mit Schaufel): State setzen + Cutscene starten
		GameState.puzzle_state[save_id] = true
		GameState.puzzle_state["outside2_second_unlocked"] = true
		GameState.return_scene_path = get_tree().current_scene.scene_file_path

		await transition()
		get_tree().change_scene_to_file("res://scenes/Cutscenes/finding_sam.tscn")
		return

	# Normale Steine
	elif is_in_group("stones"):
		if hotbarglobal.inventory_items.has("shovel"):
			GameState.puzzle_state[save_id] = true
			await remove_stones()
		else:
			DialogManager.start_dialog("res://dialog/innerMonologue/no_shovel.json")
		return

	else:
		print("not in group stones")
		return


func remove_stones():
	await transition()
	queue_free()


func transition():
	TransitionAreaFade.transition()
	await TransitionAreaFade.transition_finished


func change_sprite():
	stone_sprite.texture = grave_texture
	stone_outline.texture = grave_texture
