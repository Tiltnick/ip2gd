extends ZoomFlipStoreItem
class_name Photo

@onready var front := $Sprite_Front
@onready var back := $Sprite_Back

var front_start_scale: Vector2

func _ready() -> void:
	# Save + Hotbar + Popup
	save_id = "photo_1"
	hotbar_id = "photo"
	item_name_de = "Foto"
	item_name_en = "Photo"

	# Startzustände
	is_front = true
	front.visible = true
	back.visible = false

	# Skalen merken 
	front_start_scale = front.scale

	super._ready()

func _flip() -> void:
	
	outline.visible = false
	outline_locked = true

	var tween := create_tween()
	tween.tween_property(front, "scale:x", 0, 0.15)
	tween.tween_callback(Callable(self, "_toggle_sides"))
	tween.tween_property(front, "scale:x", front_start_scale.x, 0.15)

func _toggle_sides() -> void:
	is_front = !is_front
	front.visible = is_front
	back.visible = !is_front

func hotbar_activate():
	super.hotbar_activate()

	# beim Spawn aus Hotbar immer front
	is_front = true
	front.visible = true
	back.visible = false
