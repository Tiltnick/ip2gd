extends State
class_name Run

@export var run_multiplier: float = 1.8
@export var footstep_interval := 0.3
var footstep_timer := 0.0

#const FOOTSTEP_SOUND := preload("res://assets/sound/Free Footsteps Pack/Concrete 2.wav")

func Enter(_prev: State) -> void:
	footstep_timer = 0.0

func PhysicsUpdate(delta: float) -> void:
	var input_vector := Vector2(
		Input.get_axis("moveLeft", "moveRight"),
		Input.get_axis("moveUp", "moveDown")
	)

	if input_vector.length() > 1.0:
		input_vector = input_vector.normalized()

	actor.velocity = input_vector * actor.speed * run_multiplier
	actor.move_and_slide()

	if input_vector != Vector2.ZERO:
		footstep_timer -= delta
		if footstep_timer <= 0.0:
			Footstep.footstep_sound()
			footstep_timer = footstep_interval
	else:
		TransitionTo("idle")
		return

	if not Input.is_action_pressed("run"):
		TransitionTo("move")
		return

	actor.set_last_direction_from_vector(input_vector)
	actor.get_node("anim").play("move_" + actor.last_direction)
