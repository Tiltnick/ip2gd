extends Control
class_name DialogBox

# emitted when the player presses space (Continue)
signal continue_pressed

# emitted when the player clicks on a choice button (index is 0-based)
signal choice_selected(index: int)

@onready var name_label: Label          = $NinePatchRect/Name
@onready var dialog_text: RichTextLabel = $NinePatchRect/Dialog
@onready var portrait: TextureRect      = $NinePatchRect/Portrait
@onready var choices: VBoxContainer     = $NinePatchRect/Choices  # <-- VBoxContainer

# typewriter speed in seconds per character 
@export var typing_speed: float = 0.02
@export var max_chars_per_page: int = 200

var typing: bool = false     # true while characters are being typed
var skip: bool = false       # set to true to instantly reveal the rest
var full_text: String = ""   # the full line we want to display
var _pages: Array[String] = []
var _page_index: int = 0

func _ready() -> void:
	# Start hidden; the manager decides when to show/hide.
	hide()
	# Make sure the choices container is hidden initially.
	if is_instance_valid(choices):
		choices.visible = false

func show_line(speaker: String, text: String) -> void:
	# update the speaker label (hide it if empty)
	if speaker.strip_edges() == "":
		name_label.text = ""
		name_label.hide()
	else:
		name_label.text = speaker
		name_label.show()

	# set the full text but hide all characters for now
	full_text = text
	_pages = _split_into_pages(full_text)
	_page_index = 0

	# reset typing state and make the box visible
	typing = true
	skip = false
	show()

	# hide any stale choices from previous steps
	hide_choices()

	# start typewriter
	_apply_current_page()

func _unhandled_input(event: InputEvent) -> void:
	# One button does two things depending on state:
	# while typing: skip animation and reveal the rest
	# after typing: tell the manager we're ready to advance
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
	# Wait one frame so the label has laid out the text;
	# otherwise get_total_character_count() can be wrong.
	await get_tree().process_frame

	var total: int = dialog_text.get_total_character_count()

	while typing:
		# If the player requested a skip, reveal everything at once
		if skip:
			dialog_text.visible_characters = total
			break

		# Reveal the next character
		var next_count: int = min(dialog_text.visible_characters + 1, total)
		dialog_text.visible_characters = next_count

		# If we reached the end of the line, stop typing
		if next_count >= total:
			break

		# Small delay to create the typewriter feel
		await get_tree().create_timer(typing_speed).timeout

	# Clean up and wait to continue
	typing = false
	skip = false


# Show a list of choices (array of strings). Creates one Button per entry.
func show_choices(choice_texts: Array) -> void:

	# Clear previous buttons and show container
	_clear_children(choices)
	choices.visible = true

	# Add the buttons into the hbox
	for i in choice_texts.size():
		var b := Button.new()
		b.text = String(choice_texts[i])
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.size_flags_vertical = Control.SIZE_FILL
		b.focus_mode = Control.FOCUS_NONE
		choices.add_child(b)

		# Each button emits the index and we also hide the choice box.
		b.pressed.connect(func():
			hide_choices()
			emit_signal("choice_selected", i)
		)

# Hide and clear  choices containers.
func hide_choices() -> void:
	if not is_instance_valid(choices):
		return
	choices.visible = false
	_clear_children(choices)

# Delete Choices
func _clear_children(node: Node) -> void:
	for c in node.get_children():
		c.queue_free()

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
