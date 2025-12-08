extends NPCState
class_name NPCIdle

# Wartezeiten für NPC während des laufens
@export var min_wait_time: float = 0.5
@export var max_wait_time: float = 2.0

var wait_time_left: float = 0.0
var waiting_for_patrol: bool = false

func Enter(_prev: NPCState) -> void:
	if npc.anim:
		npc.anim.play("idle")

	# Wenn Spieler in der Nähe stop
	if npc.player_inside:
		waiting_for_patrol = false
		wait_time_left = 0.0
	else:
		# Vom move state aus stop
		waiting_for_patrol = true
		if max_wait_time > 0.0:
			wait_time_left = randf_range(min_wait_time, max_wait_time)
		else:
			wait_time_left = 0.0


func PhysicsUpdate(delta: float) -> void:
	npc.velocity = Vector2.ZERO
	npc.move_and_slide()
	if npc.player_inside:
		return

	if not waiting_for_patrol:
		TransitionTo("move")
		return

	if wait_time_left > 0.0:
		wait_time_left -= delta
		if wait_time_left <= 0.0:
			TransitionTo("move")
	else:
		TransitionTo("move")
