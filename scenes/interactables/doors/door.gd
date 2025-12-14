extends Interactable

@onready var door_is_open := false

func _ready():
	super ._ready()
	
	if GameState.puzzle_items.has("Side_Spaceship_Door_opened"):
		door_open()
	else:
		door_locked()
	
	

func interact() -> void:
	#check if item 
	if hotbarglobal.inventory_items.has("fluxomat"):
		door_open()
		DialogManager.start_dialog("res://dialog/spaceship/door_opened.json")
	else:
		DialogManager.start_dialog("res://dialog/spaceship/door_locked.json")

func door_locked():
	var texture = load('res://assets/sprites/selfmade/spaceship_door_locked.png')
	$Sprite2D.texture = texture

func door_open():
	door_is_open = true
	GameState.puzzle_items.append("Side_Spaceship_Door_opened")
	var texture = load('res://assets/sprites/selfmade/spaceship_door_open.png')
	$Sprite2D.texture = texture
