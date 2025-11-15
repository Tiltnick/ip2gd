extends State
class_name Run

@export var run_multiplier: float = 1.5

func Enter(_prev: State) -> void:
	pass

func PhysicsUpdate(_delta: float) -> void:
	var input_vector := Vector2(
		Input.get_axis("moveLeft", "moveRight"),
		Input.get_axis("moveUp", "moveDown")
	)

	# Vermeiden von Diagonalem schneller laufen
	if input_vector.length() > 1.0:
		input_vector = input_vector.normalized()

	actor.velocity = input_vector * actor.speed * run_multiplier
	actor.move_and_slide()

	# Vector 0 = idle state
	if input_vector == Vector2.ZERO:
		TransitionTo("idle")
		return

	# Shift loslassen = move state
	if not Input.is_action_pressed("run"):
		TransitionTo("move")
		return

	actor.set_last_direction_from_vector(input_vector)
	actor.get_node("anim").play("move_" + actor.last_direction)
