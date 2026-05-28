extends Node

const PHONE_UI_SCENE := preload("res://scenes/Spacegram/PhoneUI.tscn")

var phone_ui: CanvasLayer = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	phone_ui = PHONE_UI_SCENE.instantiate()
	get_tree().root.call_deferred("add_child", phone_ui)

	await get_tree().process_frame

	phone_ui.visible = false


func open_phone() -> void:
	if phone_ui == null:
		print("PhoneManager: PhoneUI fehlt.")
		return

	if phone_ui.has_method("open_phone"):
		phone_ui.open_phone()
	else:
		phone_ui.visible = true


func close_phone() -> void:
	if phone_ui == null:
		return

	if phone_ui.has_method("close_phone"):
		phone_ui.close_phone()
	else:
		phone_ui.visible = false


func update_visibility() -> void:
	if phone_ui:
		phone_ui.visible = false
