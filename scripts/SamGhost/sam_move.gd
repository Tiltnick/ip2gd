extends NPCState
class_name SamMove

@export var speed_multiplier: float = 1.0

var path_follow: PathFollow2D
var path_length: float = 0.0

func Enter(_prev: NPCState) -> void:
	path_follow = npc.path_follow
	path_length = 0.0

	if path_follow:
		var path := path_follow.get_parent() as Path2D
		if path and path.curve:
			path_length = path.curve.get_baked_length()

		# Start am Anfang
		path_follow.progress = 0.0
		npc.global_position = path_follow.global_position

	if npc.anim:
		npc.anim.play("move")

func PhysicsUpdate(delta: float) -> void:
	if path_follow == null or path_length <= 0.0:
		TransitionTo("idle")
		return

	path_follow.progress += npc.move_speed * speed_multiplier * delta
	path_follow.progress = clamp(path_follow.progress, 0.0, path_length)

	var target_pos := path_follow.global_position
	var move_vec := target_pos - npc.global_position

	if move_vec.length() > 0.1:
		npc.velocity = move_vec.normalized() * npc.move_speed * speed_multiplier
	else:
		npc.velocity = Vector2.ZERO

	if npc.anim and abs(npc.velocity.x) > 1.0:
		npc.anim.flip_h = npc.velocity.x > 0

	npc.move_and_slide()

	if path_follow.progress >= path_length:
		path_follow.progress = path_length
		npc.velocity = Vector2.ZERO
		npc.move_and_slide()
		TransitionTo("idle")
