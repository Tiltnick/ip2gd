extends CharacterBody2D
class_name AmbientPathNPC

@export var path_follow: PathFollow2D
@export var speed: float = 1.0
@export var loop: bool = true

func _physics_process(delta: float) -> void:
	if path_follow == null:
		return

	path_follow.progress += speed * delta

	if loop:
		var path := path_follow.get_parent() as Path2D
		if path and path.curve:
			var len := path.curve.get_baked_length()
			if len > 0.0:
				path_follow.progress = fposmod(path_follow.progress, len)

	global_position = path_follow.global_position
