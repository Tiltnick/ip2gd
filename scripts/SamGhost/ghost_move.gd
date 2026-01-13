extends GhostState
class_name GhostMove

@export var speed_multiplier: float = 1.0

var path_follow: PathFollow2D
var path_length: float = 0.0

func Enter(_prev: GhostState) -> void:
	path_follow = ghost.path_follow
	path_length = 0.0

	if path_follow:
		var path := path_follow.get_parent() as Path2D
		if path and path.curve:
			path_length = path.curve.get_baked_length()

		path_follow.progress = 0.0
		ghost.global_position = path_follow.global_position

	if ghost.anim:
		ghost.anim.play("move")

func PhysicsUpdate(delta: float) -> void:
	if path_follow == null or path_length <= 0.0:
		TransitionTo("idle")
		return

	path_follow.progress += ghost.move_speed * speed_multiplier * delta
	path_follow.progress = clamp(path_follow.progress, 0.0, path_length)

	var target_pos := path_follow.global_position
	var move_vec := target_pos - ghost.global_position

	if move_vec.length() > 0.1:
		ghost.velocity = move_vec.normalized() * ghost.move_speed * speed_multiplier
	else:
		ghost.velocity = Vector2.ZERO

	if ghost.anim and abs(ghost.velocity.x) > 1.0:
		ghost.anim.flip_h = ghost.velocity.x > 0

	ghost.move_and_slide()

	if path_follow.progress >= path_length:
		path_follow.progress = path_length
		ghost.velocity = Vector2.ZERO
		ghost.move_and_slide()
		TransitionTo("idle")
