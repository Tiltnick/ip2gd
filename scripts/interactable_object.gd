extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var outline: Sprite2D = $Outline

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# outline is usually not visible
	outline.visible = false

# when body enters area 
func _on_area_2d_body_entered(body: Node2D) -> void:
	# is body that enters the area the player? yes, then outline becomdes visible
	if body.is_in_group("player") or body.name == "Player":
		outline.visible = true

# body leaves area, outline is invisible again
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "Player":
		outline.visible = false
