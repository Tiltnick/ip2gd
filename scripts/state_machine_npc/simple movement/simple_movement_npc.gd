extends CharacterBody2D
class_name AmbientPathNPC

@export var path_follow: PathFollow2D
@export var speed: float = 60.0
@export var ping_pong: bool = true

@export var sprite_faces_right_by_default: bool = true
@export var dir_deadzone: float = 0.5

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var _dir := 1.0
var _len := 0.0
var _initial_facing_set := false

func _ready() -> void:
	if path_follow:
		var path: Path2D = path_follow.get_parent() as Path2D
		if path and path.curve:
			_len = path.curve.get_baked_length()

func _physics_process(delta: float) -> void:
	if path_follow == null or _len <= 0.0:
		return

	var prev_progress := path_follow.progress

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

	var target_pos: Vector2 = path_follow.global_position
	var move_vec: Vector2 = target_pos - global_position

	if move_vec.length() < dir_deadzone:
		velocity = Vector2.ZERO
		return

	# default sprite zur ersten bewegungsrichtung setzen
	if not _initial_facing_set:
		_update_visual(move_vec)
		_initial_facing_set = true

	# sprite richtung weiter updaten wenn sich bewegungsrichtung ändert
	_update_visual(move_vec)

	velocity = move_vec.normalized() * speed
	move_and_slide()

	if get_slide_collision_count() > 0:
		path_follow.progress = prev_progress
		velocity = Vector2.ZERO


func _update_visual(v: Vector2) -> void:
	var ax: float = absf(v.x)
	var ay: float = absf(v.y)

	if ax >= ay:
		# seitliche bewegung (nur wenn vorhanden)
		_play_if_exists("move_side")

		# flip nur wenn move_side existiert (sonst lassen wir's wie es ist)
		if anim != null and anim.sprite_frames != null and anim.sprite_frames.has_animation("move_side"):
			var moving_right := v.x > 0.0
			if sprite_faces_right_by_default:
				anim.flip_h = not moving_right
			else:
				anim.flip_h = moving_right
	else:
		# hoch / runter (flip aus)
		anim.flip_h = false

		if v.y < 0.0:
			_play_if_exists("move_up")
		else:
			_play_if_exists("move_down")


func _play_if_exists(name: String) -> void:
	if anim == null:
		return
	if anim.sprite_frames == null:
		return
	if not anim.sprite_frames.has_animation(name):
		return
	if anim.animation != name:
		anim.play(name)
