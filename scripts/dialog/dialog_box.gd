extends Control

# References to UI elements inside the scene
@onready var portrait = $Portrait
@onready var name_label = $Name
@onready var choices = $Choices
@onready var dialog_text: RichTextLabel = $Dialog

# Settings and state
@export var typing_speed := 0.02   # Delay between each character
var typing := false                # True while the text is being revealed
var skip := false                  # True when the player wants to skip the typing

func _ready():
	hide()  
	show_dialog("NPC", null, "Hallo! Das ist ein Test.")  # Example dialog on startup

func show_dialog(charakter_name: String = "", portrait_texture: Texture2D = null, text: String = ""):
	# Handle the character name label
	if charakter_name == "":
		name_label.hide()
	else:
		name_label.text = charakter_name
		name_label.show()

	# Handle the portrait image
	if portrait_texture == null:
		portrait.hide()
	else:
		portrait.texture = portrait_texture
		portrait.show()

	# Hide choices until the text is done typing
	choices.visible = false
	show()
	type_text(text)

func type_text(text: String) -> void:
	# Set up the text for the typewriter effect
	dialog_text.text = text
	dialog_text.visible_characters = 0
	typing = true
	skip = false

	var total := dialog_text.get_total_character_count()
	call_deferred("type_step", total)  # Start typing next frame

func type_step(total: int) -> void:
	# If player skips, show the full text immediately
	if skip:
		dialog_text.visible_characters = total
		finish_typing()
		return

	# Reveal one character at a time
	if dialog_text.visible_characters < total:
		dialog_text.visible_characters += 1
		await get_tree().create_timer(typing_speed).timeout
		type_step(total)
	else:
		finish_typing()

func finish_typing() -> void:
	# Called once the text is fully visible
	typing = false
	choices.visible = true

func _unhandled_input(event: InputEvent) -> void:
	# Allow player to skip or advance using "ui_accept"
	if event.is_action_pressed("ui_accept"):
		if typing:
			skip = true
