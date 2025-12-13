extends Door

@export var code_popup_path: NodePath
@export var puzzle_id: String = "Spaceship_code"      

var code_popup: CanvasLayer
var code_solved: bool = false


func _ready():
	
	super ._ready()
	
	set_texture()
	
	if code_popup_path != null and code_popup_path != NodePath(""):
		code_popup = get_node(code_popup_path) as CanvasLayer
	else:
		push_warning("Kein Code-Popup Pfad gesetzt!")

	if puzzle_id != "" and GameState.puzzle_state.has(puzzle_id):
		if GameState.puzzle_state[puzzle_id] == true:
			code_solved = true
			change_sprite()


func interact() -> void:
	SfxPlayer.ui_click_sound()
	if code_solved:
		
	
		open_door()
		return

	if not code_popup:
		
	
		push_error("Kein Code-Popup zugewiesen!")
		return

	code_popup.visible = true

	var first_input = code_popup.get_node("Control/Panel2/HBoxContainer/Input1") as LineEdit
	if first_input:
		first_input.grab_focus()

	var callback := Callable(self, "_on_code_verified")

	if not code_popup.is_connected("code_verified", callback):
		code_popup.connect("code_verified", callback)


func _on_code_verified(result: bool) -> void:
	if result:
		SfxPlayer.puzzle_solved()
		code_solved = true

		if puzzle_id != "":
			GameState.puzzle_state[puzzle_id] = true

		code_popup.visible = false
		open_door()


func set_texture():
	var texture = load('res://assets/sprites/selfmade/spaceship_door_locked.png')
	$Sprite2D.texture = texture

func change_sprite():
	var texture = load('res://assets/sprites/selfmade/spaceship_door_open.png')
	$Sprite2D.texture = texture
