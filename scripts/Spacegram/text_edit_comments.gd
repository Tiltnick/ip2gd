extends TextEdit

@onready var input = $TextEdit

const MIN_LINES := 1
const MAX_LINES := 4

func _ready():
	input.text_changed.connect(_on_text_changed)
	_update_height()


func _on_text_changed():
	_update_height()


func _update_height():
	var line_count = input.get_line_count()
	var line_height = input.get_line_height()

	# clamp zwischen min und max
	var visible_lines = clamp(line_count, MIN_LINES, MAX_LINES)

	# neue Höhe berechnen
	var new_height = visible_lines * line_height + 10 # padding

	input.custom_minimum_size.y = new_height

	# Scroll aktivieren, wenn über max
	input.scroll_vertical_enabled = line_count > MAX_LINES
	#input.scroll_vertical = line_count > MAX_LINES
