extends Door

@export var code_popup_path: NodePath
@export var puzzle_id: String = "Spaceship_code"
@export var puzzle_title: String = "Spaceship_code"
@export var required_items: Array[String] = []

var puzzle_open_logged := false

@export_file("*.json")
var missing_items_dialog_json: String

var code_popup: CanvasLayer
var code_solved: bool = false


func _ready():
	super._ready()

	set_texture()

	if code_popup_path != null and code_popup_path != NodePath(""):
		code_popup = get_node(code_popup_path) as CanvasLayer
	else:
		push_warning("Kein Code-Popup Pfad gesetzt!")

	if puzzle_id != "" and GameState.puzzle_state.has(puzzle_id):
		if GameState.puzzle_state[puzzle_id] == true:
			code_solved = true
			change_sprite()

	print("LOAD CHECK stone_puzzle =", GameState.puzzle_state.get("stone_puzzle", false))


func interact() -> void:
	SfxPlayer.ui_click_sound()

	if code_solved:
		_try_open_after_item_check()
		return

	if not code_popup:
		push_error("Kein Code-Popup zugewiesen!")
		return

	if not puzzle_open_logged:
		puzzle_open_logged = true
		PuzzleEvents.started(puzzle_id, puzzle_title)

	code_popup.visible = true

	var first_input = code_popup.get_node("Control/Panel2/HBoxContainer/Input1") as LineEdit
	if first_input:
		first_input.grab_focus()

	var callback := Callable(self, "_on_code_verified")
	if not code_popup.is_connected("code_verified", callback):
		code_popup.connect("code_verified", callback)


func _on_code_verified(result: bool) -> void:
	if not result:
		return

	_end_puzzle("solved")

	SfxPlayer.puzzle_solved()
	code_solved = true

	if puzzle_id != "":
		GameState.puzzle_state[puzzle_id] = true

	if code_popup:
		code_popup.visible = false

	change_sprite()
	_try_open_after_item_check()


func _end_puzzle(result: String) -> void:
	if not puzzle_open_logged:
		return

	puzzle_open_logged = false
	PuzzleEvents.ended(puzzle_id, puzzle_title, result)


func _try_open_after_item_check() -> void:
	if required_items.size() > 0 and not _player_has_all_items():
		_show_missing_items_dialog()
		return

	open_door()


func _player_has_all_items() -> bool:
	var picked_items := GameState.picked_items
	for item_id in required_items:
		if not picked_items.has(item_id):
			return false

	return true


func _show_missing_items_dialog() -> void:
	DialogManager.start_dialog(missing_items_dialog_json)


func set_texture():
	var texture = load("res://assets/sprites/selfmade/spaceship_door_locked.png")
	$Sprite2D.texture = texture


func change_sprite():
	var texture = load("res://assets/sprites/selfmade/spaceship_door_open.png")
	$Sprite2D.texture = texture
