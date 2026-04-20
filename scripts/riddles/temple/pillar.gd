extends Area2D
class_name Pillar

signal pressed(pillar: Pillar)

@export var pillar_id: String = ""
@export var interact_action: StringName = &"interact"

@export var sprite_off: Texture2D
@export var sprite_on: Texture2D

@onready var sprite: Sprite2D = $Sprite2D

var _player_inside: bool = false
var _is_on: bool = false
var _locked: bool = false

var _flash_token: int = 0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_update_visual()


func set_locked(v: bool) -> void:
	_locked = v


func set_on(v: bool) -> void:
	_is_on = v
	_update_visual()


func toggle() -> void:
	_is_on = not _is_on
	_update_visual()


func is_on() -> bool:
	return _is_on


func _process(_delta: float) -> void:
	var auth = get_tree().get_first_node_in_group("auth_screen")
	if auth and auth.visible:
		return
	
	if _locked:
		return
	if not _player_inside:
		return

	if Input.is_action_just_pressed(interact_action):
		pressed.emit(self)


func flash_hint(duration: float = 0.25) -> void:
	if sprite == null:
		return
	if sprite_on == null:
		return

	_flash_token += 1
	var token := _flash_token

	sprite.texture = sprite_on

	if duration <= 0.0:
		return

	await get_tree().create_timer(duration).timeout

	if token != _flash_token:
		return

	_update_visual()


func _update_visual() -> void:
	if sprite == null:
		return

	if _is_on and sprite_on:
		sprite.texture = sprite_on
	elif (not _is_on) and sprite_off:
		sprite.texture = sprite_off


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player_inside = true


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_player_inside = false
