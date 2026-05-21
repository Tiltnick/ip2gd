extends Control

signal avatar_selected(image_path: String, option_node: Control)

@onready var profile_image_frame: PanelContainer = $ProfileImageFrame
@onready var profile_image: TextureRect = $ProfileImageFrame/ProfileImage
@onready var selected_icon_button = $SelectedIconButton

var image_path: String = ""

const DEFAULT_BORDER_COLOR := Color("#3d8a7f")
const SELECTED_BORDER_COLOR := Color("#d9d0a7")


func _ready() -> void:
	gui_input.connect(_on_gui_input)

	var stylebox := profile_image_frame.get_theme_stylebox("panel")

	if stylebox is StyleBoxFlat:
		var duplicated_stylebox := stylebox.duplicate() as StyleBoxFlat
		profile_image_frame.add_theme_stylebox_override("panel", duplicated_stylebox)

	set_selected(false)


func setup(new_image_path: String, texture: Texture2D) -> void:
	image_path = new_image_path
	profile_image.texture = texture
	set_selected(false)


func set_selected(is_selected: bool) -> void:
	selected_icon_button.visible = is_selected

	var stylebox := profile_image_frame.get_theme_stylebox("panel")

	if stylebox is StyleBoxFlat:
		var flat_stylebox := stylebox as StyleBoxFlat
		flat_stylebox.border_color = SELECTED_BORDER_COLOR if is_selected else DEFAULT_BORDER_COLOR


func _on_gui_input(event) -> void:
	if event is InputEventMouseButton and event.pressed:
		avatar_selected.emit(image_path, self)
