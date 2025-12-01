extends OptionButton

func _ready() -> void:
	var popup = get_popup()  
	#check icon weg
	for i in popup.get_item_count():
		popup.set_item_as_checkable(i, false)
		popup.set_item_as_radio_checkable(i, false)
	#hover colour bis zum rand
	var indent := 3  
	for i in popup.get_item_count():
		popup.set_item_indent(i, indent)
