extends GhostState
class_name GhostDialog

var _connected := false

func Enter(_prev: GhostState) -> void:
	ghost.velocity = Vector2.ZERO
	if ghost.anim:
		ghost.anim.play("idle")

	# Fallback: wenn nicht gesetzt, direkt laufen
	if ghost.dialog_runner == null or ghost.dialog_process == null:
		TransitionTo("move")
		return

	var scene_name := get_tree().current_scene.name
	var dialog_path := ghost.dialog_process.get_dialog_path(scene_name)

	# Mit deinem DialogManager kompatibel: start_dialog(path)
	if ghost.dialog_runner.has_method("start_dialog"):
		ghost.dialog_runner.call("start_dialog", dialog_path)
	else:
		push_warning("dialog_runner has no method start_dialog(json_path).")
		TransitionTo("move")
		return

	# Auf dialog_finished warten
	if ghost.dialog_runner.has_signal("dialog_finished") and not _connected:
		ghost.dialog_runner.connect("dialog_finished", _on_dialog_finished)
		_connected = true

func Exit() -> void:
	if _connected and ghost.dialog_runner:
		if ghost.dialog_runner.is_connected("dialog_finished", _on_dialog_finished):
			ghost.dialog_runner.disconnect("dialog_finished", _on_dialog_finished)
	_connected = false

func _on_dialog_finished() -> void:
	ghost.unlock_interaction()
	TransitionTo("move")
