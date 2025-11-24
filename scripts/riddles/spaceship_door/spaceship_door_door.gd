extends Door

@export var code_popup_path: NodePath
# ID für Gamestate
@export var puzzle_id: String = "Spaceship_code"      

var code_popup: CanvasLayer   # CanvasLayer, nicht Control!
var code_solved: bool = false


func _ready():
	
	super ._ready()
	
	if code_popup_path != null and code_popup_path != NodePath(""):
		code_popup = get_node(code_popup_path) as CanvasLayer
	else:
		push_warning("Kein Code-Popup Pfad gesetzt!")

	# Puzzle ID != null und Gamestate hat die puzzle ID dann code solved = true
	if puzzle_id != "" and GameState.puzzle_state.has(puzzle_id):
		if GameState.puzzle_state[puzzle_id] == true:
			code_solved = true


func interact() -> void:
	# Wenn das Rätsel bereits gelöst ist → normale Türfunktion
	if code_solved:
		open_door()
		return

	# Popup muss gesetzt sein
	if not code_popup:
		push_error("Kein Code-Popup zugewiesen!")
		return

	# Popup anzeigen
	code_popup.visible = true

	# Fokus setzen
	var first_input = code_popup.get_node("Control/Panel2/HBoxContainer/Input1") as LineEdit
	if first_input:
		first_input.grab_focus()

	# Godot 4 Callable
	var callback := Callable(self, "_on_code_verified")

	if not code_popup.is_connected("code_verified", callback):
		code_popup.connect("code_verified", callback)


func _on_code_verified(result: bool) -> void:
	if result:
		code_solved = true

		# NEU: im GameState merken, dass dieses Rätsel gelöst wurde
		if puzzle_id != "":
			GameState.puzzle_state[puzzle_id] = true

		code_popup.visible = false
		open_door()
