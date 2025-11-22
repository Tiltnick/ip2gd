extends NPCState
class_name NPCMove

# Erstmal patrol später path
@export var patrol_distance: float = 50.0

# Reihenfolge der Laufrichtung
var directions = [
	Vector2.RIGHT,
	Vector2.DOWN,
	Vector2.LEFT,
	Vector2.UP
]

# Für patrol speichern
var current_dir_index := 0
var segment_start := Vector2.ZERO

# Erstmal nur mit idle weil keine Laufanimation und patrol start
func Enter(_prev: NPCState) -> void:
	if npc.anim:
		npc.anim.play("idle")
	segment_start = npc.global_position

# Idle transition mit Funktion aus npc.gd
func PhysicsUpdate(_delta: float) -> void:
	if npc.player_inside:
		TransitionTo("idle")
		return

	var dir = directions[current_dir_index]
# NPC movement mit array index
	npc.velocity = dir * npc.move_speed
	npc.move_and_slide()

# Strecke seit segment
	var traveled = npc.global_position.distance_to(segment_start)

# Richtungswechsel | Array loop für patrol
	if traveled >= patrol_distance:
		current_dir_index = (current_dir_index + 1) % directions.size()
		segment_start = npc.global_position
