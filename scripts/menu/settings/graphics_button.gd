extends OptionButton

func _ready() -> void:
	var popup := get_popup()

	for i in popup.get_item_count():
		popup.set_item_as_checkable(i, false)
		popup.set_item_as_radio_checkable(i, false)

	var indent := 3
	for i in popup.get_item_count():
		popup.set_item_indent(i, indent)

	if get_item_count() >= 3:
		set_item_metadata(0, "windowed")
		set_item_metadata(1, "fullscreen")
		set_item_metadata(2, "borderless")

	# Auswahl aus Save übernehmen + anwenden
	_select_current_mode()

	# Signal verbinden (Schutz, falls _ready mehrfach)
	if not item_selected.is_connected(_on_item_selected):
		item_selected.connect(_on_item_selected)


func _select_current_mode() -> void:
	# Wenn du was gespeichert hast: danach gehen
	var choice := ""
	if "display_mode" in GameState and str(GameState.display_mode) != "":
		choice = str(GameState.display_mode)

	# Fallback: aktuellen Zustand vom Window lesen
	if choice == "":
		var mode := DisplayServer.window_get_mode()
		var borderless := DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS)

		choice = "windowed"
		if mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
			choice = "fullscreen"
		elif borderless:
			choice = "borderless"

	# Dropdown auswählen + anwenden
	for i in get_item_count():
		if str(get_item_metadata(i)) == choice:
			select(i)
			_apply_choice(choice)
			return


func _on_item_selected(index: int) -> void:
	var choice := str(get_item_metadata(index))
	print("Graphics selected index=", index, " choice=", choice)

	_apply_choice(choice)
	GameState.display_mode = choice


func _apply_choice(choice: String) -> void:
	print("Applying:", choice)

	match choice:
		"windowed":
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

		"fullscreen":
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
