extends State
class_name DialogState

func Enter(_prev: State) -> void:

	# Bewegung stoppen
	if actor:
		actor.velocity = Vector2.ZERO
		# Idle-Animation beibehalten
		actor.get_node("anim").play("idle_" + actor.last_direction)


func Exit() -> void:

	pass

func HandleInput(_event: InputEvent) -> void:
	# Gibt kein input
	pass

func PhysicsUpdate(_delta: float) -> void:
	# Keine Bewegung
	if actor:
		actor.velocity = Vector2.ZERO
		actor.move_and_slide()
