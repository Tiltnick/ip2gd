extends Control
class_name DialogBox

# emitted when the player presses space (Continue)
signal continue_pressed

# emitted when the player clicks on a choice button (index is 0-based)
signal choice_selected(index: int)

@onready var name_label: Label          = $NinePatchRect/Name
@onready var dialog_text: RichTextLabel = $NinePatchRect/Dialog
@onready var portrait: TextureRect      = $NinePatchRect/Portrait
@onready var choice1: Control           = $NinePatchRect/Choice1
@onready var choice2: Control           = $NinePatchRect/Choice2
@onready var choice1_text: RichTextLabel        = $NinePatchRect/Choice1/Text_Choice1
@onready var choice2_text: RichTextLabel        = $NinePatchRect/Choice2/Text_Choice2

# typewriter speed in seconds per character 
@export var typing_speed: float = 0.02
@export var max_chars_per_page: int = 200

var typing: bool = false     # true while characters are being typed
var skip: bool = false       # set to true to instantly reveal the rest
var full_text: String = ""   # the full line we want to display
var _pages: Array[String] = []
var _page_index: int = 0

func _ready() -> void:
	hide()
	choice1.visible = false
	choice2.visible = false
	choice1.mouse_filter = Control.MOUSE_FILTER_STOP
	choice2.mouse_filter = Control.MOUSE_FILTER_STOP
	choice1.gui_input.connect(_on_choice1_clicked)
	choice2.gui_input.connect(_on_choice2_clicked)

func show_line(speaker: String, text: String) -> void:
	if speaker.strip_edges() == "":
		name_label.text = ""
		name_label.hide()
	else:
		name_label.text = speaker
		name_label.show()

	full_text = text
	_pages = _split_into_pages(full_text)
	_page_index = 0

	typing = true
	skip = false
	show()

	hide_choices()
	_apply_current_page()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if typing:
			skip = true
		else:
			if _page_index < _pages.size() - 1:
				_page_index += 1
				typing = true
				skip = false
				_apply_current_page()
			else:
				emit_signal("continue_pressed")

func typewriter() -> void:
	await get_tree().process_frame

	var total: int = dialog_text.get_total_character_count()

	while typing:
		if skip:
			dialog_text.visible_characters = total
			break

		var next_count: int = min(dialog_text.visible_characters + 1, total)
		dialog_text.visible_characters = next_count

		if next_count >= total:
			break

		await get_tree().create_timer(typing_speed).timeout

	typing = false
	skip = false


func show_choices(choice_texts: Array) -> void:
	hide_choices()

	if choice_texts.size() >= 1:
		choice1.visible = true
		choice1_text.text = String(choice_texts[0])
	if choice_texts.size() >= 2:
		choice2.visible = true
		choice2_text.text = String(choice_texts[1])

func hide_choices() -> void:
	choice1.visible = false
	choice2.visible = false

func _on_choice1_clicked(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		hide_choices()
		emit_signal("choice_selected", 0)

func _on_choice2_clicked(event: InputEventMouseButton) -> void:
	if event is InputEventMouseButton and event.pressed:
		hide_choices()
		emit_signal("choice_selected", 1)

func _apply_current_page() -> void:
	dialog_text.text = _pages[_page_index]
	dialog_text.visible_characters = 0
	typewriter()

func _split_into_pages(text: String) -> Array[String]:
	var result: Array[String] = []
	var max_chars: int = max_chars_per_page
	var i: int = 0
	var length: int = text.length()
	while i < length:
		var end: int = min(i + max_chars, length)
		var slice_end: int = end
		if end < length:
			var last_space: int = text.rfind(" ", end - 1)
			if last_space >= i:
				slice_end = last_space + 1
		var part: String = text.substr(i, slice_end - i)
		result.append(part)
		i = slice_end
	if result.is_empty():
		result.append("")
	return result
