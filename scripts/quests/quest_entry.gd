extends Button
class_name QuestEntry

@onready var name_label: Label = $Button/Label
@onready var new_icon: TextureRect = $Button/TextureRect

var quest_id: String
var quest_data: Dictionary
var is_completed := false

signal quest_selected(quest_data: Dictionary)

func setup(id: String, data: Dictionary, is_new := true, completed := false):
	quest_id = id
	quest_data = data
	name_label.text = data["title"]

	new_icon.visible = is_new and not completed
	is_completed = completed
	disabled = completed
	modulate = Color(0.6, 0.6, 0.6) if completed else Color.BLACK

func _pressed():
	new_icon.visible = false
	emit_signal("quest_selected", quest_data)
