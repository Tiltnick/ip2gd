extends Control
class_name DialogBox

# emitted when the player presses space (Continue)
signal continue_pressed

@onready var name_label: Label          = $NinePatchRect/Name
@onready var dialog_text: RichTextLabel = $NinePatchRect/Dialog
@onready var portrait: TextureRect      = $NinePatchRect/Portrait
@onready var choices: Control           = $NinePatchRect/Choices

# typewriter speed in seconds per character 
@export var typing_speed: float = 0.02


var typing: bool = false     # true while characters are being typed
var skip: bool = false       # set to true to instantly reveal the rest
var full_text: String = ""   # the full line we want to display

func _ready() -> void:

	hide()

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
	dialog_text.text = full_text
	dialog_text.visible_characters = 0

	# reset typing state and make the box visible
	typing = true
	skip = false
	show()

	# start typewriter
	typewriter()

func unhandled_input(event: InputEvent) -> void:
	# One button does two things depending on state:
	# while typing: skip animation and reveal the rest
	# after typing: tell the manager we're ready to advance
	if event.is_action_pressed("ui_accept"):
		if typing:
			skip = true
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
