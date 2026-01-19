extends Node
class_name UIHotkeys

@export var diary_menu_scene: PackedScene = preload("res://scenes/Menues/GameMenu/diary_menu.tscn")

const TAB_DIARY := 0
const TAB_INVENTORY := 1
const TAB_QUESTS := 2

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	# nur wenn Tagebuch eingesammelt
	if not bool(GameState.puzzle_state.get("spaceship_diary", false)):
		return

	if event.is_action_pressed("toggle_inventory"):
		_toggle_menu_or_switch_tab(TAB_INVENTORY)
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("toggle_diary"):
		_toggle_menu_or_switch_tab(TAB_DIARY)
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("toggle_quests"):
		_toggle_menu_or_switch_tab(TAB_QUESTS)
		get_viewport().set_input_as_handled()
		return


func _toggle_menu_or_switch_tab(tab_index: int) -> void:
	var menu := get_tree().get_first_node_in_group("diary_menu")

	if menu != null:
		var tabs := _find_tab_container(menu)
		if tabs:
			if tabs.current_tab == tab_index:
				_close_menu(menu)
			else:
				tabs.current_tab = tab_index
		else:
			_close_menu(menu)
		return

	_open_menu(tab_index)


func _open_menu(tab_index: int) -> void:
	if diary_menu_scene == null:
		push_warning("UIHotkeys: diary_menu_scene ist null")
		return

	
	if hotbarglobal.hotbar:
		hotbarglobal.hotbar.hide()
	if GlobalMenuButton:
		GlobalMenuButton.hide()
	if SettingsButton:
		SettingsButton.hide()

	get_tree().paused = true

	var inst := diary_menu_scene.instantiate()
	get_tree().root.add_child(inst)

	var tabs := _find_tab_container(inst)
	if tabs:
		tabs.current_tab = tab_index
	else:
		push_warning("UIHotkeys: Kein TabContainer im diary_menu gefunden.")


func _close_menu(menu: Node) -> void:
	# UI zurück
	get_tree().paused = false
	if hotbarglobal.hotbar:
		hotbarglobal.hotbar.show()
	if GlobalMenuButton:
		GlobalMenuButton.show()
	if SettingsButton:
		SettingsButton.show()

	if menu.has_method("close_menu"):
		menu.call("close_menu")
	else:
		menu.queue_free()


func _find_tab_container(root: Node) -> TabContainer:
	if root is TabContainer:
		return root as TabContainer
	for c in root.get_children():
		var found := _find_tab_container(c)
		if found:
			return found
	return null
