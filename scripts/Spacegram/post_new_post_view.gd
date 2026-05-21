extends Control

@onready var preview_image = $MarginContainer/VBoxContainer/TopSection/ProfileImageCenter/ProfileImageWrapper/ProfileImageFrame/ProfileImage
@onready var caption_line_edit = $MarginContainer/VBoxContainer/FormSection/CaptionField/MarginContainer/HBoxContainer/LineEdit
@onready var post_button = $MarginContainer/VBoxContainer/ButtonsRow/ButtonsVBox/PostButton
@onready var cancel_button = $MarginContainer/VBoxContainer/ButtonsRow/ButtonsVBox/CancelButton
@onready var change_picture_button = $MarginContainer/VBoxContainer/TopSection/ProfileImageCenter/ProfileImageWrapper/HBoxContainer/EditIconButton

var selected_image_path: String = ""

signal post_created
signal cancel_requested
signal change_picture_requested

func _ready() -> void:
	visible = false
	
	post_button.pressed.connect(_on_post_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)


func setup(image_path: String) -> void:
	selected_image_path = image_path
	caption_line_edit.text = ""
	preview_image.texture = _load_texture_from_path(image_path)
	visible = true


func _on_post_pressed() -> void:
	var caption: String = caption_line_edit.text.strip_edges()

	if caption.is_empty():
		print("PostNewPostView: Caption fehlt.")
		return

	if selected_image_path.is_empty():
		print("PostNewPostView: Kein Bild gesetzt.")
		return

	post_button.disabled = true

	var result = await SpacegramApi.create_post(caption, selected_image_path)

	if result.success:
		print("Post erstellt.")
		post_created.emit()
	else:
		print("Post konnte nicht erstellt werden: ", result.error)

	post_button.disabled = false


func _on_cancel_pressed() -> void:
	cancel_requested.emit()


func _load_texture_from_path(image_path: String) -> Texture2D:
	if image_path.is_empty():
		return null

	if image_path.begins_with("user://"):
		var image := Image.new()
		var error := image.load(image_path)

		if error != OK:
			print("PostNewPostView: Bild konnte nicht geladen werden: ", image_path)
			return null

		return ImageTexture.create_from_image(image)

	var normalized_path := image_path

	if not normalized_path.begins_with("res://"):
		normalized_path = "res://" + normalized_path

	if not ResourceLoader.exists(normalized_path):
		print("PostNewPostView: Bild nicht gefunden: ", normalized_path)
		return null

	var texture = load(normalized_path)

	if texture is Texture2D:
		return texture

	return null
	
	
func _on_change_picture_pressed() -> void:
	change_picture_requested.emit()
