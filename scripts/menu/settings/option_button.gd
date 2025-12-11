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

	# Verknüpfung der Einträge
	if get_item_count() >= 2:
		set_item_metadata(0, "en")  
		set_item_metadata(1, "de")  

	_select_current_locale()                 
	item_selected.connect(_on_item_selected) 

func _select_current_locale() -> void:    
	var current: String = TranslationServer.get_locale()
	for i in get_item_count():
		var locale: String = str(get_item_metadata(i))
		if locale == current:
			select(i)
			return


func _on_item_selected(index: int) -> void:
	var locale: String = str(get_item_metadata(index))
	TranslationServer.set_locale(locale)
	GameState.language = locale
