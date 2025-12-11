extends Interactable
class_name Photo
#icon for itemfound popup in inspector
@export var item_icon: Texture2D 
@export var spawned_from_hotbar: bool = false
# Spätere Slots
var meta_slot_index := -1
var hotbar_scale: Vector2 = Vector2(0.5, 0.5)

@onready var front := $Sprite_Front
@onready var back := $Sprite_Back

var is_front := true
var is_zoomed := false
var start_scale: Vector2
var front_start_scale: Vector2
var back_start_scale: Vector2

func _ready():
	front_start_scale = front.scale
	back_start_scale = back.scale
	start_scale = scale
	super._ready()

	# Photo wird que freed wenn es die game state schon hat
	if GameState.picked_items.has("photo_1") and not spawned_from_hotbar:
		queue_free()


func interact():
	WorldAudioManager.play_sfx((load("res://assets/sound/sfx/ButtonClick.wav")))
	if not is_zoomed:
		_zoom_in()
	elif is_front:
		_flip_photo()
	else:
		_store_in_hotbar()



func _store_in_hotbar():
	var lang = TranslationServer.get_locale().substr(0, 2)
	# Photo als aufgehoben markieren
	if not spawned_from_hotbar and not GameState.picked_items.has("photo_1"):
		GameState.picked_items.append("photo_1")
		#Item Found popup
		if lang == "de":
			PopupManager.popup_item_de("Foto",item_icon)
		elif lang == "en":
			PopupManager.popup_item_en("Photo",item_icon)

	# Nicht nochmal in hotbar speichern
	if spawned_from_hotbar:
		queue_free()
		return

	# Phot in Array eintragen dann aus Welt löschen
	hotbarglobal.add_item("photo")
	queue_free()


func _zoom_in():
	is_zoomed = true
	outline.visible = false
	outline_locked = true

	if e_popup_node:
		e_popup_node.visible = false

	var t = create_tween()
	t.tween_property(self, "scale", start_scale * 7, 0.2)


func _flip_photo():
	_disable_outline_full()

	var tween = create_tween()
	tween.tween_property(front, "scale:x", 0, 0.15)
	tween.tween_callback(Callable(self, "_toggle_sides"))
	tween.tween_property(front, "scale:x", front_start_scale.x, 0.15)


func _toggle_sides():
	is_front = !is_front
	front.visible = is_front
	back.visible = !is_front

# Ursprungsskala
func _reset_photo():
	var t = create_tween()
	t.tween_property(self, "scale", start_scale, 0.2)
	t.tween_callback(Callable(self, "_reset_state"))


func _reset_state():
	is_zoomed = false
	is_front = true
	front.visible = true
	back.visible = false
	outline_locked = false
	_try_show_outline()
	if e_popup_node and player_in_area:
		e_popup_node.visible = true


func _disable_outline_full():
	outline.visible = false
	outline_locked = true


func _try_show_outline():
	if outline_locked:
		outline.visible = false
		return
	outline.visible = true


func hotbar_activate():
	spawned_from_hotbar = true

	is_zoomed = false
	is_front = true
	front.visible = true
	back.visible = false
	outline.visible = false
	outline_locked = true

	# Mitte der aktuellen Kamera setzen
	var cam := get_viewport().get_camera_2d()
	if cam:
		global_position = cam.global_position
	else:
		# Falls keine Kamera vorhanden
		global_position = Vector2.ZERO

	scale = hotbar_scale
	start_scale = scale

	z_index = 100

	_zoom_in()
