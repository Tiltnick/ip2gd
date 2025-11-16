extends CharacterBody2D
class_name MainCharacter

@export var speed: float = 100.0

# Init Blickrichtung von Character
var last_direction: String = "down"

#var current_interactable: Interactable = null

#func set_current_interactable(obj):
#	current_interactable = obj

#func clear_current_interactable(obj):
#	if current_interactable == obj:
#		current_interactable = null


# Blickrichtung merken
func set_last_direction_from_vector(vec: Vector2) -> void:
	if abs(vec.x) > abs(vec.y):
		last_direction = "right" if vec.x > 0.0 else "left"
	elif vec.y != 0.0:
		last_direction = "down" if vec.y > 0.0 else "up"

#func _unhandled_input(event: InputEvent) -> void:
#	if event.is_action_pressed("interact") and current_interactable:
#		current_interactable.interact()
