extends Interactable


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super ._ready()
	set_texture()



func set_texture():
	var texture = load('res://assets/sprites/selfmade/stone.png')
	$Sprite2D.texture = texture
	
