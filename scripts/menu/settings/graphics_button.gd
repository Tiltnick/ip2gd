#extends OptionButton
#
#func _ready() -> void:
	#print("hallo")
	#var popup = get_popup()
	## Entfernt checkboxes etc. sieht besser aus finde ich
	#for i in popup.get_item_count():
		#popup.set_item_as_checkable(i, false)
		#popup.set_item_as_radio_checkable(i, false)
#
	#var indent := 3
	#for i in popup.get_item_count():
		#popup.set_item_indent(i, indent)
#
	#if item_count >= 3:
			#set_item_metadata(0, "windowed")
			#set_item_metadata(1, "fullscreen")
			#set_item_metadata(2, "borderless")
#
	## Wenn du saved mode hast: auswählen + anwenden
	#_select_choice(GameState.display_mode)
	#_apply_choice(GameState.display_mode)
#
	#item_selected.connect(_on_item_selected)
#
#
#func _on_item_selected(index: int) -> void:
	#var choice := str(get_item_metadata(index))
	#_apply_choice(choice)
	#GameState.display_mode = choice
#
#
#func _select_choice(choice: String) -> void:
	#for i in item_count:
		#if str(get_item_metadata(i)) == choice:
			#select(i)
			#return
#
#
#func _apply_choice(choice: String) -> void:
	#match choice:
		#"windowed":
			#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
#
		#"fullscreen":
			#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
#
		#"borderless":
			#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			#DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			#var s := DisplayServer.screen_get_size()
			#DisplayServer.window_set_size(s)
			#DisplayServer.window_set_position(Vector2i(0, 0))
extends OptionButton

func _ready() -> void:
	var popup := get_popup()

	# Optik wie bei dir
	for i in popup.get_item_count():
		popup.set_item_as_checkable(i, false)
		popup.set_item_as_radio_checkable(i, false)

	var indent := 3
	for i in popup.get_item_count():
		popup.set_item_indent(i, indent)

	# Verknüpfung der Einträge (wichtig: >= 3)
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

		"borderless":
			var screen := DisplayServer.window_get_current_screen()
			var size := DisplayServer.screen_get_size(screen)
			var pos := DisplayServer.screen_get_position(screen)

			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			DisplayServer.window_set_size(size)
			DisplayServer.window_set_position(pos)

	print("Now mode=", DisplayServer.window_get_mode(),
		" borderless=", DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS))
