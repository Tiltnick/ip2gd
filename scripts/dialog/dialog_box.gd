extends Control

@onready var portrait = $Portrait
@onready var name_label = $Name
@onready var choices = $Choices
@onready var dialog_text: RichTextLabel = $Dialog

@export var typing_speed := 0.02
var typing := false
var skip := false

func _ready():
	hide()  
	show_dialog("NPC", null, "Hallo! Das ist ein Test.")

func show_dialog(charakter_name: String = "", portrait_texture: Texture2D = null, text: String = ""):
	if charakter_name == "":
		name_label.hide()
	else:
		name_label.text = charakter_name
		name_label.show()

	if portrait_texture == null:
		portrait.hide()
	else:
		portrait.texture = portrait_texture
		portrait.show()

	choices.visible = false
	show()
	type_text(text)

func type_text(text: String) -> void:
	dialog_text.text = text
	dialog_text.visible_characters = 0
	typing = true
	skip = false

	var total := dialog_text.get_total_character_count()
	call_deferred("type_step", total)

func type_step(total: int) -> void:
	if skip:
		dialog_text.visible_characters = total
		finish_typing()
		return

	if dialog_text.visible_characters < total:
		dialog_text.visible_characters += 1
		await get_tree().create_timer(typing_speed).timeout
		type_step(total)
	else:
		finish_typing()

func finish_typing() -> void:
	typing = false
	choices.visible = true

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if typing:
			skip = true
