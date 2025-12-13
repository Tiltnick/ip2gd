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

	# Photo wird que freed wenn es die game state schon hat
	if GameState.picked_items.has("photo_1") and not spawned_from_hotbar:
		queue_free()


func interact():
	SfxPlayer.ui_click_sound()
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
