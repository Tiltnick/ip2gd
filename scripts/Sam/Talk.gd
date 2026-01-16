extends Node

var npc
var sm

var dialog_path: String = ""


func setup(_npc, _sm) -> void:
	npc = _npc
	sm = _sm


func enter() -> void:
	if npc.has_method("stop_and_idle"):
		npc.stop_and_idle()

	var scene_name: String = _get_scene_name()

	if npc._force_fail_dialog:
		dialog_path = npc.get_fail_dialog_path(scene_name)
	else:
		dialog_path = npc.get_dialog_path_for_step(scene_name, npc.step)

	DialogManager.dialog_finished.connect(_on_dialog_finished, CONNECT_ONE_SHOT)
	DialogManager.start_dialog(dialog_path)


func _on_dialog_finished() -> void:
	npc.on_dialog_finished(dialog_path)


func physics_update(_delta: float) -> void:
	pass


func exit() -> void:
	pass


func _get_scene_name() -> String:
	var scene: Node = npc.get_tree().current_scene
	if scene == null:
		return ""
	return String(scene.name)
