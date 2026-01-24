extends Interactable
class_name Door

@export_file("*.tscn") 
var target_scene_path: String = ""

@export 
var target_spawn_id: String = "start"

@export
var required_item_id: String = "fluxomat"

@export
var opened_state_key: String = "Side_Spaceship_Door_opened"

@onready var door_is_open := false


func _ready():
	super._ready()
	
	if GameState.puzzle_items.has(opened_state_key):
		door_open()
	else:
		door_locked()


func interact() -> void:
	if not is_in_group("door_broken"):
		open_door()
		return

	if hotbarglobal.has_item(required_item_id):
		hotbarglobal.remove_item(required_item_id)
		QuestManager.complete_quest("quest_2")
		door_open()
		open_door()
		return

	var puzzle_done := bool(GameState.puzzle_state.get("spaceship_room_done", false))
	var has_telescope := hotbarglobal.has_item("telescope")

	if puzzle_done and not has_telescope:
		DialogManager.start_dialog(
			"res://dialog/spaceship/door_locked_after_riddle.json"
		)
		return

	if not puzzle_done and not has_telescope:
		DialogManager.start_dialog(
			"res://dialog/spaceship/door_locked.json"
		)
		QuestManager.add_quest("quest_2") # The broken door
		return

	open_door()


func door_locked():
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if not sprite:
		push_warning("Kein Sprite2D gefunden an Tür: %s" % name)
		return

	sprite.visible = true
	var texture = load("res://assets/sprites/selfmade/spaceship_door_destroyed.png")
	sprite.texture = texture

func door_open():
	door_is_open = true
	if not GameState.puzzle_items.has(opened_state_key):
		GameState.puzzle_items.append(opened_state_key)

	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if not sprite:
		push_warning("Kein Sprite2D gefunden an Tür: %s" % name)
		return

	sprite.visible = true
	var texture = load("res://assets/sprites/selfmade/spaceship_door_open.png")
	sprite.texture = texture

func open_door() -> void:
	if target_scene_path == "":
		push_warning("Keine Zielszene gesetzt für: %s" % name)
		return
	
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		push_warning("Kein Spieler gefunden")
		return
	
	SceneManager.goto_scene(target_scene_path, target_spawn_id)
