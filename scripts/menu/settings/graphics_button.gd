extends OptionButton

func _ready() -> void:
	var popup = get_popup()
	# Entfernt checkboxes etc. sieht besser aus finde ich
	for i in popup.get_item_count():
		popup.set_item_as_checkable(i, false)
		popup.set_item_as_radio_checkable(i, false)

	var indent := 3
	for i in popup.get_item_count():
		popup.set_item_indent(i, indent)

	add_item("Windowed")
	set_item_metadata(item_count - 1, "windowed")

	add_item("Fullscreen")
	set_item_metadata(item_count - 1, "fullscreen")

	add_item("Borderless")
	set_item_metadata(item_count - 1, "borderless")

	_select_current_mode()
	item_selected.connect(_on_item_selected)

	_select_current_mode()
	item_selected.connect(_on_item_selected)

func _select_current_mode() -> void:
	var current = DisplayServer.window_get_mode()
	for i in item_count:
#		if int(get_item_metadata(i)) == current:
			select(i)
			return

func _on_item_selected(index: int) -> void:
	var mode = int(get_item_metadata(index))
	DisplayServer.window_set_mode(mode)


	#GameState.language = locale
