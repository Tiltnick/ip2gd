extends CanvasLayer

signal choice_made(choice_id: String)
signal dialog_finished
signal dialog_started

@onready var box: DialogBox = $DialogBox

var current_dialog_path: String = ""

var runtime: DialogParser = DialogParser.new()

var is_running: bool = false 


const PUZZLE_FLAG_BY_DIALOG_PATH: Dictionary = {
	"res://dialog/dialogueMrBlob/outside_1.json": "outside1_done",
	"res://dialog/dialogueMrBlob/outside_2_part_1.json": "blob_intro_done",
	"res://dialog/cluesMrBlob/clue_stone_pile.json": "blob_clue_done",
	"res://dialog/dialogueMrBlob/outside_2_part_2.json": "blob_revelation_done",
	"res://dialog/dialogueMrBlob/entering_outside_2.json": "outside2_monologue_done",
	"res://dialog/mushrooms/mushroom.json": "mushroom_dialog_done",
	"res://dialog/cluesMrBlob/clue_stone_panel_completion.json": "blob_clue1_done",
	"res://dialog/cluesMrBlob/clue_mushroom_1.json": "blob_clue2_done",
	"res://dialog/cluesMrBlob/clue_mushroom_2.json": "blob_clue3_done",
	"res://dialog/innerMonologue/tripod_without_telescope.json": "tripod_no_telescope_seen",
	"res://dialog/Sam_ghost/Sam.json": "sam_dialog_1_done",
	"res://dialog/Sam_ghost/Sam2.json": "sam_dialog_2_done",
	"res://dialog/Sam_ghost/Sam3.json": "sam_dialog_3_done",
	"res://dialog/Sam_ghost/SamFailed.json": "sam_fail_dialog_done",

	
}


func _ready() -> void:
	hide()


func start_dialog(json_path: String) -> void:
	print("START DIALOG:", json_path)

	# Falls noch ein alter Dialog läuft dann abbrechen
	force_close()

	is_running = true
	current_dialog_path = json_path
	show()
	dialog_is_started()

	
	GameState.start_dialog(current_dialog_path)

	if not runtime.load_json(json_path):
		push_error("Dialog konnte nicht geladen werden: " + json_path)
		# Direkt abbrechen keine Flags setzen
		force_close()
		return


	while is_running and not runtime.is_finished():
		var line: Dictionary = runtime.get_current_line()
		if line.is_empty():
			break

		var speaker: String = String(line.get("speaker", ""))
		var text: String    = String(line.get("text", ""))
		var portrait_path: String = String(line.get("portrait", ""))

		box.show_line(speaker, text, portrait_path)

		await box.continue_pressed
		SfxPlayer.ui_click_sound()

		if not is_running:
			break

		if runtime.is_last_line_in_node() and runtime.has_choices_for_current_node():
			var choice_texts: Array[String] = []
			for c in runtime.get_current_choices():
				choice_texts.append(String(c.get("text", "")))

			box.show_choices(choice_texts)
			var selected_index: int = await box.choice_selected

			if not is_running:
				break

			var choices_array: Array = runtime.get_current_choices()
			if selected_index >= 0 and selected_index < choices_array.size():
				var chosen: Dictionary = choices_array[selected_index] as Dictionary
				var chosen_id: String = String(chosen.get("id", ""))

				choice_made.emit(chosen_id)
				SfxPlayer.ui_click_sound()
				Choice_Store.add_choice_id(chosen_id)

			runtime.choose(selected_index)
			continue

		runtime.next()

	dialog_is_finished()


func dialog_is_finished() -> void:
	if not is_running:
		box.hide()
		hide()
		return

	# Dialog-State speichern
	GameState.finish_dialog(current_dialog_path)

	# Puzzle-Flag setzen
	_apply_puzzle_flag_for_dialog(current_dialog_path)

	current_dialog_path = ""

	box.hide()
	dialog_finished.emit()
	is_running = false
	hide()


func _apply_puzzle_flag_for_dialog(dialog_path: String) -> void:
	var flag: String = PUZZLE_FLAG_BY_DIALOG_PATH.get(dialog_path, "")
	if flag == "":
		return
	GameState.puzzle_state[flag] = true


func dialog_is_started() -> void:
	dialog_started.emit()


#Dialog  abbrechen bei save&exi
func force_close() -> void:
	if not is_running:
		return

	is_running = false
	current_dialog_path = ""
	# Parser zurücksetzen
	runtime = DialogParser.new()

	box.hide()
	hide()
