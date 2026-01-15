extends TextureRect

@export var label_text: String = "Building"
@export var hover_scale := 1.15
@export var tween_time := 0.12



var base_scale := Vector2.ONE
var tween: Tween

func _ready() -> void:
	base_scale = scale
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	_scale_to(base_scale * hover_scale)
	MiniMap.show_tooltip(label_text, global_position)

func _on_mouse_exited():
	_scale_to(base_scale)
	MiniMap.hide_tooltip()

func _scale_to(s: Vector2):
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "scale", s, tween_time)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
