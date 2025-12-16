extends Button

const DIARY_MENU_SCENE: PackedScene = preload("res://scenes/Menues/GameMenu/diary_menu.tscn") # Pfad ggf. anpassen

func _on_pressed() -> void:
	get_tree().paused = true
	GlobalMenuButton.hide()
	SettingsButton.hide()

	# diary_menu holen oder neu instanziieren
	var menu := get_tree().get_first_node_in_group("diary_menu")
	if menu == null:
		menu = DIARY_MENU_SCENE.instantiate()

		# in die aktuelle Szene hängen (oder root, falls keine current_scene)
		var current_scene := get_tree().current_scene
		if current_scene:
			current_scene.add_child(menu)
		else:
			get_tree().root.add_child(menu)

	menu.show()

	hotbarglobal.hotbar.hide()
	SfxPlayer.ui_click_sound()
