extends CharacterBody2D
class_name MainCharacter

@export var speed: float = 80.0

# Init Blickrichtung von Character
var last_direction: String = "down"

# Blickrichtung merken
func set_last_direction_from_vector(vec: Vector2) -> void:
	if abs(vec.x) > abs(vec.y):
		last_direction = "right" if vec.x > 0.0 else "left"
	elif vec.y != 0.0:
		last_direction = "down" if vec.y > 0.0 else "up"
