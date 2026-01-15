extends SamState
class_name SamMove

@export var speed_multiplier: float = 1.0

var _follow: PathFollow2D
var _path: Path2D
var _finished := false


func Enter(_prev) -> void:
	_finished = false

	_follow = npc.path_follow
	_path = null

	if _follow == null:
		TransitionTo("idle")
		return

	_path = _follow.get_parent() as Path2D
	if _path == null or _path.curve == null or _path.curve.get_baked_length() <= 0.0:
		TransitionTo("idle")
		return

	_follow.progress = 0.0
	npc.global_position = _follow.global_position

	if npc.anim:
		npc.anim.play("move")


func PhysicsUpdate(delta: float) -> void:
	if _finished:
		return

	if _follow == null:
		TransitionTo("idle")
		return

	_follow.progress += npc.move_speed * speed_multiplier * delta
	npc.global_position = _follow.global_position

	if _follow.progress_ratio >= 1.0:
		_finished = true
		if machine:
			machine.notify_move_finished()
		TransitionTo("idle")
