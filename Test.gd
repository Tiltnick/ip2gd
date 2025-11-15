extends Node2D



func _ready() -> void:
	# Start the dialogue once the scene loads.
	var dialog_manager := $DialogManager
	dialog_manager.choice_made.connect(_on_dialog_choice_made)
	dialog_manager.start_dialog("res://dialog/test.json")
# TODO Maybe but this in the dialog manager too ? 
func _on_dialog_choice_made(choice_id: String) -> void:
	var decisions: Array = []
	decisions.append(choice_id)
	
