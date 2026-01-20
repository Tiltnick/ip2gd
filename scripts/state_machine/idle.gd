extends State
class_name Idle

# Passende Idle animation
func Enter(_prev: State) -> void:
	actor.get_node("anim").play("idle_" + actor.last_direction)

# Vector != 0 -> transition move state
func PhysicsUpdate(_delta: float) -> void:
	actor.velocity = Vector2.ZERO
	actor.move_and_slide()  # damit er mit den simple npcs collided
	
	var input_vector := Vector2(
		Input.get_axis("moveLeft", "moveRight"),
		Input.get_axis("moveUp", "moveDown")
	)
	if input_vector != Vector2.ZERO:
		TransitionTo("move")
