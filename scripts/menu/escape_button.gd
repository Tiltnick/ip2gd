extends Button

func _ready() -> void:
	#  im MainMenu  Button sofort verstecken
	var scene := get_tree().current_scene
	if scene and scene.name == "MainMenu":
		hide()


func _process(_delta: float) -> void:
	# Sichtbarkeit  an die aktuelle Szene koppeln
	var scene := get_tree().current_scene
	if scene and scene.name == "MainMenu":
		visible = false
	else:
		visible = true


func _on_pressed() -> void:
	# Gleiches Verhalten wie ESC,nutzt Autoload-SavingMenu
	if Engine.has_singleton("SavingMenu"):
		SavingMenu.toggle_pause()
