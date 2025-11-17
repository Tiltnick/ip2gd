extends Interactable

@onready var dialog_manager = get_parent().get_node("DialogManager")

func interact():
	print("Buch eingesammelt!")

	# später kommt hier: hotbar.add_item(self.book_id)
	
	# Dialog? 
	dialog_manager.start_dialog("res://dialog/diary/diarytest.json")
	
	# Buch verschwindet
	queue_free()
