extends Interactable

func _ready():
	super ._ready()
	door_locked()
	
#	if item got gathered: 
	

func interact() -> void:
	#check if item 
	
	
	# else play dialog
	DialogManager.start_dialog("res://dialog/spaceship/door_locked.json")


func door_locked():
	var texture = load('res://assets/sprites/selfmade/spaceship_door_locked.png')
	$Sprite2D.texture = texture

func door_open():
	var texture = load('res://assets/sprites/selfmade/spaceship_door_open.png')
	$Sprite2D.texture = texture
