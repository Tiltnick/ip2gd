extends CharacterBody2D

const SPEED = 150.0

func _physics_process(delta):
	var input_vector = Vector2(
	Input.get_action_strength("move_left") - Input.get_action_strength("move_right"),
	Input.get_action_strength("move_up") - Input.get_action_strength("move_down") 
)

	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
	
	velocity = input_vector * SPEED
	move_and_slide()
