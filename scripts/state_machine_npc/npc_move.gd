extends NPCState
class_name NPCMove

@export var progress_epsilon: float = 4.0
@export var speed_multiplier: float = 0.5

var path_follow: PathFollow2D
var path: Path2D
var path_length: float = 0.0
var target_progress: float = 0.0


func Enter(_prev: NPCState) -> void:
	# Im Inspector eingestellte Pathfollow2d referenz
	path_follow = npc.path_follow
	if path_follow:
		path = path_follow.get_parent() as Path2D
		if path and path.curve:
			path_length = path.curve.get_baked_length()
		else:
			path_length = 0.0
	else:
		path = null
		path_length = 0.0

	_pick_new_target()

	if npc.anim:
		npc.anim.play("move")


func Exit() -> void:
	# State wechsel idle
	npc.velocity = Vector2.ZERO
	npc.move_and_slide()


func Update(_delta: float) -> void:
	pass


func PhysicsUpdate(delta: float) -> void:
	if npc.player_inside:
		TransitionTo("idle")
		return

	# Npc nicht bewegen wenn es keinen Path gibt
	if path_follow == null or path_length <= 0.0:
		npc.velocity = Vector2.ZERO
		npc.move_and_slide()
		return

	var current: float = path_follow.progress

	# State wechseln für warten
	if abs(target_progress - current) <= progress_epsilon:
		TransitionTo("idle")
		return

	var diff: float = target_progress - current
	var dir_sign: float = 1.0
	if diff < 0.0:
		dir_sign = -1.0

	var step: float = npc.move_speed * speed_multiplier * delta
	var new_progress: float = current + dir_sign * step


	if (dir_sign > 0.0 and new_progress > target_progress) or (dir_sign < 0.0 and new_progress < target_progress):
		new_progress = target_progress

	# Auf Pfad halten
	new_progress = clamp(new_progress, 0.0, path_length)
	path_follow.progress = new_progress

	# NPC zur PathFollow-Position bewegen
	var target_pos: Vector2 = path_follow.global_position
	var move_vec: Vector2 = target_pos - npc.global_position

	if move_vec.length() > 0.0:
		var dir: Vector2 = move_vec.normalized()
		npc.velocity = dir * npc.move_speed * speed_multiplier
	else:
		npc.velocity = Vector2.ZERO

	# Sprite flippen horizontal
	if abs(npc.velocity.x) > 1.0:
		var flip := npc.velocity.x > 0

		if npc.anim:
			npc.anim.flip_h = flip

		if npc.outline:
			npc.outline.flip_h = flip

	npc.move_and_slide()


func _pick_new_target() -> void:
	if path_length <= 0.0:
		return
	# Zufällige position am path
	target_progress = randf() * path_length
