extends CharacterBody2D
class_name AmbientPathNPC

@export var path_follow: PathFollow2D
@export var speed: float = 60.0 
@export var ping_pong: bool = true

var _dir := 1.0
var _len := 0.0

func _ready() -> void:
	if path_follow:
		var path := path_follow.get_parent() as Path2D
		if path and path.curve:
			_len = path.curve.get_baked_length()

func _physics_process(delta: float) -> void:
	if path_follow == null or _len <= 0.0:
		return

	path_follow.progress += speed * _dir * delta

	if ping_pong:
		if path_follow.progress >= _len:
			path_follow.progress = _len
			_dir = -1.0
		elif path_follow.progress <= 0.0:
			path_follow.progress = 0.0
			_dir = 1.0
	else:
		path_follow.progress = fposmod(path_follow.progress, _len)

	global_position = path_follow.global_position
