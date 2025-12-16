extends CanvasLayer

func _ready() -> void:
	add_to_group("diary_menu")

# hier drauf hören alle tabs im menu für closeButton!
func close_menu():
	visible = false
	get_tree().paused = false
	GlobalMenuButton.show()
	SettingsButton.show()
	hotbarglobal.hotbar.show()

	# diary_menu komplett entfernen, damit es nicht "hängen bleibt"
	queue_free()
