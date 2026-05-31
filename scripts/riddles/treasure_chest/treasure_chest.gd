extends Interactable

@export var code_popup_path: NodePath
@export var puzzle_id: String = "treasure_chest_code"
@export var shovel_path: NodePath
var shovel: ShovelItem

var code_popup: CanvasLayer
var code_solved: bool = false

func _ready():
	super ._ready()
	set_texture()
	
	if shovel_path != NodePath(""):
		shovel = get_node(shovel_path) as ShovelItem

	if code_popup_path != null and code_popup_path != NodePath(""):
		code_popup = get_node(code_popup_path) as CanvasLayer
	else:
		push_warning("Kein Code-Popup Pfad gesetzt!")

	if puzzle_id != "" and GameState.puzzle_state.has(puzzle_id):
		if GameState.puzzle_state[puzzle_id] == true:
			code_solved = true
			change_sprite()
	print("LOAD CHECK stone_puzzle =", GameState.puzzle_state.get("stone_puzzle", false))

func set_texture():
	var texturee = load('res://assets/sprites/map/Outside_2/Treasure.png')
	$Sprite2D.texture = texturee
	var outline = load('res://assets/sprites/map/Outside_2/Treasure.png')
	$Outline.texture = outline
	
func change_sprite():
	var texturee = load('res://assets/sprites/map/Outside_2/Treasure_open.png')
	$Sprite2D.texture = texturee
	var outline = load('res://assets/sprites/map/Outside_2/Treasure_open.png')
	$Outline.texture = outline


func interact() -> void:
	GameState.unlock_progress_key("shovel_puzzle_discovered")
	SfxPlayer.ui_click_sound()
	PopupManager.popup_spacegram()

	if code_solved:
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
	change_sprite()

	if result:
		SfxPlayer.puzzle_solved()
		if not hotbarglobal.give_item("shovel", "shovel_1"):
			return
		code_solved = true

		GameState.puzzle_state[puzzle_id] = true

		if shovel:
			shovel.visible = true

		code_popup.visible = false
		
		ShovelItem.new().found()
