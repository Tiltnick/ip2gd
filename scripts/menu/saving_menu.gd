extends CanvasLayer

func _ready() -> void:
	hide()


func resume():
	get_tree().paused = false
	hide()

	# Dialog wieder einblenden nur wenn er läuft
	if DialogManager and DialogManager.is_running:
		DialogManager.show()

	if hotbarglobal.hotbar:
		hotbarglobal.hotbar.show()


func pause():
	get_tree().paused = true
	show()

	for node in get_tree().get_nodes_in_group("diary_menu"):
		if node.has_method("close_menu"):
			node.close_menu()
		else:
			node.queue_free()


	if GameState.puzzle_state.get("spaceship_diary", false):
		GlobalMenuButton.show()
	else:
		GlobalMenuButton.hide()

	# Dialog verstecken falls er läuft 
	if DialogManager and DialogManager.is_running:
		DialogManager.hide()

	if hotbarglobal.hotbar:
		hotbarglobal.hotbar.hide()


func toggle_pause():
	if get_tree().paused == false:
		pause()
	else:
		resume()


func esc():
	var current_scene := get_tree().current_scene
	if current_scene and current_scene.name == "MainMenu":
		return

	if not Input.is_action_just_pressed("esc"):
		return

	# popup erst schließen
	if _close_topmost_overlay():
		get_viewport().set_input_as_handled()
		return

	# sonst pause
	toggle_pause()


func _close_topmost_overlay() -> bool:
	

	var door_ui := get_tree().get_first_node_in_group("door_code_ui")
	if door_ui and door_ui.visible:
		_close_overlay_node(door_ui)
		return true

	var statue_ui := get_tree().get_first_node_in_group("statue_puzzle_ui")
	if statue_ui and statue_ui.visible:
		_close_overlay_node(statue_ui)
		return true

	var chest_puzzle := get_tree().get_first_node_in_group("chest_puzzle_ui")
	if chest_puzzle and chest_puzzle.visible:
		_close_overlay_node(chest_puzzle)
		return true
		
	var panel_puzzle := get_tree().get_first_node_in_group("panel_puzzle_ui")
	if panel_puzzle and panel_puzzle.visible:
		_close_overlay_node(panel_puzzle)
		return true
		
	var socket_puzzle := get_tree().get_first_node_in_group("socket_puzzle_ui")
	if socket_puzzle and socket_puzzle.visible:
		_close_overlay_node(socket_puzzle)
		return true

	return false


func _close_overlay_node(n: Node) -> void:
	
	if n.has_method("close_puzzle"):
		n.call("close_puzzle")
	elif n.has_method("close"):
		n.call("close")
	else:
		n.hide()


func _on_continue_button_pressed() -> void:
	resume()


func _on_round_buttton_pressed() -> void:
	resume()


func _on_exit_button_pressed() -> void:
	var current_scene := get_tree().current_scene
	if current_scene:
		GameState.current_area_path = current_scene.get_scene_file_path()

	SaveSystem.save_game()
	GameState.has_save = true

	DialogManager.force_close()

	get_tree().paused = false
	hide()

	for node in get_tree().get_nodes_in_group("diary_menu"):
		if node.has_method("close_menu"):
			node.close_menu()
		else:
			node.queue_free()

	GlobalMenuButton.show()
	SettingsButton.show()

	SceneManager.goto_main_menu()


func _process(_delta: float) -> void:
	var auth = get_tree().get_first_node_in_group("auth_screen")
	if auth and auth.visible:
		return
	esc()
