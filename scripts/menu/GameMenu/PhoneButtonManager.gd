extends CanvasLayer

const PHONE_BUTTON_SCENE := preload("res://scenes/Menues/GameMenu/phone_button.tscn")

var button_instance: Node = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	button_instance = PHONE_BUTTON_SCENE.instantiate()
	add_child(button_instance)

	update_visibility()


func update_visibility() -> void:
	if button_instance == null:
		return

	var in_main_menu := false
	var scene := get_tree().current_scene

	if scene != null and scene.scene_file_path == "res://scenes/Menues/main_menu.tscn":
		in_main_menu = true

	if in_main_menu:
		button_instance.visible = false
		return

	if button_instance.has_method("update_visibility"):
		button_instance.update_visibility()


func show_button() -> void:
	if button_instance:
		button_instance.visible = true


func hide_button() -> void:
	if button_instance:
		button_instance.visible = false
