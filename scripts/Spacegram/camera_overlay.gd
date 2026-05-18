extends Control

signal photo_confirmed(image_path)
signal camera_closed

@onready var confirm_button = $DimBackground/PhoneFrameHorizontal/Screen/CameraPreview/HeaderMarginContainer/Header/ConfirmButton
@onready var cancel_button = $DimBackground/PhoneFrameHorizontal/Screen/CameraPreview/HeaderMarginContainer/Header/CancelButton
@onready var close_button = $DimBackground/CloseButton

var captured_image_path: String = ""


func _ready():
	visible = false


func capture_screenshot() -> void:
	visible = false

	await RenderingServer.frame_post_draw

	var image := get_viewport().get_texture().get_image()

	visible = true

	var dir_path := "user://spacegram/posts"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir_path))

	var file_name := "post_%s.png" % Time.get_datetime_string_from_system().replace(":", "-")
	var file_path := dir_path + "/" + file_name

	var error := image.save_png(file_path)

	if error != OK:
		print("Screenshot konnte nicht gespeichert werden: ", error)
		return

	captured_image_path = file_path
	print("Screenshot gespeichert: ", captured_image_path)


func _on_confirm_pressed():
	if captured_image_path.is_empty():
		await capture_screenshot()

	if captured_image_path.is_empty():
		return

	photo_confirmed.emit(captured_image_path)


func _on_cancel_pressed():
	camera_closed.emit()


func _on_close_pressed():
	camera_closed.emit()
