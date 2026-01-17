extends Interactable
class_name Door

@export_file("*.tscn") 
var target_scene_path: String = ""

@export 
var target_spawn_id: String = "start"   # Name des Spawnpoints in der Zielszene

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
	if is_in_group("door_broken"):
		if door_is_open:
			open_door()
			return

		# check if item 
		if hotbarglobal.has_item(required_item_id):
			# Item verbrauchen, damit es aus der Hotbar verschwindet
			hotbarglobal.remove_item(required_item_id)
			
			QuestManager.complete_quest("quest2")

			# Tür optisch öffnen + Zustand merken
			door_open()
			open_door()
			
		else:
			DialogManager.start_dialog("res://dialog/spaceship/door_locked.json")
			await DialogManager.dialog_finished
			QuestManager.add_quest("quest2") # The broken door
			
	elif not is_in_group("door_broken"):
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
