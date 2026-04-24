extends PanelContainer

@onready var caption_label = $MarginContainer/VBoxContainer/CaptionLabel

func _ready():
	print("POST ITEM SCRIPT LÄUFT")

func setup_post(username: String, caption: String, time_text: String) -> void:
	caption_label.clear()
	caption_label.append_text(
		"%s [color=#4fa9a7][font_size=12]%s[/font_size][/color]" 
		% [caption, time_text]
	)
