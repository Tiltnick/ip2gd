extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_new_g_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/folderSetup.tscn")
#TODO link to start scene

func _on_resume_button_pressed() -> void:
	print("pressed resume") #funktion muss noch rein wenn gespeichert
	#oder raus wenn speichern erst im nächsten sprint

func _on_exit_button_pressed() -> void:
	get_tree().quit()
