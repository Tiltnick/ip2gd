extends Interactable


func _ready():
	super ._ready()
	set_texture()
	

func set_texture():
	var texture = load('res://assets/sprites/map/Outside_2/Treasure.png')
	$Sprite2D.texture = texture
	
func change_sprite():
	var texture = load('res://assets/sprites/map/Outside_2/Treasure.png')
	$Sprite2D.texture = texture
