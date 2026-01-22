extends NPCState
class_name NPCIdle

@export var min_wait_time: float = 0.5
@export var max_wait_time: float = 2.0

var wait_time_left: float = 0.0
var was_player_inside: bool = false

func Enter(_prev: NPCState) -> void:
	if npc.anim:
		npc.anim.play("idle")

	npc.velocity = Vector2.ZERO
	was_player_inside = npc.player_inside

	# Wenn Spieler drin: stehen bleiben bis er raus ist
	if npc.player_inside:
		wait_time_left = -1.0
		return

	_start_patrol_wait()

func PhysicsUpdate(delta: float) -> void:
	npc.velocity = Vector2.ZERO

	# Spieler blockiert => stehen
	if npc.player_inside:
		was_player_inside = true
		return

	# Wenn Player gerade raus ist, neu warten
	if was_player_inside and not npc.player_inside:
		was_player_inside = false
		_start_patrol_wait()

	# Steh-NPC: bleibt immer idle
	if npc.behavior == NPC.Behavior.STAND_ONLY:
		return

	#Patrouille nur wenn Path existiert
	if not npc.has_valid_path():
		return
	
	# Timer runterzählen -> Move
	if wait_time_left < 0.0:
		return

	wait_time_left -= delta
	if wait_time_left <= 0.0:
		TransitionTo("move")

func _start_patrol_wait() -> void:
	if max_wait_time > 0.0:
		wait_time_left = randf_range(min_wait_time, max_wait_time)
	else:
		wait_time_left = 0.0
