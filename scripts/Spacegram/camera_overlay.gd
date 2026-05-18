extends Control

signal photo_confirmed(image_path)
signal camera_closed

@onready var confirm_button = $DimBackground/PhoneFrameHorizontal/Screen/CameraPreview/HeaderMarginContainer/Header/ConfirmButton
@onready var cancel_button = $DimBackground/PhoneFrameHorizontal/Screen/CameraPreview/HeaderMarginContainer/Header/CancelButton
@onready var close_button = $DimBackground/CloseButton

@onready var capture_button = $DimBackground/PhoneFrameHorizontal/Screen/CameraPreview/FooterMarginContainer/Footer/CaptureButton
@onready var screenshot_preview = $DimBackground/PhoneFrameHorizontal/Screen/CameraPreview/ScreenshotPreview
@onready var small_preview = $DimBackground/PhoneFrameHorizontal/Screen/CameraPreview/FooterMarginContainer/Footer/PanelContainer/SmallPreview

var captured_image_path: String = ""


func _ready() -> void:
	visible = false
	_reset_camera_state()


func _reset_camera_state() -> void:
	captured_image_path = ""

	screenshot_preview.texture = null
	small_preview.texture = null

	capture_button.visible = true
	confirm_button.visible = false
	cancel_button.visible = false


func _show_preview_state() -> void:
	capture_button.visible = false
	confirm_button.visible = true
	cancel_button.visible = true


func _on_capture_pressed() -> void:
	await capture_screenshot()

	if not captured_image_path.is_empty():
		_show_preview_state()


func capture_screenshot() -> void:
	# Overlay kurz ausblenden, damit es nicht mitfotografiert wird
	visible = false

	await RenderingServer.frame_post_draw
	await get_tree().process_frame

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

	var texture := ImageTexture.create_from_image(image)
	screenshot_preview.texture = texture
	small_preview.texture = texture

	print("Screenshot gespeichert: ", captured_image_path)


func _on_confirm_pressed() -> void:
	if captured_image_path.is_empty():
		print("Kein Screenshot vorhanden.")
		return

	photo_confirmed.emit(captured_image_path)
	_reset_camera_state()


func _on_cancel_pressed() -> void:
	_reset_camera_state()


func _on_close_pressed() -> void:
	_reset_camera_state()
	camera_closed.emit()
